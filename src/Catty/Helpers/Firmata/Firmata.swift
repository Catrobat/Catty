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
import Foundation

// message command bytes (128-255/0x80-0xFF)
let kSTART_SYSEX: UInt8 = 0xF0
let kSET_PIN_MODE: UInt8 = 0xF4
let kRESET: UInt8 = 0xFF
let kEND_SYSEX: UInt8 = 0xF7
let kREPORT_VERSION: UInt8 = 0xF9 // report firmware version

// extended command set using sysex (0-127/0x00-0x7F)
/* 0x00-0x0F reserved for user-defined commands */
let kREPORT_ANALOG: UInt8 = 0xC0 // query for analog pin
let kREPORT_DIGITAL: UInt8 = 0xD0 // query for digital pin
let kANALOG_MESSAGE: UInt8 = 0xE0 // data for a analog pin

let kREPORT_FIRMWARE: UInt8 = 0x79 // report name and version of the firmware
let kDIGITAL_MESSAGE: UInt8 = 0x90 // data for a digital port

let kRESERVED_COMMAND: UInt8 = 0x00 // 2nd SysEx data byte is a chip-specific command (AVR, PIC, TI, etc).
let kANALOG_MAPPING_QUERY: UInt8 = 0x69 // ask for mapping of analog to pin numbers
let kANALOG_MAPPING_RESPONSE: UInt8 = 0x6A // reply with mapping info
let kCAPABILITY_QUERY: UInt8 = 0x6B // ask for supported modes and resolution of all pins
let kCAPABILITY_RESPONSE: UInt8 = 0x6C // reply with supported modes and resolution
let kPIN_STATE_QUERY: UInt8 = 0x6D // ask for a pin's current mode and value
let kPIN_STATE_RESPONSE: UInt8 = 0x6E // reply with a pin's current mode and value
let kEXTENDED_ANALOG: UInt8 = 0x6F // analog write (PWM, Servo, etc) to any pin
let kSERVO_CONFIG: UInt8 = 0x70 // set max angle, minPulse, maxPulse, freq
let kSTRING_DATA: UInt8 = 0x71 // a string message with 14-bits per char
let kSHIFT_DATA: UInt8 = 0x75 // shiftOut config/data message (34 bits)
let kI2C_REQUEST: UInt8 = 0x76 // I2C request messages from a host to an I/O board
let kI2C_REPLY: UInt8 = 0x77 // I2C reply messages from an I/O board to a host
let kI2C_CONFIG: UInt8 = 0x78 // Configure special I2C settings such as power pins and delay times
let kSAMPLING_INTERVAL: UInt8 = 0x7A // sampling interval
let kSYSEX_NON_REALTIME: UInt8 = 0x7E // MIDI Reserved for non-realtime messages
let kSYSEX_REALTIME: UInt8 = 0x7F // MIDI Reserved for realtime messages

enum PinState: Int {
    case low = 0
    case high
}

enum PinMode: Int {
    case unknown = -1
    case input
    case output
    case analog
    case pwm
    case servo
    case shift
    case i2C
}

class Firmata: FirmataProtocol {

    private let FIRST_DIGITAL_PIN = 3
    private let LAST_DIGITAL_PIN = 8
    private let FIRST_ANALOG_PIN = 14
    private let LAST_ANALOG_PIN = 19
    private let PORT_COUNT = 3

    private var portMasks = [UInt8](repeating: 0, count: 3)
    weak var delegate: FirmataDelegate?
    private var sysexData = NSMutableData()
    private var seenStartSysex: Bool = false

    // MARK: WRITE
    /* PINMODE
     * -------------------------------
     * 0  kSET_PIN_MODE (0xF4)
     * 1  pin (0 to 127)
     * 2  PinMode (rawValue)
     */
    func writePinMode(_ newMode: PinMode, pin: UInt8) {

        //Set a pin's mode

        let data0: UInt8 = kSET_PIN_MODE        //Status byte == 244
        let data1: UInt8 = pin        //Pin#
        let data2 = UInt8(newMode.rawValue)    //Mode

        let bytes: [UInt8] = [data0, data1, data2]
        let newData = Data(bytes: UnsafePointer<UInt8>(bytes), count: 3)

        delegate?.sendData(newData)
    }

