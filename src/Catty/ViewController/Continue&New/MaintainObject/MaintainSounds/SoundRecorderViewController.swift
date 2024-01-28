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

import AVFoundation
import UIKit

@objc class SoundRecorderViewController: UIViewController, AVAudioRecorderDelegate {

    @objc weak var delegate: SoundDelegate?

    @IBOutlet private weak var timerLabel: TimerLabel!
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var dbMeter: UIProgressView!

    private let recordIcon = UIImage(named: "mic.circle")
    private let pauseIcon = UIImage(named: "pause.circle")

    private var recorder: AVAudioRecorder?
    private var displayLink: CADisplayLink?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = kLocalizedPocketCodeRecorder
        navigationController?.isToolbarHidden = true

        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        navigationItem.rightBarButtonItem = done

        let back = UIBarButtonItem(title: kLocalizedBack, style: .plain, target: self, action: #selector(backButtonPressed))
        navigationItem.leftBarButtonItem = back

        timerLabel.timerType = TimerLabelTypeStopWatch
        timerLabel.timeFormat = "mm:ss.SS"
        timerLabel.timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .regular)
        timerLabel.timeLabel.textColor = UIColor.globalTint

        recordButton.tintAdjustmentMode = .normal
        recordButton.setBackgroundImage(recordIcon, for: .normal)

        initializeRecorder()
    }

    func initializeRecorder() {
        let documents = URL(fileURLWithPath: CBFileManager.shared().documentsDirectory)
        let fileURL = documents.appendingPathComponent(NSString.uuid()).appendingPathExtension("m4a")

        let settings = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2
        ]

        try? AVAudioSession.sharedInstance().setCategory(.record)
        recorder = try? AVAudioRecorder.init(url: fileURL, settings: settings)
        recorder?.delegate = self
        recorder?.isMeteringEnabled = true

        displayLink = CADisplayLink(target: self, selector: #selector(updateMeters))
        displayLink?.add(to: .current, forMode: .common)
    }

    @objc func updateMeters() {
        if let recorder = recorder, recorder.isRecording {
            recorder.updateMeters()
            timerLabel.setStopWatchTime(recorder.currentTime)
            let average = (recorder.averagePower(forChannel: 0) + recorder.averagePower(forChannel: 1)) / 2
            dbMeter.setProgress(pow(10, average / 20), animated: false)
        } else {
            dbMeter.setProgress(0, animated: false)
        }
    }

    @IBAction private func recordButtonPressed(_ sender: Any) {
        guard let recorder = recorder else { return }

        if !recorder.isRecording {
            let maxDuration = Double(CBFileManager.shared().freeDiskspace()) / 1024 / 128 // 128 Kbps AAC
            guard recorder.record(forDuration: maxDuration) else { return }
            recordButton.setBackgroundImage(pauseIcon, for: .normal)
        } else {
            recorder.pause()
            recordButton.setBackgroundImage(recordIcon, for: .normal)
        }
    }

    @objc func doneButtonPressed() {
        exit(savingChanges: true)
    }

    @objc func backButtonPressed() {
        recorder?.pause()
        recordButton.setBackgroundImage(recordIcon, for: .normal)

        if let recordingUrl = recorder?.url, CBFileManager.shared().fileExists(recordingUrl.path) {
            AlertControllerBuilder.actionSheet(title: nil)
            .addCancelAction(title: kLocalizedCancel, handler: nil)
            .addDefaultAction(title: kLocalizedSaveChanges) { [weak self] in
                self?.exit(savingChanges: true)
            }
            .addDestructiveAction(title: kLocalizedDiscardChanges) { [weak self] in
                self?.exit(savingChanges: false)
            }
            .build().showWithController(self)
        } else {
            exit(savingChanges: false)
        }
    }

    func exit(savingChanges: Bool) {
        displayLink?.invalidate()
        recorder?.stop()

        if let recordingUrl = recorder?.url, CBFileManager.shared().fileExists(recordingUrl.path) {
            if savingChanges {
                delegate?.add(Sound(name: kLocalizedRecording, fileName: recordingUrl.lastPathComponent))
            } else {
                recorder?.deleteRecording()
            }
        }

        navigationController?.popViewController(animated: true)
    }

    // MARK: Delegates

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordButton.setBackgroundImage(recordIcon, for: .normal)
        recordButton.isEnabled = false

        if !flag {
            Util.alert(title: kLocalizedError, text: kLocalizedMemoryWarning)
        }
    }
}
