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

import AudioKit
import Foundation

class Sampler: AKSampler {

    var activeNotes = [Int: Set<Note>]()
    let playingQueue = DispatchQueue(label: "SamplerPlayingQueue")
    let type: SamplerType
    var isDiscarded = false

    init(type: SamplerType) {
        self.type = type
        super.init()
    }

    func playNote(_ newNote: Note) {
        _ = playingQueue.sync {
            if !self.isDiscarded {
                var notesWithSamePitch = activeNotes[newNote.pitch] ?? Set<Note>()

                // Only one note of the same pitch can play at the same time (restriction of sampler).
                // We don't have to send a noteOff event for older notes of the same pitch in the
                // "play note" or "play drum" instruction after the durationTimer has fired because the
                // noteOff event was automatically triggered when the new note of the same pitch was played.
                // the "isSilent" property determines whether a noteOff event has to be sent at the end of
                // the instruction.
                for note in notesWithSamePitch {
                    note.isSilent = true
                }

                notesWithSamePitch.insert(newNote)
                activeNotes[newNote.pitch] = notesWithSamePitch
                play(noteNumber: UInt8(newNote.pitch), velocity: 127)
            }
        }
    }

    func stopNote(_ note: Note) {
        _ = playingQueue.sync {
            if !self.isDiscarded {
                if !note.isSilent {
                    stop(noteNumber: UInt8(note.pitch))
                }
                if var notesWithSamePitch = activeNotes[note.pitch] {
                    notesWithSamePitch.remove(note)
                    activeNotes[note.pitch] = notesWithSamePitch
                }
            }
        }
    }

    func pauseSampler() {
        stopAllVoices()
    }

    func resumeSampler() {
        restartVoices()
    }

    func stopSampler() {
        activeNotes.removeAll()
        stopAllVoices()
    }

    func remove() {
        _ = playingQueue.sync {
            self.isDiscarded = true
            stopSampler()
            self.detach()
        }
    }
}
