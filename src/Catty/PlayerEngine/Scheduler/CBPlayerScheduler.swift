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

protocol CBPlayerSchedulingAlgorithm {
    // param: lastScript (nilable)
    // param: scriptExecContextDict is a non empty list!
    func scriptExecContextForNextInstruction(lastScript: Script?,
        scriptExecContextDict: [Script:CBScriptExecContext]) -> CBScriptExecContext
}

final class CBPlayerScheduler : NSObject {

    // MARK: - Constants
    // specifies max depth limit for self broadcasts running on the same function stack
    let selfBroadcastRecursionMaxDepthLimit = 20

    // MARK: - Properties
    var logger : CBLogger
    private let _frontend : CBPlayerFrontend
    private let _backend : CBPlayerBackend
    private(set) var running = false
    private(set) lazy var scriptExecContextDict = [Script:CBScriptExecContext]()
    var schedulingAlgorithm : CBPlayerSchedulingAlgorithm?
    private weak var _currentScriptExecContext : CBScriptExecContext?
    private lazy var _registeredBroadcastScripts = [String:[BroadcastScript]]()
    private lazy var _selfBroadcastCounters = [String:Int]()

    // MARK: - Initializers
    init(logger: CBLogger, frontend: CBPlayerFrontend, backend: CBPlayerBackend) {
        self.logger = logger
        _frontend = frontend
        _backend = backend
    }

    // MARK: - Getters and Setters
    func isScriptRunning(script: Script) -> Bool {
        if let _ = scriptExecContextDict[script] {
            return true
        }
        return false
    }

    // MARK: - Operations
    private func _resetScript(script: Script) {
        logger.debug("!!! RESETTING: \(script)");
        logger.debug("-------------------------------------------------------------")
        for brick in script.brickList {
            if let loopBeginBrick = brick as? LoopBeginBrick {
                loopBeginBrick.resetCondition()
            }
        }
    }

    func addScriptExecContext(scriptExecContext: CBScriptExecContext) {
        assert(scriptExecContextDict[scriptExecContext.script] == nil, "Context already in dictionary!")
        logger.info("Added new CBScriptExecContext for \(scriptExecContext.script)")
        scriptExecContextDict[scriptExecContext.script] = scriptExecContext
    }

    func addInstructionAfterCurrentInstructionOfScript(script: Script, instruction: CBExecClosure) {
        if let scriptExecContext = scriptExecContextDict[script] {
            scriptExecContext.addInstructionAtCurrentPosition(instruction)
        }
    }

    func addInstructionsAfterCurrentInstructionOfScript(script: Script, instructionList: [CBExecClosure]) {
        for instruction in instructionList {
            addInstructionAfterCurrentInstructionOfScript(script, instruction: instruction)
        }
    }

    func removeInstructionsBeforeCurrentInstruction(#numberOfInstructions: Int, inScript script: Script) {
        if let scriptExecContext = scriptExecContextDict[script] {
            scriptExecContext.removeNumberOfInstructionsBeforeCurrentInstruction(numberOfInstructions)
        }
    }

    func subscribeBroadcastScript(broadcastScript: BroadcastScript, forMessage message: String) {
        if var broadcastScripts = _registeredBroadcastScripts[message] {
            assert(contains(broadcastScripts, broadcastScript) == false, "FATAL: BroadcastScript already registered!")
            broadcastScripts += broadcastScript
        } else {
            _registeredBroadcastScripts[message] = [broadcastScript]
        }
        logger.info("Subscribed new BroadcastScript of object \(broadcastScript.object.name) " +
                    "for message \(message)")
    }

    func unsubscribeBroadcastScript(broadcastScript: BroadcastScript, forMessage message: String) {
        if var broadcastScripts = _registeredBroadcastScripts[message] {
            var index = 0
            for script in broadcastScripts {
                if script === broadcastScript {
                    broadcastScripts.removeAtIndex(index)
                    logger.info("Unsubscribed BroadcastScript of object \(broadcastScript.object.name) " +
                                "for message \(message)")
                    return
                }
                ++index
            }
        }
        fatalError("FATAL: Given BroadcastScript is NOT registered!")
    }

    func runNextInstructionOfScript(script: Script) {
        if scriptExecContextDict.count == 0 { return }
        if schedulingAlgorithm != nil {
            let newScriptExecContext = schedulingAlgorithm?.scriptExecContextForNextInstruction(
                _currentScriptExecContext?.script,
                scriptExecContextDict: scriptExecContextDict
            )
            _currentScriptExecContext = newScriptExecContext
        } else {
            _currentScriptExecContext = scriptExecContextDict[script]
        }

        if let scriptExecContext = _currentScriptExecContext {
            if let nextInstruction = scriptExecContext.nextInstruction() {
                nextInstruction()
            } else {
                logger.debug("All actions/instructions have been finished!")
                stopScript(script)
            }
        } else {
            // TODO: review!!
            logger.debug("Script already removed from scheduler!")
            logger.debug("Force stopping script now!")
            stopScript(script)
        }
    }

