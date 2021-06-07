/**
 *  The MIT License (MIT)
 *
 *  Copyright (c) 2016 David Dias
 *  https://github.com/NeoTeo/fingerprinter-chromaprint
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

import AVFoundation
import Chromaprint

class ChromaprintAudioDecoder {

    public  func decodeAudio(
        _ fromUrl: URL,
        withMaxLength maxLength: Int ,
        forContext context: OpaquePointer) -> Double {

        let asset = AVURLAsset(url: fromUrl)
        let reader: AVAssetReader

        do {
            reader = try AVAssetReader(asset: asset)
        } catch {
            print("Error: Can not initialize asset reader")
            return 0
        }

        let audioTracks = asset.tracks(withMediaType: AVMediaType.audio)

        if audioTracks.isEmpty {
            print("Error: No audio tracks found")
            return 0
        }

        let outputSettings: [String: Int] = [AVFormatIDKey: Int(kAudioFormatLinearPCM), AVLinearPCMIsBigEndianKey: 0, /// little endian
            AVLinearPCMIsFloatKey: 0,                       /// signed integer
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsNonInterleaved: 0]                 /// is interleaved

        let audioTrack = audioTracks[0]
        let trackOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettings)

        /// Get the duration.
        let durationInSeconds = CMTimeGetSeconds(audioTrack.timeRange.duration)

        var sampleRate: Int32?
        var sampleChannels: Int32?
        let descriptions = audioTrack.formatDescriptions

        for d in 0..<descriptions.count {
            let item = descriptions[d] as! CMAudioFormatDescription
            let desc = CMAudioFormatDescriptionGetStreamBasicDescription(item)?.pointee
            //print("so d is \(d) and desc.mSampleRate is \(desc.mSampleRate)")
            if desc?.mSampleRate != 0 {
                sampleRate = Int32((desc?.mSampleRate)!)
            }
            if desc?.mChannelsPerFrame != 0 {
                sampleChannels = Int32((desc?.mChannelsPerFrame)!)
            }
        }

        /// Sanity check
        guard let rate = sampleRate, let channels = sampleChannels else { return 0 }

        reader.add(trackOutput)
        reader.startReading()

        let sampleData = NSMutableData()
        var totalBuf: Int = 0

        /** Calculate remainingSamples as
         max length (in seconds) times number of samples read in a second.
         Sample rate is the number of samples per second
         and since we have two channels our number is
         max length * sample channels * sample rate
         */
        var remainingSamples = Int32(maxLength) * channels * rate

        /// start off chromaprint
        chromaprint_start(context, rate, channels)

        while reader.status == AVAssetReader.Status.reading {
            if let sampleBufferRef = trackOutput.copyNextSampleBuffer() {
                if let blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef) {

                    /// bufferLength is the total number of bytes in the buffer
                    /// Note that 16-bit samples are half that.
                    let bufferLength = CMBlockBufferGetDataLength(blockBufferRef)
                    totalBuf += bufferLength

                    /// Create a mutable data buffer of bufferLength bytes
                    let data = NSMutableData(length: bufferLength)

                    /// Copy bufferLength bytes from blockBufferRef into data
                    CMBlockBufferCopyDataBytes(
                        blockBufferRef,         /// source buffer
                        atOffset: 0,                      /// offset from start
                        dataLength: bufferLength,           /// number of bytes to copy
                        destination: data!.mutableBytes)     /// destination buffer

                    let opaquePtr = OpaquePointer(data!.mutableBytes)
                    let samples = UnsafePointer<Int16>(opaquePtr)

                    /**
                     *  - ctx: Chromaprint context pointer
                     *  - data: raw audio data, should point to an array of 16-bit signed
                     *          integers in native byte-order
                     *  - size: size of the data buffer
                     (in samples, so divide by 2 - should use bitdepth val instead)
                     sampleCount already accounts for both channels since it is calculated
                     from the number of bytes read.
                     Each channel's sample count would be:
                     bytes per channel = bytes read divided by two
                     samples per channel = bytes per channel divided by two (for 16-bit samples)
                     
                     a shortcut is bufferLength>>2
                     */
                    let sampleCount = Int32(bufferLength >> 1)

                    /// pick the smaller of the two values so we don't remove too much
                    let length = min(remainingSamples, sampleCount)

                    chromaprint_feed(context, samples, length)

                    sampleData.append(samples, length: bufferLength)
                    CMSampleBufferInvalidate(sampleBufferRef)

                    /// Cut short if we've set a maxLength
                    if maxLength != 0 {
                        remainingSamples -= length
                        if remainingSamples <= 0 {
                            break
                        }
                    }
                }
            }
        }

        chromaprint_finish(context)
        return durationInSeconds
    }
}
