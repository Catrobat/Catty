/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

import UIKit

@objc class BrickCategoryOverviewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var brickCategoryOverviewCollectionView: UICollectionView!
    var categegoriesBricks = [BrickCategory]()
    var scriptCollectionViewController: ScriptCollectionViewController

    // MARK: Init
    @objc(init:) init(scriptCollectionViewController: ScriptCollectionViewController) {
        self.scriptCollectionViewController = scriptCollectionViewController
        categegoriesBricks = CatrobatSetup.self.registeredBrickCategories()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCollectionView()
    }

    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: UIDefines.brickCategorySectionInset, left: 0, bottom: UIDefines.brickCategorySectionInset, right: 0)
        layout.itemSize = CGSize(width: view.frame.width, height: UIDefines.brickCategoryHeight)
        layout.minimumInteritemSpacing = UIDefines.brickCategorySectionInset
        layout.minimumLineSpacing = UIDefines.brickCategorySectionInset

        brickCategoryOverviewCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)

        brickCategoryOverviewCollectionView.register(BrickCategoryOverviewCollectionViewCell.self, forCellWithReuseIdentifier: BrickCategoryOverviewCollectionViewCell.identifier)
        brickCategoryOverviewCollectionView.delegate = self
        brickCategoryOverviewCollectionView.dataSource = self
        brickCategoryOverviewCollectionView.backgroundColor = UIColor.white
        brickCategoryOverviewCollectionView.autoresizesSubviews = true
        brickCategoryOverviewCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(brickCategoryOverviewCollectionView)

        setupNavBar()
    }

    // MARK: UICollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categegoriesBricks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BrickCategoryOverviewCollectionViewCell.identifier, for: indexPath) as? BrickCategoryOverviewCollectionViewCell else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: BrickCategoryOverviewCollectionViewCell.identifier, for: indexPath)
        }
        cell.configure(label: categegoriesBricks[indexPath.row].name)
        cell.contentView.backgroundColor = categegoriesBricks[indexPath.row].color
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.borderColor = categegoriesBricks[indexPath.row].strokeColor.cgColor
        return cell
    }

    @objc func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bcvc = BrickCategoryViewController(brickCategory: categegoriesBricks[indexPath.row].self, andObject: scriptCollectionViewController.object)
        bcvc?.delegate = scriptCollectionViewController.self

        guard let bcvc_unwrapped = bcvc else {
               return
        }
        self.navigationController?.pushViewController(bcvc_unwrapped, animated: true)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
           if let layout = self.brickCategoryOverviewCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: self.view.frame.width, height: UIDefines.brickCategoryHeight)
           }
        }
    }

    // MARK: Setup
    func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(dismiss))

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.navTint]

        navigationItem.leftBarButtonItem?.tintColor = UIColor.navTint
        updateTitle()
    }

    @objc func updateTitle() {
        title = kLocalizedCategories
    }

    @objc
    func dismiss(sender: Any) {
        if sender is UIBarButtonItem {
            presentingViewController?.dismiss(animated: true)
        }
    }

}
