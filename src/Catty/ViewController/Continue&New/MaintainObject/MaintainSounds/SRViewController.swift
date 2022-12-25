/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

import AVFoundation
import UIKit

@objc(SRViewController)
class SRViewController: UIViewController, AVAudioRecorderDelegate {

    @objc weak var delegate: SoundDelegate?

    @IBOutlet private var recordButton: UIButton!
    private var sound: Sound?
    private var filePath: String?
    @IBOutlet private weak var timerLabel: TimerLabel!
    private var recorder: AVAudioRecorder?
    private var session: AVAudioSession?
    private var isSaved = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let save = UIBarButtonItem(
            title: "save", style: .done, target: self, action: #selector(saveSound(sender:)))
        navigationController?.isToolbarHidden = true
        navigationItem.rightBarButtonItem = save

        let frame_x = view.frame.size.width / 2.0 - (view.frame.size.height * 0.4 / 2.0)
        let frame_y = view.frame.size.height * 0.4
        recordButton.frame = CGRect(x: frame_x, y: frame_y, width: view.frame.size.height * 0.4, height: view.frame.size.height * 0.4)

        timerLabel.timerType = TimerLabelTypeStopWatch
        view.addSubview(timerLabel)
        timerLabel.timeLabel.backgroundColor = UIColor.clear
        timerLabel.timeLabel.font = UIFont.systemFont(ofSize: 28.0)
        timerLabel.timeLabel.textColor = UIColor.globalTint
        timerLabel.textAlignment = NSTextAlignment.center

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.recording(_:)))
        timerLabel.addGestureRecognizer(recognizer)

        view.backgroundColor = UIColor.background

        initializeRecorder()

    }

    // MARK: Recorder

    @objc func initializeRecorder() {
        session = AVAudioSession.sharedInstance()

        let fileManager = CBFileManager.shared()
        let fileName = NSString.uuid() + ".m4a"
        if let documentsDirectory = fileManager?.documentsDirectory {
            filePath = "\(documentsDirectory)/\(fileName)"
            sound = Sound.init(name: fileName, fileName: fileName)
            let pathURL = URL(fileURLWithPath: filePath!, isDirectory: false)

            let settings = [
                AVFormatIDKey: NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
                AVSampleRateKey: NSNumber(value: 44100.0),
                AVNumberOfChannelsKey: NSNumber(value: 2)
            ]
            do {
                try session?.setCategory(.record)
                try recorder = AVAudioRecorder.init(url: pathURL, settings: settings)
                recorder?.isMeteringEnabled = true
                recorder?.prepareToRecord()
                recorder?.delegate = self

            } catch {
                debugPrint(error)
            }
        }
    }

    // MARK: Tap/Click events

    @IBAction private func recording(_ sender: Any) {
        recordClicked()
    }

    @objc func recordClicked() {
        if !recordButton.isSelected {

            recordButton.isSelected = true
            timerLabel.start()

            do {
                try session?.setActive(true)
            } catch {
                debugPrint(error)
            }

            recorder?.record(forDuration: (Double(CBFileManager.shared().freeDiskspace()) / 1024) / 256.0)
            sound?.name = kLocalizedRecording

        } else {
            recorder?.pause()
            timerLabel.pause()
            recordButton.isSelected = false
        }
    }

    @objc func saveSound(sender: UIBarButtonItem) {
        if sound?.name == kLocalizedRecording {
            recorder?.stop()
            delegate?.add(sound)
        } else {
            recorder?.deleteRecording()
        }
        isSaved = true
        navigationController?.popViewController(animated: true)
    }

    @objc override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (sound?.name == kLocalizedRecording) && !isSaved {
            recorder?.stop()
            delegate?.showSaveSoundAlert(sound)
        } else if (sound?.name != kLocalizedRecording) && !isSaved {
            recorder?.deleteRecording()
        }
    }

    // MARK: AVAudioRecorderDelegate

    @objc func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {

        recordButton.isEnabled = false
        timerLabel.pause()
        recordButton.isSelected = false

        if (Double(CBFileManager.shared().freeDiskspace() / 1024) / 1024) < 1 {
            Util.alert(title: kLocalizedError, text: kLocalizedMemoryWarning)
        }

        if !flag {
            sound?.name = ""
        }
    }

    // MARK: System Memory Warning

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        Util.alert(title: kLocalizedError, text: kLocalizedMemoryWarning)
    }

}
