/**
 *  Copyright (C) 2010-2015 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

func synchronized(lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

class CBPlayerBackend : NSObject {

    static let sharedInstance = CBPlayerBackend() // singleton
    final var running : Bool = false

    override private init() {} // private constructor

    final func prepareExecutionForScriptSequenceList(scriptSequenceList : CBScriptSequenceList) {
//        println("Started \(scriptSequenceList.script) in object \(scriptSequenceList.script.object.name)")
        let scriptEndCompletion = { [weak self] in
            synchronized(scriptSequenceList.script, {
                if let broadcastScript = scriptSequenceList.script as? BroadcastScript {
                    // TODO: avoid concurrency conflicts between BroadcastBricks and BroadcastWaitBricks!!!
                    if broadcastScript.calledByOtherScriptBroadcastWait {
                        broadcastScript.signalForWaitingBroadcasts() // signal finished broadcast!
                    }
                }
                if scriptSequenceList.abortScriptExecutionCompletionClosure != nil {
                    // resets abort flag and aborts script execution here
                    scriptSequenceList.abortScriptExecutionCompletionClosure?()
                    scriptSequenceList.abortScriptExecutionCompletionClosure = nil
                    println("Script aborted while finishing!")
                    return
                }
                scriptSequenceList.running = false
                if scriptSequenceList.script.inParentHierarchy(scriptSequenceList.script.object) {
                    scriptSequenceList.script.removeFromParent()
                }
                println("Script finished!")
            })
        }
        scriptSequenceList.scriptExecutionClosure = _sequenceBlockForSequenceList(scriptSequenceList.sequenceList, finalCompletionBlock:scriptEndCompletion)
    }

    final private func _sequenceBlockForSequenceList(sequenceList : CBSequenceList, finalCompletionBlock : dispatch_block_t) -> dispatch_block_t {
        var completionBlock = finalCompletionBlock
        let reverseSequenceList = sequenceList.reverseSequenceList()
        for sequence in reverseSequenceList.sequenceList {
            if let operationSequence = sequence as? CBOperationSequence {
                completionBlock = _sequenceBlockForOperationSequence(operationSequence, finalCompletionBlock: completionBlock)
            } else if let ifSequence = sequence as? CBIfConditionalSequence {
                // if else sequence
                completionBlock = { [weak self] in
                    if ifSequence.checkCondition() {
                        self?._sequenceBlockForSequenceList(ifSequence.sequenceList, finalCompletionBlock: completionBlock)()
                    } else if ifSequence.elseSequenceList != nil {
                        self?._sequenceBlockForSequenceList(ifSequence.elseSequenceList!, finalCompletionBlock: completionBlock)()
                    } else {
                        completionBlock()
                    }
                }
            } else if let conditionalSequence = sequence as? CBConditionalSequence {
                // loop sequence
                completionBlock = _repeatingSequenceBlockForConditionalSequence(conditionalSequence, finalCompletionBlock: completionBlock)
            }
        }
        assert(completionBlock != nil, "This method must NEVER return nil!!")
        return completionBlock
    }

    final private func _repeatingSequenceBlockForConditionalSequence(conditionalSequence : CBConditionalSequence, finalCompletionBlock : dispatch_block_t) -> dispatch_block_t {
        let localUniqueIdentifier = NSString.localUniqueIdenfier()

        var completionBlock : dispatch_block_t = { [weak self] in
            if conditionalSequence.checkCondition() {
                let startTime = NSDate()
                let loopEndCompletionBlock = { [weak self] in
                    // high priority queue only needed for blocking purposes...
                    // the reason for this is that you should NEVER block the (serial) main_queue!!
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                        let duration = NSDate().timeIntervalSinceDate(startTime)
                        println("  Duration for Sequence: \(duration*1000)ms")
                        if duration < 0.02 {
                            NSThread.sleepForTimeInterval(0.02-duration)
                        }
                        // now switch back to the main queue for executing the sequence!
                        dispatch_async(dispatch_get_main_queue(), {
                            conditionalSequence.rootSequenceList.whileSequences[localUniqueIdentifier]?()
                        })
                    })
                }
                self?._sequenceBlockForSequenceList(conditionalSequence.sequenceList, finalCompletionBlock: loopEndCompletionBlock)()
            } else {
                conditionalSequence.resetCondition() // reset loop counter
                finalCompletionBlock()
            }
        }
        conditionalSequence.rootSequenceList.whileSequences[localUniqueIdentifier] = completionBlock
        assert(completionBlock != nil, "This method must NEVER return nil!!")
        return completionBlock
    }

    final private func _sequenceBlockForOperationSequence(operationSequence : CBOperationSequence, finalCompletionBlock : dispatch_block_t) -> dispatch_block_t {
        #if DEBUG
            let startTime = NSDate()
        #endif // DEBUG == 1
        var completionBlock = {
//            NSDebug(@"  Duration for Sequence in %@: %fms", [weakSelf class], [[NSDate date] timeIntervalSinceDate:startTime]*1000);
            finalCompletionBlock();
        }

        for operation in operationSequence.operationList.reverse() {
            if let broadcastBrick = operation.brick as? BroadcastBrick {
                // cancel all upcoming actions if BroadcastBrick calls its own script
                if let broadcastScript = broadcastBrick.script as? BroadcastScript {
                    assert(broadcastBrick.broadcastMessage == nil, "broadcastMessage in BroadcastBrick must NOT be nil")
                    assert(broadcastScript.receivedMessage == nil, "receivedMessage in BroadcastScript must NOT be nil")
                    if broadcastBrick.broadcastMessage == broadcastScript.receivedMessage {
                        // DO NOT call completionBlock here so that upcoming actions are ignored!
                        completionBlock = {
                            // end of script reached!! Scripts will be aborted due to self-calling broadcast
                            if broadcastScript.calledByOtherScriptBroadcastWait {
                                broadcastScript.signalForWaitingBroadcasts() // signal finished broadcast!
                            }
//                            NSDebug(@"BroadcastScript ended due to self broadcast!")
                            broadcastBrick.performBroadcast() // finally perform broadcast
                        }
                        continue;
                    }
                }
                completionBlock = {
                    broadcastBrick.performBroadcast()
                    completionBlock() // the script must continue here. upcoming actions are executed!!
                }
            } else if let broadcastWaitBrick = operation.brick as? BroadcastWaitBrick {
                // cancel all upcoming actions if BroadcastWaitBrick calls its own script
                if let broadcastScript = broadcastWaitBrick.script as? BroadcastScript {
                    assert(broadcastWaitBrick.broadcastMessage == nil, "broadcastMessage in BroadcastWaitBrick must NOT be nil")
                    assert(broadcastScript.receivedMessage == nil, "receivedMessage in BroadcastScript must NOT be nil")
                    if broadcastWaitBrick.broadcastMessage == broadcastScript.receivedMessage {
                        // DO NOT call completionBlock here so that upcoming actions are ignored!
                        completionBlock = {
                            // end of script reached!! Scripts will be aborted due to self-calling broadcast
                            if broadcastScript.calledByOtherScriptBroadcastWait {
                                broadcastScript.signalForWaitingBroadcasts() // signal finished broadcast!
                            }
//                            NSDebug(@"BroadcastScript ended due to self broadcastWait!");
                            // finally perform normal (!) broadcast
                            // no waiting required, since there all upcoming actions in the sequence are omitted!
                            broadcastWaitBrick.performBroadcastButDontWait()
                        }
                        continue
                    }
                }
                completionBlock = {
                    broadcastWaitBrick.performBroadcastAndWaitWithCompletion(completionBlock)
                }
            } else {
                completionBlock = {
//                    NSDebug(@"[%@] %@ action", [weakSelf class], [operation.brick class]);
                    if (operationSequence.rootSequenceList.abortScriptExecutionCompletionClosure != nil) {
                        // resets abort flag and aborts script execution here
                        operationSequence.rootSequenceList.abortScriptExecutionCompletionClosure?()
                        operationSequence.rootSequenceList.abortScriptExecutionCompletionClosure = nil
//                        NSLog(@"%@ aborted!", [weakSelf class])
                        return
                    }
                    operation.brick.script.runAction(operation.brick.action(), completion: completionBlock)
                }
            }
        }
        assert(completionBlock != nil, "This method must NEVER return nil!!")
        return completionBlock
    }
}
