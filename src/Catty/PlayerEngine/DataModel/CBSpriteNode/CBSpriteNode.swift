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

@objc
class CBSpriteNode: SKSpriteNode {

    // MARK: - Properties
    @objc var spriteObject: SpriteObject
    @objc var currentLook: Look? {
        didSet {
            setPhyicsBody()

            guard let stage = self.scene as? StageProtocol else { return }
            if !self.spriteObject.isBackground() { return }
            stage.notifyBackgroundChange()
        }
    }
    @objc var currentUIImageLook: UIImage?

    var rotationStyle: RotationStyle
    var rotationDegreeOffset = 90.0
    var penConfiguration: PenConfiguration
    var embroideryStream: EmbroideryStream

    @objc var filterDict = ["brightness": false, "color": false]
    @objc var ciBrightness = CGFloat(BrightnessSensor.defaultRawValue) // CoreImage specific brightness
    @objc var ciHueAdjust = CGFloat(ColorSensor.defaultRawValue) // CoreImage specific hue adjust

    // MARK: Custom getters and setters
    @objc func setPositionForCropping(_ position: CGPoint) {
        self.position = position
    }

    // MARK: - Initializers
    @objc required init(spriteObject: SpriteObject) {
        let color = UIColor.clear
        self.spriteObject = spriteObject
        self.rotationStyle = SpriteKitDefines.defaultRotationStyle
        self.embroideryStream = EmbroideryStream(projectWidth: self.spriteObject.scene.project?.header.screenWidth as? CGFloat,
                                                 projectHeight: self.spriteObject.scene.project?.header.screenHeight as? CGFloat)

        self.penConfiguration = PenConfiguration(projectWidth: self.spriteObject.scene.project?.header.screenWidth as? CGFloat,
                                                 projectHeight: self.spriteObject.scene.project?.header.screenHeight as? CGFloat)

        if let firstLook = spriteObject.lookList.firstObject as? Look,
            let filePathForLook = firstLook.path(for: spriteObject.scene),
            let image = UIImage(contentsOfFile: filePathForLook) {
            let texture = SKTexture(image: image)
            let textureSize = texture.size()
            super.init(texture: texture, color: color, size: textureSize)
            self.currentLook = firstLook

        } else {
            super.init(texture: nil, color: color, size: CGSize.zero)
        }

        self.spriteObject.spriteNode = self
        self.name = spriteObject.name
        self.isUserInteractionEnabled = false

        setLook()
    }

    @objc required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func update(_ currentTime: TimeInterval) {
        self.drawPenLine()
        self.drawPlotLine()
        self.drawEmbroidery()

        for script in self.spriteObject.scriptList where ((script as? WhenConditionScript) != nil) {
            guard let stage = self.scene as? StageProtocol else { return }
            stage.notifyWhenCondition()
        }
    }

    // MARK: - Operations
    func returnFilterInstance(_ filterName: String, image: CIImage) -> CIFilter? {
        var filter: CIFilter?
        if filterName == "brightness" {
            filter = CIFilter(name: "CIColorControls", parameters: [kCIInputImageKey: image, "inputBrightness": self.ciBrightness])
        }
        if filterName == "color" {
            filter = CIFilter(name: "CIHueAdjust", parameters: [kCIInputImageKey: image, "inputAngle": self.ciHueAdjust])
        }
        return filter
    }

    @objc func executeFilter(_ inputImage: UIImage?) {
        guard let lookImage = inputImage?.cgImage else { preconditionFailure() }

        var ciImage = CIImage(cgImage: lookImage)
        let context = CIContext(options: nil)

        if Double(self.ciBrightness) != BrightnessSensor.defaultRawValue {
            self.filterDict["brightness"] = true
        } else {
            self.filterDict["brightness"] = false
        }

        if Double(self.ciHueAdjust) != ColorSensor.defaultRawValue {
            self.filterDict["color"] = true
        } else {
            self.filterDict["color"] = false
        }

        for (filterName, isActive) in filterDict {
            if isActive, let outputImage = returnFilterInstance(filterName, image: ciImage)?.outputImage {
                ciImage = outputImage
            }
        }

        let outputImage = ciImage
        // 2
        guard let cgimg = context.createCGImage(outputImage, from: outputImage.extent) else { preconditionFailure() }

        // 3
        let newImage = UIImage(cgImage: cgimg)
        self.currentUIImageLook = newImage
        let texture = SKTexture(image: newImage)
        let xScale = self.xScale
        let yScale = self.yScale

        let defaultSize = CGFloat(SizeSensor.defaultRawValue)
        self.xScale = defaultSize
        self.yScale = defaultSize
        self.size = texture.size()

        self.texture = texture
        if xScale != defaultSize {
            self.xScale = xScale
        }
        if yScale != defaultSize {
            self.yScale = yScale
        }
    }

    @objc func nextLook() -> Look? {
        guard let currentLook = currentLook
            else { return nil }

        let currentIndex = spriteObject.lookList.index(of: currentLook)
        let nextIndex = (currentIndex + 1) % spriteObject.lookList.count
        return spriteObject.lookList[nextIndex] as? Look
    }

    @objc func previousLook() -> Look? {
        if currentLook == nil {
            return nil
        }

        var index = spriteObject.lookList.index(of: currentLook!)
        index -= 1
        index = index < 0 ? spriteObject.lookList.count - 1 : index
        return spriteObject.lookList[index] as? Look
    }

    @objc func getLookList() -> NSMutableArray? {
        spriteObject.lookList
    }

    @objc func look(for index: Int) -> Look? {
        if  index < 1 || index > spriteObject.lookList.count {
            return nil
        }
        return spriteObject.lookList[index - 1] as? Look
    }