    /*Report Version
     * -------------------------------
     * 0  REPORT_VERSION //0xF9
     */
    func reportVersion() {

        let data0: UInt8 = kREPORT_VERSION //0xF9
        let bytes: [UInt8] = [data0]
        let newData = Data(bytes: UnsafePointer<UInt8>(bytes), count: 1)

        print("reportVersion bytes in hex \(newData.description)")
        delegate?.sendData(newData)
    }
    /*Report Version
     * -------------------------------
     * 0  kSTART_SYSEX 0xF0
     * 0  REPORT_FIRMWARE 0x79
     * 0  END_SYSEX 0xF7
     */
    func reportFirmware() {
        let data0: UInt8 = kSTART_SYSEX
        let data1: UInt8 = kREPORT_FIRMWARE
        let data2: UInt8 = kEND_SYSEX
        let bytes: [UInt8] = [data0, data1, data2]
        let newData = Data(bytes: UnsafePointer<UInt8>(bytes), count: 3)
        print("reportFirmware bytes in hex \(newData.description)")
        delegate?.sendData(newData)
    }

    /* analog mapping query
     * -------------------------------
     * 0  kSTART_SYSEX (0xF0)
     * 1  analog mapping query (0x69)
     * 2  END_SYSEX (0xF7)
     */
    func analogMappingQuery() {
        let data0: UInt8 = kSTART_SYSEX
        let data1: UInt8 = kANALOG_MAPPING_QUERY
        let data2: UInt8 = kEND_SYSEX
        let bytes: [UInt8] = [data0, data1, data2]
        let newData = Data(bytes: UnsafePointer<UInt8>(bytes), count: 3)
        print("analogMappingQuery bytes in hex \(newData.description)")
        delegate?.sendData(newData)
    }

    /* capabilities query
     * -------------------------------
     * 0  kSTART_SYSEX (0xF0)
     * 1  capabilities query (0x6B)
     * 2  END_SYSEX (0xF7)
     */
    func capabilityQuery() {
        let data0: UInt8 = kSTART_SYSEX
        let data1: UInt8 = kCAPABILITY_QUERY
        let data2: UInt8 = kEND_SYSEX
        let bytes: [UInt8] = [data0, data1, data2]
        let newData = Data(bytes: UnsafePointer<UInt8>(bytes), count: 3)
        print("capabilityQuery bytes in hex \(newData.description)")
        delegate?.sendData(newData)
    }

    /* pin state query
     * -------------------------------
     * 0  kSTART_SYSEX (0xF0)
     * 1  pin state query (0x6D)
     * 2  pin (0 to 127)
     * 3  END_SYSEX (0xF7)
     */
    func pinStateQuery(_ pin: UInt8) {
        let data0: UInt8 = kSTART_SYSEX
        let data1: UInt8 = kPIN_STATE_QUERY
        let data2: UInt8 = pin
        let data3: UInt8 = kEND_SYSEX
        let bytes: [UInt8] = [data0, data1, data2, data3]
        let newData = Data(bytes: UnsafePointer<UInt8>(bytes), count: 4)
        print("pinStateQuery bytes in hex \(newData.description)")
        delegate?.sendData(newData)
    }

    /* servo config
     * --------------------
     * 0  kSTART_SYSEX (0xF0)
     * 1  SERVO_CONFIG (0x70)
     * 2  pin number (0-127)
     * 3  minPulse LSB (0-6)
     * 4  minPulse MSB (7-13)
     * 5  maxPulse LSB (0-6)
     * 6  maxPulse MSB (7-13)
     * 7  END_SYSEX (0xF7)
     */
    func servoConfig(_ pin: UInt8, minPulse: UInt8, maxPulse: UInt8) {
        let data0: UInt8 = kSTART_SYSEX
        let data1: UInt8 = kSERVO_CONFIG //TODO: check with PIN
        let data2: UInt8 = pin
        let data3: UInt8 = minPulse & 0x7F
        let data4: UInt8 = minPulse >> 7
        let data5: UInt8 = maxPulse & 0x7F
        let data6: UInt8 = maxPulse >> 7
        let data7: UInt8 = kEND_SYSEX
        let bytes: [UInt8] = [data0, data1, data2, data3, data4, data5, data6, data7]
        let newData = Data(bytes: UnsafePointer<UInt8>(bytes), count: 8)
        print("servoConfig bytes in hex \(newData.description)")
        delegate?.sendData(newData)
    }