    func run() {
        logger.info("")
        logger.info("#############################################################")
        logger.info("")
        logger.info(" => SCHEDULER STARTED")
        logger.info("")
        logger.info("#############################################################\n\n")
        running = true

        for (script, _) in scriptExecContextDict {
            startScript(script)
        }
    }

    func startScript(script: Script) {
        assert(running) // ensure that player is running!
        if let scriptExecContext = scriptExecContextDict[script] {
            logger.info("    STARTING: \(script)")
            logger.info("-------------------------------------------------------------")

            if scriptExecContext.inParentHierarchy(scriptExecContext.script.object) == false {
                //            NSLog(@" + Adding this node to object");
                scriptExecContext.script.object.addChild(scriptExecContext)
            }
            _resetScript(script)

            if scriptExecContext.hasActions() {
                scriptExecContext.removeAllActions()
            }
            runNextInstructionOfScript(script) // Ready...Steady...Gooooo!! => invoke first instruction!
            return
        }
        // make sure that context has already been added to Scheduler
        fatalError("Unable to start script! ScriptExecContext not added to scheduler. This should NEVER happen!!")
    }

    func restartScript(script: Script) {
        assert(running) // make sure that player is running!
        if let scriptExecContext = scriptExecContextDict[script] {
            stopScript(script, removeReferences:false)
            scriptExecContext.reset()
            addScriptExecContext(scriptExecContext)
            startScript(script)
        } else {
//            let sequenceList = frontend.computeSequenceListForScript(script)
//            let scriptExecContext = CBPlayerBackend().executionContextForScriptSequenceList(sequenceList)
//            addScriptExecContext(scriptExecContext)
//            startScript(script)
            fatalError("Script is not running!")
        }
    }

    func stopScript(script: Script, removeReferences: Bool = true) {
        logger.info("!!! STOPPING: \(script)")
        logger.info("-------------------------------------------------------------")
        if let scriptExecContext = scriptExecContextDict[script] {
            if removeReferences {
                scriptExecContext.removeReferences()
            }
            if scriptExecContext.inParentHierarchy(script.object) {
                scriptExecContext.removeFromParent()
            }
            scriptExecContext.removeAllActions()
            scriptExecContextDict.removeValueForKey(script)
            logger.debug("\(script) finished!")
            return
        }
        logger.debug("\(script) already stopped!!")
    }

    func shutdown() {
        logger.info("")
        logger.info("#############################################################")
        logger.info("")
        logger.info("!!! SCHEDULER SHUTDOWN")
        logger.info("")
        logger.info("#############################################################\n\n")
        for (script, scriptExecContext) in scriptExecContextDict {
            logger.info("!!! STOPPING: \(script)")
            logger.info("-------------------------------------------------------------")
            if scriptExecContext.inParentHierarchy(script.object) {
                scriptExecContext.removeFromParent()
            }
            scriptExecContext.removeReferences()
            logger.debug("\(script) finished!")
        }
        scriptExecContextDict.removeAll(keepCapacity: false)
        running = false
        _currentScriptExecContext = nil
    }

