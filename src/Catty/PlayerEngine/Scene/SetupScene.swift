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

// ATTENTION: this class is subject to be removed soon. => better Swift-Objective-C compatibility

@objc final class SetupScene {

    static func setupSceneForProgram(program: Program) -> CBPlayerScene {
        // create all player loggers
        let sceneLogger = Swell.getLogger(LoggerConfig.PlayerSceneID)
        let schedulerLogger = Swell.getLogger(LoggerConfig.PlayerSchedulerID)
        let frontendLogger = Swell.getLogger(LoggerConfig.PlayerFrontendID)
        let backendLogger = Swell.getLogger(LoggerConfig.PlayerBackendID)
        let bcHandlerLogger = Swell.getLogger(LoggerConfig.PlayerBroadcastHandlerID)

        // setup broadcast handler
        let bcHandler = CBPlayerBroadcastHandler(logger: bcHandlerLogger)

        // setup scheduler
        let scheduler = CBPlayerScheduler(logger: schedulerLogger, broadcastHandler: bcHandler)
        scheduler.schedulingAlgorithm = nil // default scheduling algorithm!
//        scheduler.schedulingAlgorithm = CBPlayerSchedulingAlgorithmLoadBalancing()
        bcHandler.scheduler = scheduler

        // setup frontend
        let frontend = CBPlayerFrontend(logger: frontendLogger, program: program)
        frontend.addSequenceFilter(CBPlayerFilterRedundantBroadcastWaits())

        // setup backend
        let backend = CBPlayerBackend(logger: backendLogger, scheduler: scheduler, broadcastHandler: bcHandler)

        // finally create scene
        let programSize = CGSizeMake(CGFloat(program.header.screenWidth.floatValue),
            CGFloat(program.header.screenHeight.floatValue))
        return CBPlayerScene(size: programSize, logger: sceneLogger, scheduler: scheduler,
            frontend: frontend, backend: backend, broadcastHandler: bcHandler)
    }

}
