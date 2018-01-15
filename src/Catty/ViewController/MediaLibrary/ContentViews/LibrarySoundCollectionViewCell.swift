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

protocol LibrarySoundCollectionViewCellDelegate: class {
    func soundLibraryItemCollectionViewCellDidTapPlayOrStop(_ cell: LibrarySoundCollectionViewCell)
}

class LibrarySoundCollectionViewCell: UICollectionViewCell {

    weak var delegate: LibrarySoundCollectionViewCellDelegate?

    @IBOutlet private weak var playOrStopButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.textColor = .utilityTint()
    }

    @IBAction func playOrStop() {
        self.delegate?.soundLibraryItemCollectionViewCellDidTapPlayOrStop(self)
    }
}

extension LibrarySoundCollectionViewCell {
    enum State {
        case stopped
        case preparing
        case playing
    }

    var state: State {
        get {
            if !self.playOrStopButton.isSelected {
                return .stopped
            } else  if self.titleLabel.isHidden {
                return .preparing
            } else {
                return .playing
            }
        }
        set {
            switch newValue {
            case .playing:
                self.playOrStopButton.isSelected = true
                self.activityIndicator.stopAnimating()
                self.titleLabel.isHidden = false
            case .preparing:
                self.playOrStopButton.isSelected = true
                self.activityIndicator.startAnimating()
                self.titleLabel.isHidden = true
            case .stopped:
                self.playOrStopButton.isSelected = false
                self.activityIndicator.stopAnimating()
                self.titleLabel.isHidden = false
            }
        }
    }

    var title: String? {
        get {
            return self.titleLabel.text
        }
        set {
            self.titleLabel.text = newValue
        }
    }
}