    // MARK: - Broadcast handling
    func performBroadcastWithMessage(message: String, senderScript:Script) {

        logger.info("Broadcast: \(message)")
        var runNextInstructionOfSenderScript = true

        if let broadcastScripts = _registeredBroadcastScripts[message] {
            for broadcastScript in broadcastScripts {
                // case broadcastScript == senderScript => restart script
                if broadcastScript === senderScript {
                    // if sender script stopped in the meanwhile => do NOT restart and abort this broadcast!
                    if isScriptRunning(broadcastScript) == false {
                        return;
                    }
                    broadcastScript.calledByOtherScriptBroadcastWait = false // no synchronization needed here
                    var counter = 0
                    if let counterNumber = _selfBroadcastCounters[message] {
                        counter = counterNumber
                    }
                    if ++counter % selfBroadcastRecursionMaxDepthLimit == 0 { // XXX: DIRTY PERFORMANCE HACK!!
                        dispatch_async(dispatch_get_main_queue(), { [weak self] in
                            self?.restartScript(broadcastScript) // restart this self-listening BroadcastScript
                        })
                    } else {
                        restartScript(broadcastScript)
                    }
                    _selfBroadcastCounters[message] = counter

                    // end of script reached!! Scripts will be aborted due to self-calling broadcast
                    // the final closure will never be called (except when script is canceled!) due
                    // to self-broadcast
                    runNextInstructionOfSenderScript = false // still enqueued next actions are ignored due to restart!
                    logger.debug("BROADCASTSCRIPT HAS BEEN RESTARTED DUE TO SELF-BROADCAST!!")
                    continue
                }

                // case broadcastScript != senderScript
                broadcastScript.calledByOtherScriptBroadcastWait = false
                if isScriptRunning(broadcastScript) == false {
                    // case broadcastScript is not running
                    let sequenceList = _frontend.computeSequenceListForScript(broadcastScript)
                    addScriptExecContext(_backend.executionContextForScriptSequenceList(sequenceList))
                    startScript(broadcastScript)
                } else {
                    // case broadcastScript is running
                    if broadcastScript.calledByOtherScriptBroadcastWait {
                        broadcastScript.signalForWaitingBroadcasts() // signal finished broadcast!
                    }
                    restartScript(broadcastScript) // trigger script to restart
                }
            }
        }
        if (runNextInstructionOfSenderScript) {
            // the script must continue here. upcoming actions are executed!!
            runNextInstructionOfScript(senderScript)
        }
    }

    //- (void)broadcastAndWait:(NSString*)message senderScript:(Script*)script
    //{
    //    NSDebug(@"BroadcastWait: %@", message);
    //    CBPlayerScheduler *scheduler = [CBPlayerScheduler sharedInstance];
    //    CBPlayerFrontend *frontend = [CBPlayerFrontend new];
    //    CBPlayerBackend *backend = [CBPlayerBackend new];
    //    for (NSString *spriteObjectName in self.spriteObjectBroadcastScripts) {
    //        NSArray *broadcastScriptList = self.spriteObjectBroadcastScripts[spriteObjectName];
    //        for (BroadcastScript *broadcastScript in broadcastScriptList) {
    //            if (! [broadcastScript.receivedMessage isEqualToString:message]) {
    //                continue;
    //            }
    //
    //            dispatch_semaphore_t semaphore = self.broadcastMessageSemaphores[broadcastScript.receivedMessage];
    //            if (! semaphore) {
    //                semaphore = dispatch_semaphore_create(0);
    //                self.broadcastMessageSemaphores[broadcastScript.receivedMessage] = semaphore;
    //            }
    //
    //            // case sender script equals receiver script => restart receiver script
    //            // (sets brick action instruction pointer to zero)
    //            if (broadcastScript == script) {
    //                if (! [scheduler isScriptRunning:broadcastScript]) {
    //                    if (self.broadcastMessageSemaphores[broadcastScript.receivedMessage]) {
    //                        dispatch_semaphore_signal(self.broadcastMessageSemaphores[broadcastScript.receivedMessage]);
    //                    }
    //                    return;
    //                }
    //                broadcastScript.calledByOtherScriptBroadcastWait = NO; // no synchronization required here
    //                NSNumber *counterNumber = self.broadcastScriptCounters[message];
    //                NSUInteger counter = 0;
    //                if (counterNumber) {
    //                    counter = [counterNumber integerValue];
    //                }
    //                if (++counter % 12) { // XXX: DIRTY HACK!!
    //                    [scheduler restartScript:broadcastScript];
    //                } else {
    //                    dispatch_async(dispatch_get_main_queue(), ^{
    //                        [scheduler restartScript:broadcastScript]; // restart this self-listening BroadcastScript
    //                    });
    //                }
    //                self.broadcastScriptCounters[message] = @(counter);
    //                continue;
    //            }
    //
    //            // case sender script does not equal receiver script => check if receiver script
    //            // if broadcastScript is not running then start broadcastScript!
    //            broadcastScript.calledByOtherScriptBroadcastWait = YES; // synchronized!
    //            if (! [scheduler isScriptRunning:broadcastScript]) {
    //                // broadcastScript != senderScript
    //                CBScriptSequenceList *sequenceList = [frontend computeSequenceListForScript:broadcastScript];
    //                [scheduler addScriptExecContext:[backend executionContextForScriptSequenceList:sequenceList]];
    //                [scheduler startScript:broadcastScript];
    //            } else {
    //                // case broadcast script is already running!
    //                if (broadcastScript.isCalledByOtherScriptBroadcastWait) {
    //                    dispatch_semaphore_signal(semaphore); // signal finished broadcast!
    //                }
    //                [scheduler restartScript:broadcastScript]; // trigger script to restart
    //            }
    //        }
    //    }
    //}

}
