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

extension AudioManager: AudioManagerProtocol {
    private var noiseRecogniserTimeIntervalInSeconds: Double { get { return 0.05 } }
    private var noiseRecorderChannel: Int { get { return 0 } }
    
    func startLoudnessRecorder() -> Void {
        if self.recorder == nil {
            self.initRecorder()
        }
        
        self.loudnessTimer = Timer.scheduledTimer(timeInterval: noiseRecogniserTimeIntervalInSeconds,
                                                  target: self,
                                                  selector: #selector(self.programTimerCallback),
                                                  userInfo: nil,
                                                  repeats: true)
        
        self.recorder.isMeteringEnabled = true
        self.recorder.record()
    }
    
    func stopLoudnessRecorder() -> Void {
        if self.recorder != nil {
            self.recorder.stop()
            self.recorder = nil
        }
        
        if self.loudnessTimer != nil {
            self.loudnessTimer.invalidate()
            self.loudnessTimer = nil
        }
    }
    
    func pauseLoudnessRecorder() -> Void {
        self.recorder?.pause()
    }
    
    func resumeLoudnessRecorder() -> Void {
        self.recorder?.record()
    }
    
    func loudness() -> Double? {
        if self.loudnessInDecibels == nil || self.recorder == nil {
            return nil // no sound
        }
        return self.loudnessInDecibels as? Double
    }
    
    func initRecorder() {
        let url = URL(fileURLWithPath: "/dev/null")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 0,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ] as [String : Any]
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(true)
        try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        try! self.recorder = AVAudioRecorder(url: url, settings: settings)
    }
    
    @objc func programTimerCallback() {
        guard let recorder = self.recorder else { return }
        recorder.updateMeters()
        
        self.loudnessInDecibels = recorder.averagePower(forChannel: noiseRecorderChannel) as NSNumber
    }
    
    func loudnessAvailable() -> Bool {
        var isGranted = false
        let dispatchGroup = DispatchGroup()
        
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.denied:
            isGranted = false
        case AVAudioSessionRecordPermission.undetermined:
            dispatchGroup.enter()
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted: Bool) in
                isGranted = granted
                dispatchGroup.leave()
            })
            dispatchGroup.wait()
        case AVAudioSessionRecordPermission.granted:
            isGranted = true
        }
        
        if isGranted && self.recorder == nil {
            self.initRecorder()
            return self.recorder.prepareToRecord()
        }
        
        return isGranted
    }
}
