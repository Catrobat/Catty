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

import SpriteKit
import UIKit

@objc
class ScenePresenterViewController: UIViewController, UIActionSheetDelegate {

    let slidingStartArea = 40
    let menuAnimationDuration = 0.25

    var menuView: UIView?
    var menuViewLeadingConstraint: NSLayoutConstraint?
    var program: Program?
    var formulaManager: FormulaManager?

    private var _loadingView: LoadingView?
    var loadingView: LoadingView? {
        // lazy instantiation
        if _loadingView == nil {
            _loadingView = LoadingView()
            view.addSubview(_loadingView!)
            view.bringSubview(toFront: _loadingView!)
        }
        return _loadingView
    }
    @IBOutlet private weak var menuBackButton: UIButton!
    @IBOutlet private weak var menuContinueButton: UIButton!
    @IBOutlet private weak var menuScreenshotButton: UIButton!
    @IBOutlet private weak var menuRestartButton: UIButton!
    @IBOutlet private weak var menuAxisButton: UIButton!
    @IBOutlet private weak var menuAspectRatioButton: UIButton!
    @IBOutlet private weak var menuBackLabel: UIButton!
    @IBOutlet private weak var menuContinueLabel: UIButton!
    @IBOutlet private weak var menuScreenshotLabel: UIButton!
    @IBOutlet private weak var menuRestartLabel: UIButton!
    @IBOutlet private weak var menuAxisLabel: UIButton!

    private var scene: CBScene?

    private var _skView: SKView?
    private var skView: SKView? {
        if _skView == nil {
            _skView = SKView(frame: view.bounds)
            #if DEBUG
            _skView?.showsFPS = true
            _skView?.showsNodeCount = true
            _skView?.showsDrawCount = true
            #endif
        }
        return _skView
    }
    private var menuOpen = false
    private var firstGestureTouchPoint = CGPoint.zero
    private var snapshotImage: UIImage?

    private var _gridView: UIView?
    private var gridView: UIView? {
        // lazy instantiation
        if _gridView == nil {
            _gridView = UIView(frame: view.bounds)
            _gridView?.isHidden = true
        }
        return _gridView
    }

    @objc
    func pausePlayer() {
        skView?.isPaused = true
        DispatchQueue.global(qos: .default).async(execute: {
            AudioManager.shared().pauseAllSounds()
            AudioManager.shared().pauseSpeechSynth()
            FlashHelper.sharedFlashHandler().pause()
            BluetoothService.sharedInstance().pauseBluetoothDevice()
        })
        scene?.pauseScheduler()
    }

    @objc
    func continuePlayer() {
        skView?.isPaused = false
        DispatchQueue.global(qos: .default).async(execute: {
            AudioManager.shared().resumeAllSounds()
            AudioManager.shared().resumeSpeechSynth()
            BluetoothService.sharedInstance().continueBluetoothDevice()
            if FlashHelper.sharedFlashHandler().wasTurnedOn == FlashON {
                FlashHelper.sharedFlashHandler().resume()
            }
        })
        scene?.resumeScheduler()
    }

    func stopProgram() {
        scene?.stopProgram()

        // TODO remove Singletons
        AudioManager.shared().stopAllSounds()
        AudioManager.shared().stopSpeechSynth()
        CameraPreviewHandler.shared().stopCamera()

        FlashHelper.sharedFlashHandler().reset()
        FlashHelper.sharedFlashHandler().turnOff() // always turn off flash light when Scene is stopped

        BluetoothService.sharedInstance().scenePresenter = nil
        BluetoothService.sharedInstance().resetBluetoothDevice()
    }