    /* servo config
     * --------------------
     * 0  kSTART_SYSEX (0xF0)
     * 1  STRING_DATA (0x71)
     * *  data needed for string
     * 7  END_SYSEX (0xF7)
     */
    func stringData(_ string: String) {
        let data0: UInt8 = kSTART_SYSEX
        let data1: UInt8 = kSTRING_DATA
        let bytes1: [UInt8] = [data0, data1]
        var newData = Data(bytes: bytes1, count: 2)

        guard let data = string.data(using: String.Encoding.ascii) else { return }

        let count = data.count / MemoryLayout<UInt8>.size
        var bytes = [UInt8](repeating: 0, count: count)
        (data as NSData).getBytes(&bytes, length: count * MemoryLayout<UInt8>.size)

        //        for (var i = 0; i < data.length; i++){
        //            let lsb = bytes[i] & 0x7f;
        //            let msb = bytes[i] >> 7  & 0x7f;
        //
        //            let append1:UInt8 = lsb
        //            let append2:UInt8 = msb
        //            let appendData:[UInt8] = [append1,append2]
        //            newData.appendData(NSData(bytes: appendData, length: 2))
        //        }
        //
        //        //issue #72 and #50 on firmata, will be fixed in 2.4
        //        let end1:UInt8 = 0
        //        let end2:UInt8 = 0
        for i in 0 ..< data.count {
            let lsb = bytes[i] & 0x7f
            let append1: UInt8 = lsb
            let appendData: [UInt8] = [append1]
            newData.append(Data(bytes: UnsafePointer<UInt8>(appendData), count: 1))

        }
        let end3: UInt8 = kEND_SYSEX
        let endData: [UInt8] = [end3]
        newData.append(Data(bytes: UnsafePointer<UInt8>(endData), count: 1))

        print("stringdata bytes in hex \(newData.description)")
        delegate?.sendData(newData)
    }

    /* Set sampling interval
     * -------------------------------
     * 0  kSTART_SYSEX (0xF0)
     * 1  SAMPLING_INTERVAL (0x7A)
     * 2  sampling interval on the millisecond time scale (LSB)
     * 3  sampling interval on the millisecond time scale (MSB)
     * 4  END_SYSEX (0xF7)
     */
    func samplingInterval(_ intervalMilliseconds: UInt8) {
        let data0: UInt8 = kSTART_SYSEX
        let data1: UInt8 = kSAMPLING_INTERVAL
        let data2: UInt8 = intervalMilliseconds & 0x7f
        let data3: UInt8 = (intervalMilliseconds >> 7)
        let data4: UInt8 = kEND_SYSEX
        let bytes: [UInt8] = [data0, data1, data2, data3, data4]
        let newData = Data(bytes: UnsafePointer<UInt8>(bytes), count: 5)
        print("samplingInterval bytes in hex \(newData.description)")
        delegate?.sendData(newData)
    }

    /* WritePWM
     * -------------------------------
     * 0  ANALOG_MESSAGE (0xE0) + pin
     * 1  value (LSB)
     * 2  value (MSB)
     */
    func writePWMValue(_ value: UInt8, pin: UInt8) {

        //Set an PWM output pin's value

        var data0: UInt8  //Status
        var data1: UInt8  //LSB of bitmask
        var data2: UInt8  //MSB of bitmask

        //Analog (PWM) I/O message
        data0 = kANALOG_MESSAGE + pin
        data1 = value & 0x7F;   //only 7 bottom bits
        data2 = value >> 7;     //top bit in second byte // &0x7f ??

        let bytes: [UInt8] = [data0, data1, data2]
        let newData = Data(bytes: UnsafePointer<UInt8>(bytes), count: 3)

        delegate?.sendData(newData)

    }

