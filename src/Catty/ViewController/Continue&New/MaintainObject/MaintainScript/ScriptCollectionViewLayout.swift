/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

@objc
protocol ScriptCollectionViewLayoutDelegate: class {
    func scriptCollectionViewLayout(_ scriptCollectionViewLayout: ScriptCollectionViewLayout,
                                    moveItemAt indexPath: IndexPath, to newIndexPath: IndexPath)
}

/// ScriptCollectionViewLayout subclasses UICollectionViewFlowLayout in order to be able
/// to adjust the collection view's data source while moving bricks, so that the size of
/// the bricks doesn't change while being dragged.
@objc
class ScriptCollectionViewLayout: UICollectionViewFlowLayout {

    @objc
    internal weak var delegate: ScriptCollectionViewLayoutDelegate?

    override func invalidationContext(forInteractivelyMovingItems targetIndexPaths: [IndexPath],
                                      withTargetPosition targetPosition: CGPoint, previousIndexPaths: [IndexPath],
                                      previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {

        let context = super.invalidationContext(forInteractivelyMovingItems: targetIndexPaths,
                                                withTargetPosition: targetPosition,
                                                previousIndexPaths: previousIndexPaths,
                                                previousPosition: previousPosition)

        if let previousIndexPath = previousIndexPaths.first, let targetIndexPath = targetIndexPaths.first {
            self.delegate?.scriptCollectionViewLayout(self, moveItemAt: previousIndexPath, to: targetIndexPath)
        }

        return context
    }
}
