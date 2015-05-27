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

@objc protocol CBPlayerBroadcastHandlerProtocol {
    func setupHandler()
    func subscribeBroadcastScript(broadcastScript: BroadcastScript, forMessage message: String)
    func unsubscribeBroadcastScript(broadcastScript: BroadcastScript, forMessage message: String)
    func performBroadcastWithMessage(message: String, senderScript:Script)
}

final class CBPlayerBroadcastHandler : NSObject, CBPlayerBroadcastHandlerProtocol {

    // MARK: - Constants
    // specifies max depth limit for self broadcasts running on the same function stack
    let selfBroadcastRecursionMaxDepthLimit = 20

    // MARK: - Properties
    var logger : CBLogger
    let frontend : CBPlayerFrontendProtocol
    let backend : CBPlayerBackendProtocol
    weak var scheduler : CBPlayerSchedulerProtocol?
    private lazy var _registeredBroadcastScripts = [String:[BroadcastScript]]()
    private lazy var _broadcastStartQueueBuffer = [CBBroadcastQueueElement]()
    private lazy var _selfBroadcastCounters = [String:Int]()

    // MARK: - Initializers
    init(logger: CBLogger, frontend: CBPlayerFrontendProtocol, backend: CBPlayerBackendProtocol,
        scheduler: CBPlayerSchedulerProtocol?)
    {
        self.logger = logger
        self.scheduler = scheduler
        self.frontend = frontend
        self.backend = backend
    }

    convenience init(logger: CBLogger, frontend: CBPlayerFrontendProtocol, backend: CBPlayerBackendProtocol) {
        self.init(logger: logger, frontend: frontend, backend: backend, scheduler: nil)
    }

    // MARK: - Operations
    func setupHandler() {
        // setup broadcast start queue handler
        let broadcastQueue = dispatch_queue_create("org.catrobat.broadcastStart.queue", DISPATCH_QUEUE_CONCURRENT)
        dispatch_async(broadcastQueue, { [weak self] in
            while self?._allStartScriptsReachedMatureState() == false {
                NSThread.sleepForTimeInterval(0.1)
            }

            // if mature state reached => perform all already enqueued broadcasts
            dispatch_async(dispatch_get_main_queue(), { [weak self] in
                if self?._broadcastStartQueueBuffer.count > 0 {
                    if self?._allStartScriptsReachedMatureState() == true {
                        if let broadcastStartQueueBuffer = self?._broadcastStartQueueBuffer {
                            for (message, senderScript) in broadcastStartQueueBuffer {
                                self?.performBroadcastWithMessage(message, senderScript: senderScript)
                            }
                            self?._broadcastStartQueueBuffer.removeAll(keepCapacity: false)
                        }
                    }
                }
            })
        })
        // start all StartScripts
        _broadcastStartQueueBuffer.removeAll()
    }