    /* WriteDigitalState
     * -------------------------------
     * 0  DIGITAL_MESSAGE (0x90) + port
     * 1  portmask (LSB)
     * 2  portmask (MSB)
     */
    func writePinState(_ newState: PinState, pin: UInt8) {

        //Set an output pin's state

        var data0: UInt8  //Status
        var data1: UInt8  //LSB of bitmask
        var data2: UInt8  //MSB of bitmask

        //Status byte == 144 + port#
        let port: UInt8 = pin / 8

        data0 = kDIGITAL_MESSAGE + port

        //Data1 == pin0State + 2*pin1State + 4*pin2State + 8*pin3State + 16*pin4State + 32*pin5State
        let pinIndex: UInt8 = pin - (port * 8)
        var newMask = UInt8(newState.rawValue * Int(powf(2, Float(pinIndex))))

        if port == 0 {
            portMasks[Int(port)] &= ~(1 << pinIndex) //prep the saved mask by zeroing this pin's corresponding bit
            newMask |= portMasks[Int(port)] //merge with saved port state
            portMasks[Int(port)] = newMask
            data1 = newMask<<1; data1 >>= 1  //remove MSB
            data2 = newMask >> 7 //use data1's MSB as data2's LSB
        } else {
            portMasks[Int(port)] &= ~(1 << pinIndex) //prep the saved mask by zeroing this pin's corresponding bit
            newMask |= portMasks[Int(port)] //merge with saved port state
            portMasks[Int(port)] = newMask
            data1 = newMask
            data2 = 0

            //Hack for firmata pin15 reporting bug?
            if port == 1 {
                data2 = newMask >> 7
                data1 &= ~(1 << 7)
            }
        }

        let bytes: [UInt8] = [data0, data1, data2]
        let newData = Data(bytes: UnsafePointer<UInt8>(bytes), count: 3)
        delegate?.sendData(newData)

        print(self, "setting pin states -->", "[\(binaryforByte(portMasks[0]))] [\(binaryforByte(portMasks[1]))] [\(binaryforByte(portMasks[2]))]")

    }

    /* Analog Reporting
     * -------------------------------
     * 0  REPORT_ANALOG (0xC0) + pin
     * 1  enabled (0/1)
     */
    func setAnalogValueReportingforPin(_ pin: UInt8, enabled: Bool) {

        //Enable analog read for a pin
        //Enable by pin
        let data0: UInt8 = kREPORT_ANALOG + UInt8(pin)          //start analog reporting for pin (192 + pin#)
        var data1: UInt8 = 0    //Enable
        if enabled { data1 = 1 }

        let bytes: [UInt8] = [data0, data1]

        let newData = Data(bytes: UnsafePointer<UInt8>(bytes), count: 2)

        delegate?.sendData(newData)
    }

    /* Digital Pin Reporting
     * -------------------------------
     * 0  REPORT_DIGITAL (0xD0) + port
     * 1  enabled (0/1)
     */
    func setDigitalStateReportingForPin(_ digitalPin: UInt8, enabled: Bool) {

        //Enable input/output for a digital pin
        //find port for pin
        var port: UInt8
        var pin: UInt8

        port = digitalPin / 8
        pin = digitalPin % 8

        let data0: UInt8 = kREPORT_DIGITAL + port        //start port 0 digital reporting (0xd0 + port#)
        var data1 = UInt8(portMasks[Int(port)])    //retrieve saved pin mask for port;

        if enabled {
            data1 |= 1 << pin
        } else {
            data1 ^= 1 << pin
        }

        let bytes: [UInt8] = [data0, data1]
        let newData = Data(bytes: UnsafePointer<UInt8>(bytes), count: 2)

        portMasks[Int(port)] = data1    //save new pin

        delegate?.sendData(newData)

    }

