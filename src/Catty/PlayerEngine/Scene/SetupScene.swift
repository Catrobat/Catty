/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

// ATTENTION: this intermediate class is subject to be removed after ScenePresenterVC has been
//            ported to Swift.
//            This class is needed to take advantage of Swift's static dispatching concept
//            used by several player engine components (Scheduler, BroadcastHandler, etc.).

final class SetupScene: NSObject {

    static func setupSceneForProgram(program: Program) -> CBScene {

        let sceneLogger = Swell.getLogger(LoggerConfig.PlayerSceneID)
        let schedulerLogger = Swell.getLogger(LoggerConfig.PlayerSchedulerID)
        let frontendLogger = Swell.getLogger(LoggerConfig.PlayerFrontendID)
        let backendLogger = Swell.getLogger(LoggerConfig.PlayerBackendID)
        let bcHandlerLogger = Swell.getLogger(LoggerConfig.PlayerBroadcastHandlerID)

        let bcHandler = CBBroadcastHandler(logger: bcHandlerLogger)
        let scheduler = CBScheduler(logger: schedulerLogger, broadcastHandler: bcHandler)
        bcHandler.scheduler = scheduler
        let frontend = CBFrontend(logger: frontendLogger, program: program)
        frontend.addSequenceFilter(CBFilterRedundantBroadcastWaits())
        let backend = CBBackend(logger: backendLogger) // setup backend

        let programSize = CGSizeMake(
            CGFloat(program.header.screenWidth.floatValue),
            CGFloat(program.header.screenHeight.floatValue)
        )

        return CBScene(
            size: programSize,
            logger: sceneLogger,
            scheduler: scheduler,
            frontend: frontend,
            backend: backend,
            broadcastHandler: bcHandler
        )
    }

}