    // MARK: - View Event Handling

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self,
                                                         action: #selector(ScenePresenterViewController.handlePan(_:))))
        skView?.backgroundColor = UIColor.background()
        self.modalPresentationCapturesStatusBarAppearance = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.shared.isIdleTimerDisabled = true
        navigationController?.navigationBar.isHidden = true
        navigationController?.isToolbarHidden = true
        // disable swipe back gesture
        if navigationController?.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) ?? false {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        menuOpen = false

        if let sView = skView {
            view.addSubview(sView)
        }
        let subviewArray = Bundle.main.loadNibNamed("SceneMenuView", owner: self, options: nil)
        menuView = subviewArray?[0] as? UIView
        if let mView = menuView, let sView = skView {
            view.insertSubview(mView, aboveSubview: sView)
        }
        menuView?.translatesAutoresizingMaskIntoConstraints = false
        menuView?.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        menuViewLeadingConstraint = menuView?.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        menuViewLeadingConstraint?.isActive = true
        view.layoutIfNeeded()

        setUpMenuButtons()
        setUpLabels()
        setUpGridView()
        checkAspectRatio()

        setupSceneAndStart()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        menuView?.removeFromSuperview()
        navigationController?.navigationBar.isHidden = false
        navigationController?.isToolbarHidden = false
        UIApplication.shared.isIdleTimerDisabled = false

        // reenable swipe back gesture
        if navigationController?.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) ?? false {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        skView?.bounds = view.bounds
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: Dealloc

    deinit {
        program = nil
        scene = nil

        // Delete sound rec for loudness sensor
        let fileMgr = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let soundfile = URL(fileURLWithPath: documentsPath).appendingPathComponent("loudness_handler.m4a").absoluteString
        try? fileMgr.removeItem(atPath: soundfile)
    }

    // MARK: View Setup

    func setUpLabels() {
        let labelTextArray = [kLocalizedBack, kLocalizedRestart, kLocalizedContinue, kLocalizedPreview, kLocalizedAxes]
        let labelArray = [menuBackLabel, menuRestartLabel, menuContinueLabel, menuScreenshotLabel, menuAxisLabel]
        for i in 0..<labelTextArray.count {
            setupLabel(labelTextArray[i], andView: labelArray[i])
        }
        menuBackLabel.addTarget(self,
                                action: #selector(ScenePresenterViewController.stopAction(_:)),
                                for: .touchUpInside)
        menuContinueLabel.addTarget(self,
                                    action: #selector(ScenePresenterViewController.continueAction(_:)),
                                    for: .touchUpInside)
        menuScreenshotLabel.addTarget(self,
                                      action: #selector(ScenePresenterViewController.takeScreenshotAction(_:)),
                                      for: .touchUpInside)
        menuRestartLabel.addTarget(self,
                                   action: #selector(ScenePresenterViewController.restartAction(_:)),
                                   for: .touchUpInside)
        menuAxisLabel.addTarget(self,
                                action: #selector(ScenePresenterViewController.showHideAxisAction(_:)),
                                for: .touchUpInside)
    }

    func setupLabel(_ name: String?, andView label: UIButton?) {
        label?.setTitle(name, for: .normal)
        label?.tintColor = UIColor.navTint()
        label?.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        label?.titleLabel?.textAlignment = .center
    }

    func setUpMenuButtons() {
        setupButton(with: menuBackButton,
                    imageNameNormal: UIImage(named: "stage_dialog_button_back"),
                    andImageNameHighlighted: UIImage(named: "stage_dialog_button_back_pressed"),
                    andSelector: #selector(ScenePresenterViewController.stopAction(_:)))
        setupButton(with: menuContinueButton,
                    imageNameNormal: UIImage(named: "stage_dialog_button_continue"),
                    andImageNameHighlighted: UIImage(named: "stage_dialog_button_continue_pressed"),
                    andSelector: #selector(ScenePresenterViewController.continueAction(_:)))
        setupButton(with: menuScreenshotButton,
                    imageNameNormal: UIImage(named: "stage_dialog_button_screenshot"),
                    andImageNameHighlighted: UIImage(named: "stage_dialog_button_screenshot_pressed"),
                    andSelector: #selector(ScenePresenterViewController.takeScreenshotAction(_:)))
        setupButton(with: menuRestartButton,
                    imageNameNormal: UIImage(named: "stage_dialog_button_restart"),
                    andImageNameHighlighted: UIImage(named: "stage_dialog_button_restart_pressed"),
                    andSelector: #selector(ScenePresenterViewController.restartAction(_:)))
        setupButton(with: menuAxisButton,
                    imageNameNormal: UIImage(named: "stage_dialog_button_toggle_axis"),
                    andImageNameHighlighted: UIImage(named: "stage_dialog_button_toggle_axis_pressed"),
                    andSelector: #selector(ScenePresenterViewController.showHideAxisAction(_:)))
        setupButton(with: menuAspectRatioButton,
                    imageNameNormal: UIImage(named: "stage_dialog_button_aspect_ratio"),
                    andImageNameHighlighted: UIImage(named: "stage_dialog_button_aspect_ratio_pressed"),
                    andSelector: #selector(ScenePresenterViewController.manageAspectRatioAction(_:)))
    }

    func setupButton(with button: UIButton?, imageNameNormal stateNormal: UIImage?, andImageNameHighlighted stateHighlighted: UIImage?, andSelector myAction: Selector) {
        button?.setBackgroundImage(stateNormal, for: .normal)
        button?.setBackgroundImage(stateHighlighted, for: .highlighted)
        button?.setBackgroundImage(stateHighlighted, for: .selected)
        button?.addTarget(self, action: myAction, for: .touchUpInside)
    }

    func setUpGridView() {
        gridView?.backgroundColor = UIColor.clear
        let xArrow = UIView(frame: CGRect(x: 0,
                                          y: Util.screenHeight() / 2,
                                          width: Util.screenWidth(),
                                          height: 1))
        xArrow.backgroundColor = UIColor.red
        gridView?.addSubview(xArrow)
        let yArrow = UIView(frame: CGRect(x: Util.screenWidth() / 2,
                                          y: 0,
                                          width: 1,
                                          height: Util.screenHeight()))
        yArrow.backgroundColor = UIColor.red
        gridView?.addSubview(yArrow)
        // nullLabel
        let nullLabel = UILabel(frame: CGRect(x: Util.screenWidth() / 2 + 5,
                                              y: Util.screenHeight() / 2 + 5,
                                              width: 10,
                                              height: 15))
        nullLabel.text = "0"
        nullLabel.textColor = UIColor.red
        gridView?.addSubview(nullLabel)
        // positveWidth
        let positiveWidth = UILabel(frame: CGRect(x: Util.screenWidth() - 40,
                                                  y: Util.screenHeight() / 2 + 5,
                                                  width: 30,
                                                  height: 15))
        positiveWidth.text = String((program?.header.screenWidth.intValue)! / 2)
        positiveWidth.textColor = UIColor.red
        positiveWidth.sizeToFit()
        positiveWidth.frame = CGRect(x: Util.screenWidth() - positiveWidth.frame.size.width - 5,
                                     y: Util.screenHeight() / 2 + 5,
                                     width: positiveWidth.frame.size.width,
                                     height: positiveWidth.frame.size.height)
        gridView?.addSubview(positiveWidth)
        // negativeWidth
        let negativeWidth = UILabel(frame: CGRect(x: 5,
                                                  y: Util.screenHeight() / 2 + 5,
                                                  width: 40,
                                                  height: 15))
        negativeWidth.text = String(-(program?.header.screenWidth.intValue)! / 2)
        negativeWidth.textColor = UIColor.red
        negativeWidth.sizeToFit()
        gridView?.addSubview(negativeWidth)
        // positveHeight
        let positiveHeight = UILabel(frame: CGRect(x: Util.screenWidth() / 2 + 5,
                                                   y: Util.screenHeight() - 20,
                                                   width: 40,
                                                   height: 15))
        positiveHeight.text = String(-(program?.header.screenHeight.intValue)! / 2)
        positiveHeight.textColor = UIColor.red
        positiveHeight.sizeToFit()
        gridView?.addSubview(positiveHeight)
        // negativeHeight
        let negativeHeight = UILabel(frame: CGRect(x: Util.screenWidth() / 2 + 5,
                                                   y: 5,
                                                   width: 40,
                                                   height: 15))
        negativeHeight.text = String((program?.header.screenHeight.intValue)! / 2)
        negativeHeight.textColor = UIColor.red
        negativeHeight.sizeToFit()
        gridView?.addSubview(negativeHeight)

        if let aView = gridView, let aView1 = skView {
            view.insertSubview(aView, aboveSubview: aView1)
        }
    }

    func checkAspectRatio() {
        if Int(truncating: (program?.header.screenWidth)!) == Int(Util.screenWidth(true)) &&
            Int(truncating: (program?.header.screenHeight)!) == Int(Util.screenHeight(true)) {
            menuAspectRatioButton.isHidden = true
        }
    }

    func setupSceneAndStart() {
        // Initialize scene
        let scene: CBScene? = SceneBuilder(program: program!)
            .withFormulaManager(formulaManager: formulaManager!)
            .build()

        if program?.header.screenMode == kCatrobatHeaderScreenModeMaximize {
            scene?.scaleMode = SKSceneScaleMode.fill
        } else if program?.header.screenMode == kCatrobatHeaderScreenModeStretch {
            scene?.scaleMode = SKSceneScaleMode.aspectFit
        } else {
            scene?.scaleMode = SKSceneScaleMode.fill
        }
        self.scene = scene

        BluetoothService.sharedInstance().scenePresenter = self
        CameraPreviewHandler.shared()?.setCamView(self.view)

        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")

        skView?.presentScene(self.scene)
        self.scene?.startProgram()

        menuView?.isUserInteractionEnabled = true

        hideLoadingView()
        hideMenuView()
    }

    // MARK: - Bluetooth Event Handling

    func connectionLost() {
        showLoadingView()
        menuView?.isUserInteractionEnabled = false
        let previousScene: CBScene? = scene
        previousScene?.isUserInteractionEnabled = false
        stopProgram()
        previousScene?.isUserInteractionEnabled = true
        hideLoadingView()

        AlertControllerBuilder.alert(title: "Lost Bluetooth Connection", message: kLocalizedPocketCode)
            .addCancelAction(title: kLocalizedOK, handler: {
                self.parent?.navigationController?.isToolbarHidden = false
                self.parent?.navigationController?.isNavigationBarHidden = false
                self.navigationController?.popViewController(animated: true)})
            .build()
            .showWithController(self)
    }

    // MARK: - User Event Handling

    @objc func continueAction(_ sender: UIButton?) {
        continuePlayer()
        hideMenuView()
    }

    @objc func stopAction(_ sender: UIButton?) {
        let previousScene: CBScene? = scene

        DispatchQueue.global(qos: .default).async(execute: {
            self.menuView?.isUserInteractionEnabled = false
            previousScene?.isUserInteractionEnabled = false
            self.stopProgram()
            previousScene?.isUserInteractionEnabled = true
        })

        parent?.navigationController?.isToolbarHidden = false
        parent?.navigationController?.isNavigationBarHidden = false
        navigationController?.popViewController(animated: true)
    }

    @objc func restartAction(_ sender: UIButton?) {
        showLoadingView()

        menuView?.isUserInteractionEnabled = false
        scene?.isUserInteractionEnabled = false

        DispatchQueue.global(qos: .default).async(execute: {
            self.stopProgram()

            DispatchQueue.main.async(execute: {
                self.program = Program(loadingInfo: Util.lastUsedProgramLoadingInfo())
                self.setupSceneAndStart()
            })
        })
    }

    @objc func showHideAxisAction(_ sender: UIButton?) {
        if gridView?.isHidden == false {
            gridView?.isHidden = true
        } else {
            gridView?.isHidden = false
        }
    }

    @objc func manageAspectRatioAction(_ sender: UIButton?) {
        scene?.scaleMode = scene?.scaleMode == .aspectFit ? .fill : .aspectFit
        program?.header.screenMode = (program?.header.screenMode == kCatrobatHeaderScreenModeStretch) ? kCatrobatHeaderScreenModeMaximize : kCatrobatHeaderScreenModeStretch
        skView?.setNeedsLayout()
    }

    @objc func takeScreenshotAction(_ sender: UIButton?) {
        takeManualScreenshot(for: skView!, and: program!)
    }

    // MARK: - Pan Gesture Handler

    @objc func handlePan(_ gesture: UIPanGestureRecognizer?) {
        if var translate: CGPoint? = gesture?.translation(in: gesture?.view) {
            translate!.y = 0.0

            if gesture?.state == .began {
                firstGestureTouchPoint = gesture?.location(in: gesture?.view) ?? CGPoint.zero
            }

            if gesture?.state == .changed {
                if translate!.x > 0.0 &&
                    translate!.x < (menuView?.frame.size.width ?? 0.0) &&
                    firstGestureTouchPoint.x < CGFloat(slidingStartArea) &&
                    menuOpen == false {
                    handlePositvePan(translate ?? CGPoint.zero)
                } else if translate!.x < 0.0 && (translate?.x ?? 0.0) > -(menuView?.frame.size.width ?? 0.0) && menuOpen == true {
                    handleNegativePan(translate ?? CGPoint.zero)
                }
            }

            if gesture?.state == .cancelled ||
                gesture?.state == .ended ||
                gesture?.state == .failed {
                if translate!.x > ((menuView?.frame.size.width)! / 4) &&
                    firstGestureTouchPoint.x < CGFloat(slidingStartArea) &&
                    menuOpen == false {
                    //user opened at least 1/4 of the menu -> show
                    showMenuView()
                } else if translate!.x > 0.0 &&
                    translate!.x < ((menuView?.frame.size.width)! / 4) &&
                    firstGestureTouchPoint.x < CGFloat(slidingStartArea) &&
                    menuOpen == false {
                    //user did not open at least 1/4 of the menu -> abort/hide
                    hideMenuView()
                } else if translate!.x < (-(menuView?.frame.size.width)! / 4) &&
                    menuOpen == true {
                    //user closed at least 1/4 of the opened menu -> hide
                    hideMenuView()
                } else if translate!.x < 0.0 &&
                    translate!.x > (-(menuView?.frame.size.width)! / 4) &&
                    menuOpen == true {
                    //user did not close at least 1/4 of the menu -> abort/show
                    showMenuView()
                } else {
                    //if anything goes wrong, hide the menu view
                    hideMenuView()
                }
            }
        }
    }

    func handlePositvePan(_ translate: CGPoint) {
        UIView.animate(withDuration: menuAnimationDuration,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        self.view.bringSubview(toFront: self.menuView!)
                        self.menuViewLeadingConstraint?.constant = -(self.menuView?.frame.size.width)! + translate.x
                        self.view.layoutIfNeeded()
        })
    }

    func handleNegativePan(_ translate: CGPoint) {
        UIView.animate(withDuration: menuAnimationDuration,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        self.menuViewLeadingConstraint?.constant = translate.x
                        self.view.layoutIfNeeded()
        })
    }

    func showMenuView() {
        UIView.animate(withDuration: menuAnimationDuration,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        self.view.bringSubview(toFront: self.menuView!)
                        self.menuViewLeadingConstraint?.constant = 0
                        self.view.layoutIfNeeded()
        }, completion: { _ in
            self.menuOpen = true
            self.pausePlayer()
        })
    }

    func hideMenuView() {
        let hideAnimationDuration = (self.skView?.isPaused ?? true) ? menuAnimationDuration : 0.5
        UIView.animate(withDuration: hideAnimationDuration,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        self.menuViewLeadingConstraint?.constant = -(self.menuView?.frame.size.width ?? 0.0)
                        self.view.layoutIfNeeded()
        }, completion: { _ in
            self.menuOpen = false
            if self.skView?.isPaused ?? true {
                self.continuePlayer()
            } else {
                self.takeAutomaticScreenshot(for: self.skView!, and: self.program!)
            }
        })
    }

    // MARK: - Getters & Setters

    func showLoadingView() {
        loadingView?.show()
    }

    func hideLoadingView() {
        loadingView?.hide()
    }
}