    /* Digital Port Reporting
     * -------------------------------
     * 0  REPORT_DIGITAL (0xD0) + port
     * 1  enabled (0/1)
     */
    func setDigitalStateReportingForPort(_ port: UInt8, enabled: Bool) {

        //Enable input/output for a digital pin
        //Enable by port
        let data0: UInt8 = kREPORT_DIGITAL + port  //start port 0 digital reporting (207 + port#)
        var data1: UInt8 = 0 //Enable
        if enabled { data1 = 1 }

        let bytes: [UInt8] = [data0, data1]
        let newData = Data(bytes: UnsafePointer<UInt8>(bytes), count: 2)
        delegate?.sendData(newData)

    }

    func i2cConfig(_ delay: UInt8, data: Data) {

        var data0: UInt8
        var data1: UInt8
        var data2: UInt8
        var data3: UInt8

        data0 = kSTART_SYSEX
        data1 = kI2C_CONFIG
        data2 = delay
        data3 = delay >> 8

        var bytes: [UInt8] = [data0, data1, data2, data3]
        var newData = Data(bytes: bytes, count: 4)

        let count = data.count / MemoryLayout<UInt8>.size
        bytes = [UInt8](repeating: 0, count: count)
        (data as NSData).getBytes(&bytes, length: count * MemoryLayout<UInt8>.size)

        for i in 0 ..< data.count {
            let lsb: UInt8 = bytes[i] & 0x7f
            let msb: UInt8 = bytes[i] >> 7 & 0x7f

            let append: [UInt8] = [lsb, msb]
            newData.append(Data(bytes: UnsafePointer<UInt8>(append), count: 2))
        }

        data0 = kEND_SYSEX
        let append: [UInt8] = [data0]
        newData.append(Data(bytes: UnsafePointer<UInt8>(append), count: 1))

        delegate?.sendData(newData)
    }

    /* I2C read/write request
     * -------------------------------
     * 0  kSTART_SYSEX (0xF0) (MIDI System Exclusive)
     * 1  I2C_REQUEST (0x76)
     * 2  slave address (LSB)
     * 3  slave address (MSB) + read/write and address mode bits
     {7: always 0} + {6: reserved} + {5: address mode, 1 means 10-bit mode} +
     {4-3: read/write, 00 => write, 01 => read once, 10 => read continuously, 11 => stop reading} +
     {2-0: slave address MSB in 10-bit mode, not used in 7-bit mode}
     * 4  data 0 (LSB)
     * 5  data 0 (MSB)
     * 6  data 1 (LSB)
     * 7  data 1 (MSB)
     * ...
     * n  END_SYSEX (0xF7)
     */
    //    func i2cRequest:(I2CMODE)i2cMode address:(unsigned short int)address data:(NSData *)data selector:(SEL)aSelector
    //    {
    //
    //    const unsigned char first[] = {kSTART_SYSEX, I2C_REQUEST, address, i2cMode};
    //    NSMutableData *dataToSend = [[NSMutableData alloc] initWithBytes:first length:sizeof(first)];
    //
    //    // need to split this data into msb and lsb
    //    const unsigned char *bytes = [data bytes];
    //
    //    for (int i = 0; i < [data length]; i++)
    //    {
    //    unsigned char lsb = bytes[i] & 0x7f;
    //    unsigned char msb = bytes[i] >> 7  & 0x7f;
    //
    //    const unsigned char append[] = { lsb, msb };
    //    [dataToSend appendBytes:append length:sizeof(append)];
    //    }
    //
    //    const unsigned char end[] = {END_SYSEX};
    //    [dataToSend appendBytes:end length:sizeof(end)];
    //
    //    NSLog(@"i2cRequest bytes in hex: %@", [dataToSend description]);
    //
    //    if(aSelector)
    //    [selectorQueue enqueue:NSStringFromSelector(aSelector)];
    //    else
    //    [selectorQueue enqueue:[[NSString alloc] init]];
    //    [currentlyDisplayingService write:dataToSend];
    //    }