    @objc func changeLook(_ look: Look?) {
        guard let look = look,
            let filePathForLook = look.path(for: spriteObject.scene),
            let image = UIImage(contentsOfFile: filePathForLook)
            else { return }

        let texture = SKTexture(image: image)
        self.currentUIImageLook = image
        self.size = texture.size()
        let xScale = self.xScale
        let yScale = self.yScale
        let defaultSize = CGFloat(SizeSensor.defaultRawValue)
        self.xScale = defaultSize
        self.yScale = defaultSize
        self.size = texture.size()

        self.texture = texture
        self.currentLook = look

        if xScale != defaultSize {
            self.xScale = xScale
        }
        if yScale != defaultSize {
            self.yScale = yScale
        }
    }

    @objc func setLook() {
        // swiftlint:disable:next empty_count
        if spriteObject.lookList.count > 0, let look = spriteObject.lookList[0] as? Look {
            changeLook(look)
        }
    }

    // MARK: Events
    @objc func start(_ zPosition: CGFloat) {

        self.catrobatPosition = CBPosition(x: PositionXSensor.defaultRawValue, y: PositionYSensor.defaultRawValue)

        self.zRotation = CGFloat(RotationSensor.defaultRawValue)
        self.xScale = CGFloat(SizeSensor.defaultRawValue)
        self.yScale = CGFloat(SizeSensor.defaultRawValue)

        self.ciBrightness = CGFloat(BrightnessSensor.defaultRawValue)

        if self.spriteObject.isBackground() == true {
            self.zPosition = CGFloat(LayerSensor.defaultRawValue)
        } else {
            self.zPosition = zPosition
        }
    }

    @objc func isTouched(at touch: UITouch) -> Bool {
        guard let imageLook = currentUIImageLook else { return false }

        guard spriteObject.name != nil, let scene = spriteObject.spriteNode.scene else { preconditionFailure("Invalid SpriteObject!") }

        let globalTouchPosition = touch.location(in: scene)
        let localTouchPosition = touch.location(in: self)

        return self.contains(globalTouchPosition) && !imageLook.isTransparentPixel(atScenePoint: localTouchPosition)
    }

    @objc func isFlipped() -> Bool {
        if self.xScale < 0 {
            return true
        }
        return false
    }

    private func setPhyicsBody() {
        guard let objectName = self.spriteObject.name, isPhysicsObject() else { return }

        self.enumerateChildNodes(withName: SpriteKitDefines.physicsNodeName) { node, _ in
            node.removeFromParent()
        }

        let originalTexture = self.texture!
        let size = originalTexture.size()
        let physicsSubnodesPerDimension = Int((size.height > size.width ?
                                                            size.height / CGFloat(SpriteKitDefines.physicsSubnodeSize) :
                                                            size.width / CGFloat(SpriteKitDefines.physicsSubnodeSize)
                                                            ).rounded(.up))

        let leftCornerX = (-size.width / 2)
        let bottomCornerY = (-size.height / 2)
        let childNodeWidth = (size.width / CGFloat(physicsSubnodesPerDimension))
        let childNodeHeight = (size.height / CGFloat(physicsSubnodesPerDimension))
        let childNodeSize = CGSize(width: childNodeWidth, height: childNodeHeight)
        let childNodeHeightRelative = 1.0 / CGFloat(physicsSubnodesPerDimension)
        let childNodeWidthRelative = 1.0 / CGFloat(physicsSubnodesPerDimension)

        let superNode = SKSpriteNode(color: .clear, size: size)
        superNode.name = SpriteKitDefines.physicsNodeName

        for y in 0..<physicsSubnodesPerDimension {
            for x in 0..<physicsSubnodesPerDimension {
                let dX = childNodeWidth * CGFloat(x)
                let dY = childNodeHeight * CGFloat(y)

                let dXRelative = childNodeWidthRelative * CGFloat(x)
                let dYRelative = childNodeHeightRelative * CGFloat(y)

                let rect = CGRect(x: dXRelative, y: dYRelative, width: childNodeWidthRelative, height: childNodeHeightRelative)

                let texture = SKTexture(rect: rect, in: originalTexture)

                let physicsBodyJoint: SKPhysicsBody? = SKPhysicsBody(texture: texture, size: childNodeSize)
                guard physicsBodyJoint != nil else { continue }

                let node = SKSpriteNode(color: .clear, size: childNodeSize)
                node.name = objectName
                node.position.x = leftCornerX + childNodeWidth / 2 + dX
                node.position.y = bottomCornerY + childNodeHeight / 2 + dY

                node.physicsBody = physicsBodyJoint
                node.physicsBody?.collisionBitMask = 0
                node.physicsBody?.categoryBitMask = 1
                node.physicsBody?.contactTestBitMask = 1
                node.physicsBody?.isDynamic = true
                node.physicsBody?.affectedByGravity = false
                superNode.addChild(node)
            }
        }

        self.addChild(superNode)
    }

    func makePhysicsObject(setBody: Bool = true) {
        guard let objectName = self.spriteObject.name else { return }

        if !isPhysicsObject() {
            self.spriteObject.scene.project?.physicsObjectNames.add(objectName)
        }

        if setBody, self.childNode(withName: SpriteKitDefines.physicsNodeName) == nil {
            setPhyicsBody()
        }
    }

    private func isPhysicsObject() -> Bool {
        guard let objectName = self.spriteObject.name else { return false }
        return self.spriteObject.scene.project?.physicsObjectNames.contains(objectName) ?? false
    }
}