    func subscribeBroadcastScript(broadcastScript: BroadcastScript, forMessage message: String) {
        if var broadcastScripts = _registeredBroadcastScripts[message] {
            assert(contains(broadcastScripts, broadcastScript) == false, "FATAL: BroadcastScript already registered!")
            broadcastScripts += broadcastScript
            _registeredBroadcastScripts[message] = broadcastScripts
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

    // MARK: - Broadcast Handling
    private func _allStartScriptsReachedMatureState() -> Bool {
        if let scriptExecContextDict = scheduler?.scriptExecContextDict {
            for (script, scriptExecContext) in scriptExecContextDict {
                if let startScript = script as? StartScript {
                    if (scriptExecContext.state != .RunningMature) && (scriptExecContext.state != .Dead) {
                        return false
                    }
                }
            }
            return true
        }
        return false
    }

    func performBroadcastWithMessage(message: String, senderScript:Script) {
        if let senderScriptExecContext = scheduler?.scriptExecContextDict[senderScript] {
            senderScriptExecContext.state = .RunningMature
        }
        if _allStartScriptsReachedMatureState() == false {
            logger.info("Enqueuing broadcast: \(message)")
            _broadcastStartQueueBuffer += (message, senderScript)
            return
        }

        logger.info("Performing broadcast: \(message)")
        var runNextInstructionOfSenderScript = true

        if let broadcastScripts = _registeredBroadcastScripts[message] {
            for broadcastScript in broadcastScripts {
                // case broadcastScript == senderScript => restart script
                if broadcastScript === senderScript {
                    // if sender script stopped in the mean while => do NOT restart and abort this broadcast!
                    if scheduler?.isScriptScheduled(broadcastScript) == false {
                        return;
                    }
                    broadcastScript.calledByOtherScriptBroadcastWait = false // no synchronization needed here
                    var counter = 0
                    if let counterNumber = _selfBroadcastCounters[message] {
                        counter = counterNumber
                    }
                    if ++counter % selfBroadcastRecursionMaxDepthLimit == 0 { // XXX: DIRTY PERFORMANCE HACK!!
                        dispatch_async(dispatch_get_main_queue(), { [weak self] in
                            self?.scheduler?.restartScript(broadcastScript) // restart this self-listening BroadcastScript
                        })
                    } else {
                        scheduler?.restartScript(broadcastScript)
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
                if scheduler?.isScriptScheduled(broadcastScript) == false {
                    // case broadcastScript is not running
                    let sequenceList = frontend.computeSequenceListForScript(broadcastScript)
                    if let senderScriptExecContext = scheduler?.scriptExecContextDict[senderScript],
                       let scene = senderScriptExecContext.scene,
                       let spriteNode = CBSpriteNode.spriteNodeWithName(broadcastScript.object.name, inScene: scene)
                    {
                        scheduler?.addScriptExecContext(backend.executionContextForScriptSequenceList(sequenceList, spriteNode: spriteNode))
                        scheduler?.startScript(broadcastScript)
                    }
                } else {
                    // FIXME: START ANOTHER BROADCAST SCRIPT INSTANCE!!
                    // case broadcastScript is running
                    if broadcastScript.calledByOtherScriptBroadcastWait {
                        broadcastScript.signalForWaitingBroadcasts() // signal finished broadcast!
                    }
                    scheduler?.restartScript(broadcastScript) // trigger script to restart
                }
            }
        }
        if (runNextInstructionOfSenderScript) {
            // the script must continue here. upcoming actions are executed!!
            scheduler?.runNextInstructionOfScript(senderScript)
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

//    - (void)performBroadcastAndWaitWithScheduler:(CBPlayerScheduler*)scheduler
//    {
//    NSDebug(@"Performing: %@", self.description);
//    //    [self.script.object.program broadcastAndWait:self.broadcastMessage senderScript:self.script];
//    __weak BroadcastWaitBrick *weakSelf = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//    // wait here on other queue!!
//    //        [weakSelf.script.object.program waitingForBroadcastWithMessage:weakSelf.broadcastMessage];
//    // now switch back to the main queue for executing the sequence!
//    dispatch_async(dispatch_get_main_queue(), ^{
//    // the script must continue here. upcoming actions are executed!!
//    //            [scheduler runNextInstructionOfScript:weakSelf.script];
//    });
//    });
//    }
//
//    #pragma mark - broadcasting handling
//    - (void)setupBroadcastHandling
//    {
//    // reset all lazy (!) instantiated objects
//    self.broadcastWaitHandler = nil;
//    self.spriteObjectBroadcastScripts = nil;
//    
//    for (SpriteObject *spriteObject in self.objectList) {
//    NSMutableArray *broadcastScripts = [NSMutableArray array];
//    for (Script *script in spriteObject.scriptList) {
//    if (! [script isKindOfClass:[BroadcastScript class]]) {
//    continue;
//    }
//    
//    BroadcastScript *broadcastScript = (BroadcastScript*)script;
//    [self.broadcastWaitHandler registerSprite:spriteObject forMessage:broadcastScript.receivedMessage];
//    [broadcastScripts addObject:broadcastScript];
//    }
//    [self.spriteObjectBroadcastScripts setObject:broadcastScripts forKey:spriteObject.name];
//    }
//    }
//    
//    #warning !! REMOVE THIS LATER !!
//    - (void)signalForWaitingBroadcastWithMessage:(NSString*)message
//    {
//    dispatch_semaphore_t semaphore = self.broadcastMessageSemaphores[message];
//    assert(semaphore);
//    dispatch_semaphore_signal(semaphore);
//    }
//    
//    - (void)waitingForBroadcastWithMessage:(NSString*)message
//    {
//    dispatch_semaphore_t semaphore = self.broadcastMessageSemaphores[message];
//    // FIXME: workaround for synchronization issue
//    if (! semaphore) {
//    semaphore = dispatch_semaphore_create(0);
//    self.broadcastMessageSemaphores[message] = semaphore;
//    }
//    assert(semaphore);
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//    }


}