    // MARK: RECEIVE
    /** Received data */
    func receiveData(_ data: Data) {

        //data may or may not be a whole (or a single) command
        //unless jumbled, sysex bytes should never occur in data stream
        let count = data.count / MemoryLayout<UInt8>.size
        var bytes = [UInt8](repeating: 0, count: count)
        (data as NSData).getBytes(&bytes, length: count * MemoryLayout<UInt8>.size)
        for i in 0 ..< data.count {
            let byte: UInt8 = bytes[i]

            if byte == kSTART_SYSEX {
                print("Start sysex received, clear data")
                sysexData.length = 0
                sysexData.append(&bytes[i], length: 1)
                seenStartSysex = true

            } else if byte == kEND_SYSEX {
                sysexData.append(&bytes[i], length: 1)

                print("End sysex received")
                seenStartSysex = false
                let sysexCount = data.count / MemoryLayout<UInt8>.size
                var firmataDataBytes = [UInt8](repeating: 0, count: sysexCount)
                sysexData.getBytes(&firmataDataBytes, length: sysexCount * MemoryLayout<UInt8>.size)

                print("Sysex Command byte is %02hhx", firmataDataBytes[1])
                if firmataDataBytes.count < 2 {
                    return
                }
                switch firmataDataBytes[1] {
                case kANALOG_MAPPING_RESPONSE:
                    parseAnalogMappingResponse(sysexData as Data)
                case kCAPABILITY_RESPONSE:
                    parseCapabilityResponse(sysexData as Data)
                case kPIN_STATE_RESPONSE:
                    parsePinStateResponse(sysexData as Data)
                case kREPORT_FIRMWARE:
                    print("type of message is firmware report")
                    parseReportFirmwareResponse(sysexData as Data)
                case kSTRING_DATA:
                    parseStringData(sysexData as Data)
                default:
                    print("type of message unknown")
                }
                sysexData.length = 0
                break

            } else if seenStartSysex {
                print("In sysex, appending waiting for end sysex %c", byte)
                sysexData.append(&bytes[i], length: 1)

            } else {
                //Respond to incoming data

                var buf = [UInt8](repeating: 0, count: 512)  //static only works on classes & structs in swift
                var length: Int = 0                               //again, was static
                let dataLength: Int = data.count

                if dataLength < 20 {

                    memcpy(&buf, bytes, Int(dataLength))

                    length += dataLength
                    processInputData(buf, length: length)
                    length = 0
                } else if dataLength == 20 {

                    memcpy(&buf, bytes, 20)
                    length += dataLength

                    if length >= 64 {
                        processInputData(buf, length: length)
                        length = 0
                    }
                }
            }
        }
    }

    private func processInputData(_ data: [UInt8], length: Int) {

        //Parse data we received

        print(self, "received data", "data = \(data[0]) : length = \(length)")

        //each message is 3 bytes long
        var i = 0
        while i < length {
            //Digital Reporting (per port)
            //Port 0
            if data[i] == kDIGITAL_MESSAGE {
                var pinStates = Int(data[i + 1])
                pinStates |= Int(data[i + 2]) << 7    //use LSB of third byte for pin7
                updateForPinStates(pinStates, port: 0)
                return
            }

                //Port 1
            else if data[i] == 0x91 {
                var pinStates = Int(data[i + 1])
                pinStates |= Int(data[i + 2]) << 7  //pins 14 & 15
                updateForPinStates(pinStates, port: 1)
                return
            }

                //Port 2
            else if data[i] == 0x92 {
                let pinStates = Int(data[i + 1])
                updateForPinStates(pinStates, port: 2)
                return
            }

                //Analog Reporting (per pin)
            else if (data[i] >= kANALOG_MESSAGE) && (data[i] <= 0xe5) {

                let pin = Int(data[i]) - 0xe0 + FIRST_ANALOG_PIN
                let val = Int(data[i + 1]) + (Int(data[i + 2]) << 7)

                print("\(pin):\(val)")

                delegate?.didReceiveAnalogMessage(pin, value: val)

            } else if data[i] == kREPORT_VERSION {
                print("Report Version")
                let bytes: [UInt8] = [data[i], data[i + 1], data[i + 2]]
                parseReportVersionResponse(Data(bytes: UnsafePointer<UInt8>(bytes), count: 3))
            }

            i += 3
        }
    }

