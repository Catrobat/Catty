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

class IntroductionViewController: UIViewController {

    @IBOutlet private weak var headline: UILabel!
    @IBOutlet private weak var paragraph: UILabel!
    @IBOutlet private weak var image: UIImageView!

    @IBOutlet private var dismissButton: UIButton!

    @IBAction private func touchDismiss(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        IntroductionPageViewController.hasBeenShown = true
    }

    var content: Content?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear

        self.headline.text = self.content?.title
        self.paragraph.text = self.content?.description
        self.image.image = self.content?.image
        self.dismissButton.isHidden = self.content == nil
    }
}

extension IntroductionViewController {
    struct Content {
        var title: String
        var description: String
        var image: UIImage
    }
}
