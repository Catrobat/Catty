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

class LibraryImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.layer.borderWidth = CGFloat(kDefaultImageCellBorderWidth)
        self.imageView.layer.borderColor = UIColor.utilityTint().cgColor
    }
}

extension LibraryImageCollectionViewCell {
    enum State {
        case noImage
        case loading
        case loaded(image: UIImage)
        // a failed state could be added in order to support retry
    }

    var state: State {
        get {
            if self.activityIndicator.isAnimating {
                return .loading
            } else if let image = self.imageView.image {
                return .loaded(image: image)
            } else {
                return .noImage
            }
        }
        set {
            switch newValue {
            case .loaded(let image):
                self.activityIndicator.stopAnimating()
                self.imageView.image = image
            case .loading:
                self.activityIndicator.startAnimating()
                self.imageView.image = nil
            case .noImage:
                self.activityIndicator.stopAnimating()
                self.imageView.image = nil
            }
        }
    }
}