    private func updateForPinStates(_ pinStates: Int, port: Int) {
        print(self, "getting pin states <--", "[\(binaryforByte(portMasks[0]))] [\(binaryforByte(portMasks[1]))] [\(binaryforByte(portMasks[2]))]")
        let offset = 8 * port

        var portData: [Int] = []
        //Iterate through all  pins
        for i in 0 ... 7 {
            var state = pinStates
            let mask = 1 << i
            state = state & mask
            state = state >> i

            let pin = i + Int(offset)
            delegate?.didReceiveDigitalMessage(pin, value: state)
            portData.append(state)
        }

        //Save reference state mask
        portMasks[port] = UInt8(pinStates)
        delegate?.didReceiveDigitalPort(port, portData: portData)
    }

    // MARK: PARSE

    /* Receive Firmware Name and Version (after query)
     * 0  kSTART_SYSEX (0xF0)
     * 1  STRING_DATA (0x71)
     * 2  first character LSB (0-6)
     * 3  first character MSB (7-13)
     * x  ...for as many bytes as it needs)
     * 4  END_SYSEX (0xF7)
     */
    private func parseStringData(_ data: Data) {
        let nameData = data[2..<data.count - 1]
        if let name = String(data: nameData, encoding: String.Encoding.ascii) {
            delegate?.stringDataReceived(name)
        }
    }

    /* Receive Firmware Name and Version (after query)
     * 0  kSTART_SYSEX (0xF0)
     * 1  queryFirmware (0x79)
     * 2  major version (0-127)
     * 3  minor version (0-127)
     * 4  first 7-bits of firmware name
     * 5  second 7-bits of firmware name
     * x  ...for as many bytes as it needs)
     * 6  END_SYSEX (0xF7)
     */
    private func parseReportFirmwareResponse(_ data: Data) {
        let nameData = data[4..<data.count - 1]
        if let name = String(data: nameData, encoding: String.Encoding.ascii) {
            delegate?.firmwareVersionReceived(name + " \(data[2])." + "\(data[3])")
        }
    }

    /* version report format
     * -------------------------------------------------
     * 0  version report header (0xF9)
     * 1  major version (0-127)
     * 2  minor version (0-127)
     */
    private func parseReportVersionResponse(_ data: Data) {
        delegate?.protocolVersionReceived("\(data[1])," + "\(data[2])")
    }

    /* pin state response
     * -------------------------------
     * 0  kSTART_SYSEX (0xF0)
     * 1  pin state response (0x6E)
     * 2  pin (0 to 127)
     * 3  pin mode (the currently configured mode)
     * 4  pin state, bits 0-6
     * 5  (optional) pin state, bits 7-13
     * 6  (optional) pin state, bits 14-20
     ...  additional optional bytes, as many as needed
     * N  END_SYSEX (0xF7)
     The pin "state" is any data written to the pin. For output modes (digital output, PWM, and Servo), the state is any value that has been previously written to the pin. A GUI needs this state to properly initialize any on-screen controls, so their initial settings match whatever the pin is actually doing. For input modes, typically the state is zero. However, for digital inputs, the state is the status of the pullup resistor.
     */
    private func parsePinStateResponse(_ data: Data) {
        let pin = data[2]
        let currentMode = data[3]
        let value = data[4] & 0x7F
        let port = pin / 8
        print("Pin: %i, Mode: %i, Value %i", pin, currentMode, value)
        print("Setting Pin %i for port %i", pin, port)

        //check if if its digital

        //    @try {
        //        unsigned short int mask = [(NSNumber*)[ports objectAtIndex:port] unsignedShortValue];
        //        [ports insertObject:[NSNumber numberWithUnsignedChar:mask & ~(value<<(pin % 8))] atIndex:port];
        //
        //    }
        //    @catch (NSException *exception) {
        //    }
        //    @finally {
        //        [ports insertObject:[NSNumber numberWithUnsignedChar:value<<(pin % 8)] atIndex:port];
        //    }

        //   TODO:
        //    [peripheralDelegate didUpdatePin:pin currentMode:(PINMODE)currentMode value:value];
    }

