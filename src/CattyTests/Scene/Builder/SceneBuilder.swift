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

@testable import Pocket_Code

final class CBSceneMock: CBScene {

    init(size: CGSize) {
        let logger = CBLogger(name: "CBSceneMockLogger")
        let broadcastHandler = CBBroadcastHandler(logger: logger)
        let formulaManager = FormulaManager()
        let scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler, formulaInterpreter: formulaManager)
        scheduler.running = true
        super(size: size, logger: logger, scheduler: scheduler,
        frontend: CBFrontend(logger: logger, program: nil), backend: CBBackend(logger: logger),
        broadcastHandler: broadcastHandler, formulaManager: formulaManager)
    }
}
