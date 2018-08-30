/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

@objc final class SceneBuilder: NSObject {
    
    private var program: Program
    private var scheduler: CBSchedulerProtocol
    private var frontend: CBFrontendProtocol
    private var backend: CBBackendProtocol
    private var broadcastHandler: CBBroadcastHandler
    private var formulaManager: FormulaManagerProtocol
    private var logger: CBLogger
    private var size: CGSize
    
    @objc init(program: Program) {
        self.program = program
        
        guard
            let sceneLogger = Swell.getLogger(LoggerConfig.PlayerSceneID),
            let schedulerLogger = Swell.getLogger(LoggerConfig.PlayerSchedulerID),
            let frontendLogger = Swell.getLogger(LoggerConfig.PlayerFrontendID),
            let backendLogger = Swell.getLogger(LoggerConfig.PlayerBackendID),
            let bcHandlerLogger = Swell.getLogger(LoggerConfig.PlayerBroadcastHandlerID)
            else { preconditionFailure() }
        
        self.logger = sceneLogger
        self.formulaManager = FormulaManager()
        self.broadcastHandler = CBBroadcastHandler(logger: bcHandlerLogger)
        
        self.scheduler = CBScheduler(logger: schedulerLogger, broadcastHandler: broadcastHandler, formulaInterpreter: formulaManager)
        broadcastHandler.scheduler = scheduler
        
        self.frontend = CBFrontend(logger: frontendLogger, program: program)
        frontend.addSequenceFilter(CBFilterRedundantBroadcastWaits())
        
        self.backend = CBBackend(logger: backendLogger) // setup backend
        
        self.size = CGSize(
            width: CGFloat(program.header.screenWidth.floatValue),
            height: CGFloat(program.header.screenHeight.floatValue)
        )
    }
    
    func withScheduler(scheduler: CBSchedulerProtocol) -> Self {
        self.scheduler = scheduler
        return self
    }
    
    func withFrontend(frontend: CBFrontendProtocol) -> Self {
        self.frontend = frontend
        return self
    }
    
    func withBackend(backend: CBBackendProtocol) -> Self {
        self.backend = backend
        return self
    }
    
    func withBroadcastHandler(broadcastHandler: CBBroadcastHandler) -> Self {
        self.broadcastHandler = broadcastHandler
        return self
    }
    
    func withFormulaManager(formulaManager: FormulaManagerProtocol) -> Self {
        self.formulaManager = formulaManager
        return self
    }
    
    @objc func withSize(size: CGSize) -> Self {
        self.size = size
        return self
    }
    
    @objc func build() -> CBScene {
        return CBScene(size: size, logger: logger, scheduler: scheduler, frontend: frontend, backend: backend, broadcastHandler: broadcastHandler, formulaManager: formulaManager)
    }
}