    /* analog mapping response
     * -------------------------------
     * 0  kSTART_SYSEX (0xF0)
     * 1  analog mapping response (0x6A)
     * 2  analog channel corresponding to pin 0, or 127 if pin 0 does not support analog
     * 3  analog channel corresponding to pin 1, or 127 if pin 1 does not support analog
     * 4  analog channel corresponding to pin 2, or 127 if pin 2 does not support analog
     ...   etc, one byte for each pin
     * N  END_SYSEX (0xF7)
     */
    private func parseAnalogMappingResponse(_ data: Data) {
        var analogMapping = [UInt8: UInt8]()
        var j = UInt8(0)
        let length = data.count - 1
        for i in 2 ..< length {
            if data[i] != 127 {
                analogMapping[data[i]] = j
            }
            j += 1
        }
        print("Analog Mapping Response %@", analogMapping)
        delegate?.didUpdateAnalogMapping(NSMutableDictionary(dictionary: analogMapping))
    }

    /* capabilities response
     * -------------------------------
     * 0  kSTART_SYSEX (0xF0)
     * 1  capabilities response (0x6C)
     * 2  1st mode supported of pin 0
     * 3  1st mode's resolution of pin 0
     * 4  2nd mode supported of pin 0
     * 5  2nd mode's resolution of pin 0
     ...   additional modes/resolutions, followed by a single 127 to mark the
     end of the first pin's modes.  Each pin follows with its mode and
     127, until all pins implemented.
     * N  END_SYSEX (0xF7)
     */
    private func parseCapabilityResponse(_ data: Data) {

        var pins = [[Int: Int]]()

        var j: UInt8 = 0

        let count = data.count / MemoryLayout<UInt8>.size
        var bytes = [UInt8](repeating: 0, count: count)
        (data as NSData).getBytes(&bytes, length: count * MemoryLayout<UInt8>.size)

        //start at 2 to ditch start and command byte
        //take end byte off the end
        var i = 2
        while i < (data.count - 1) {
            //ugh altering i inside of loop...
            var modes = [Int: Int]()

            while bytes[i] != 127 {
                let mode = bytes[i]
                i += 1
                let resolution = bytes[i]
                i += 1

                //                print("Pin %i  Mode: %02hhx Resolution:%02hhx", j, mode, resolution);
                modes[Int(mode)] = Int(resolution)
            }
            j += 1
            pins.append(modes)

            i += 1
        }

        print("Capability Response %@", pins)
        delegate?.didUpdateCapability(pins)
        //    [peripheralDelegate didUpdateCapability:(NSMutableArray*)pins];
    }

    // MARK: Helper
    private func pinStateForInt(_ stateInt: Int) -> PinState {

        var state: PinState

        switch stateInt {

        case PinState.high.rawValue:
            state = PinState.high
        case PinState.low.rawValue:
            state = .low
        default:
            state = PinState.high
        }

        return state
    }

    private func stringForPinMode(_ mode: PinMode) -> NSString {

        var modeString: NSString

        switch mode {
        case .input:
            modeString = "Input"
        case .output:
            modeString = "Output"
        case .analog:
            modeString = "Analog"
        case .pwm:
            modeString = "PWM"
        case .servo:
            modeString = "Servo"
        default:
            modeString = "NOT FOUND"
        }

        return modeString

    }

    private func binaryforByte(_ value: UInt8) -> String {

        var str = String(value, radix: 2)
        let len = str.count
        if len < 8 {
            var addzeroes = 8 - len
            while addzeroes > 0 {
                str = "0" + str
                addzeroes -= 1
            }
        }

        return str
    }

}
