/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

protocol UploadCategoryViewControllerDelegate: AnyObject {
    func categoriesSelected(tags: [StoreProjectTag])
}

class UploadCategoryViewController: UIViewController {
    var tagIDString: String?
    weak var delegate: UploadCategoryViewControllerDelegate?

    private let horizontalConstrainValue: CGFloat = 25.0
    private let verticalConstrainValue: CGFloat = 0.0
    private let eachElementEstimatedHight: CGFloat = 40
    private var selectedCategoryTag: [Int]
    private let categories: [StoreProjectTag]
    private var backgroundViewHeight: CGFloat

    private var categoryElementViews: [UIView]
    private let backgroundView: UIView
    private let scrollView: UIScrollView

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.background
        if let tagIDString = tagIDString {
            selectedCategoryTag += StoreProjectTag.indices(with: tagIDString, from: categories)
        }

        self.initCategoriesElements()
        self.initSelectCategoriesDescription()
        navigationItem.title = kLocalizedSelectCategories
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.initScrollView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        var selectedCategories = [StoreProjectTag]()
         for tag in selectedCategoryTag {
            selectedCategories.append(self.categories[tag])
        }
        self.sendBack(selectedCategories: selectedCategories)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(tags: [StoreProjectTag]) {
        categoryElementViews = [UIView]()
        selectedCategoryTag = [Int]()
        backgroundView = UIView()
        backgroundViewHeight = 30.0
        scrollView = UIScrollView(frame: .zero)
        categories = tags
        super.init(nibName: nil, bundle: nil)
    }

    func initScrollView() {
        let contentViewSize = CGSize(width: self.view.frame.width, height: backgroundViewHeight)
        backgroundView.frame.size = contentViewSize

        scrollView.contentSize = contentViewSize
        scrollView.frame = view.bounds
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false

        if !view.subviews.contains(scrollView) {
            view.addSubview(scrollView)
            scrollView.addSubview(backgroundView)
        }
    }

    func initCategoriesElements() {
        var lastSeperationView = addLineViewElement(withTopConstraint: 30, fromElement: self.backgroundView)

        for tag in 0..<categories.count {
            let elemetView = UIView()
            elemetView.tag = tag
            elemetView.isUserInteractionEnabled = true
            let categoryTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCategoryAction(_:)))
            elemetView.addGestureRecognizer(categoryTapGesture)
            categoryElementViews.append(elemetView)
            self.backgroundView.addSubview(elemetView)

            elemetView.translatesAutoresizingMaskIntoConstraints = false
            elemetView.topAnchor.constraint(equalTo: lastSeperationView.bottomAnchor, constant: verticalConstrainValue).isActive = true
            elemetView.leftAnchor.constraint(equalTo: self.backgroundView.leftAnchor, constant: 0).isActive = true
            elemetView.rightAnchor.constraint(equalTo: self.backgroundView.rightAnchor, constant: 0).isActive = true

            let categoryLabel = UILabel()
            categoryLabel.text = categories[tag].text
            categoryLabel.font = .systemFont(ofSize: 16.0)
            elemetView.addSubview(categoryLabel)

            categoryLabel.translatesAutoresizingMaskIntoConstraints = false
            categoryLabel.topAnchor.constraint(equalTo: elemetView.topAnchor, constant: 10).isActive = true
            categoryLabel.leftAnchor.constraint(equalTo: elemetView.leftAnchor, constant: horizontalConstrainValue).isActive = true
            categoryLabel.bottomAnchor.constraint(equalTo: elemetView.bottomAnchor, constant: -10).isActive = true

            var selectedImageView = UIView()
            if let  checkImage = UIImage(named: "checkmark") {
                selectedImageView = UIImageView(image: checkImage)
            }
            selectedImageView.contentMode = .scaleAspectFit
            selectedImageView.tintColor = UIColor.globalTint
            selectedImageView.tintAdjustmentMode = .normal
            if selectedCategoryTag.contains(tag) {
                selectedImageView.isHidden = false
            } else {
                selectedImageView.isHidden = true
            }
            elemetView.addSubview(selectedImageView)

            selectedImageView.translatesAutoresizingMaskIntoConstraints = false
            selectedImageView.heightAnchor.constraint(equalToConstant: 12).isActive = true
            selectedImageView.widthAnchor.constraint(equalToConstant: 12).isActive = true
            selectedImageView.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor).isActive = true
            selectedImageView.trailingAnchor.constraint(equalTo: elemetView.trailingAnchor, constant: -horizontalConstrainValue).isActive = true

            lastSeperationView = addLineViewElement(withTopConstraint: verticalConstrainValue, fromElement: elemetView)
            backgroundViewHeight += eachElementEstimatedHight
        }
    }

    func initSelectCategoriesDescription() {
        let label = UILabel()
        label.text = kLocalizedSelectCategoriesDescription
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
        self.backgroundView.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        if let lastView = categoryElementViews.last {
            label.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 15).isActive = true
        }
        label.leftAnchor.constraint(equalTo: self.backgroundView.leftAnchor, constant: horizontalConstrainValue).isActive = true
        backgroundViewHeight += eachElementEstimatedHight
    }

    func addLineViewElement(withTopConstraint topConstraint: CGFloat, fromElement element: UIView) -> UIView {
        let lineView = UIView()
        lineView.backgroundColor = UIColor.textViewBorderGray
        backgroundView.addSubview(lineView)

        lineView.translatesAutoresizingMaskIntoConstraints = false
        if element == self.backgroundView {
            lineView.topAnchor.constraint(equalTo: element.topAnchor, constant: topConstraint).isActive = true
        } else {
            lineView.topAnchor.constraint(equalTo: element.bottomAnchor, constant: topConstraint).isActive = true
        }
        lineView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 0).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: 0).isActive = true

        return lineView
    }

    @objc func selectCategoryAction(_ sender: AnyObject) {
        let tag = sender.view.tag
        let selectCategoryView = categoryElementViews[tag]
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: .allowUserInteraction,
                       animations: {
                        selectCategoryView.backgroundColor = .textViewBorderGray
                        selectCategoryView.backgroundColor = .white
                    }, completion: nil)
        if selectedCategoryTag.count < 3 && !selectedCategoryTag.contains(tag) {
            selectedCategoryTag.append(tag)
            if let checkImageView = selectCategoryView.subviews.last {
                checkImageView.isHidden = false
            }
        } else if selectedCategoryTag.contains(tag) {
            selectedCategoryTag.removeObject(tag)
            if let checkImageView = selectCategoryView.subviews.last {
                checkImageView.isHidden = true
            }
        }
    }

    func sendBack(selectedCategories: [StoreProjectTag]) {
        self.delegate?.categoriesSelected(tags: selectedCategories)
    }
}
