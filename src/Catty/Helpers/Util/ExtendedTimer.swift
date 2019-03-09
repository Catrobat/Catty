/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

import Foundation

final class ExtendedTimer: Hashable {

    var timer: Timer?
    let block: ((ExtendedTimer) -> Void)?
    var pauseDate: Date?
    var fireDateBeforePausing: Date?

    var isValid: Bool {
        return self.timer?.isValid ?? false
    }
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }

    init(timeInterval: TimeInterval, repeats: Bool, execOnCurrentRunLoop: Bool, block: @escaping (ExtendedTimer) -> Void) {
        if #available(iOS 10.0, *) {
            self.block = nil
            self.timer = Timer.init(timeInterval: timeInterval, repeats: repeats) { _ in
                block(self)
            }
        } else {
            self.timer = nil
            self.block = block
            self.timer = Timer.init(timeInterval: timeInterval, target: self, selector: #selector(fire(timer:)), userInfo: nil, repeats: repeats)
        }
        if execOnCurrentRunLoop {
            RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.default)
        } else {
            RunLoop.main.add(self.timer!, forMode: RunLoop.Mode.default)
        }
    }

    @objc func fire(timer: Timer) {
        self.block?(self)
    }

    func invalidate() {
        self.timer?.invalidate()
        self.timer = nil
    }

    func pause() {
        fireDateBeforePausing = timer?.fireDate
        pauseDate = Date()
        timer?.fireDate = Date.distantFuture
    }

    func resume() {
        if let pauseDate = pauseDate, let fireDateBeforePausing = fireDateBeforePausing {
            let pauseTime = -pauseDate.timeIntervalSinceNow
            timer?.fireDate = Date(timeInterval: pauseTime, since: fireDateBeforePausing)
        } else {
            timer?.fire()
        }
    }

    static func == (lhs: ExtendedTimer, rhs: ExtendedTimer) -> Bool {
        return lhs === rhs
    }
}
