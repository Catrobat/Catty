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

final class TimerWithBlock {
    var timer: Timer?
    let block: ((TimerWithBlock) -> Void)?

    var isValid: Bool {
        return self.timer?.isValid ?? false
    }

    init(timeInterval: TimeInterval, repeats: Bool, block: @escaping (TimerWithBlock) -> Void) {
        if #available(iOS 10.0, *) {
            self.block = nil
            self.timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats) { _ in
                block(self)
            }
        } else {
            self.timer = nil
            self.block = block
            self.timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(fire(timer:)), userInfo: nil, repeats: repeats)
        }
    }

    @objc func fire(timer: Timer) {
        self.block?(self)
    }

    func invalidate() {
        self.timer?.invalidate()
        self.timer = nil
    }
}
