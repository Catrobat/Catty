// swiftlint:disable all
//
//  Level.swift
//  Swell
//
//  Created by Hubert Rabago on 6/20/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

public typealias RawLevel = Int

public enum PredefinedLevel: RawLevel {
    case trace = 100
    case debug = 200
    case info = 300
    case warn = 400
    case error = 500
    case severe = 600
}

public struct LogLevel {
    var level: RawLevel
    var name: String
    var label: String

    static var allLevels = [RawLevel: LogLevel]()

    public static let TRACE = LogLevel.create(.trace, name: "trace", label: "TRACE")
    public static let DEBUG = LogLevel.create(.debug, name: "debug", label: "DEBUG")
    public static let INFO = LogLevel.create(.info, name: "info", label: " INFO")
    public static let WARN = LogLevel.create(.warn, name: "warn", label: " WARN")
    public static let ERROR = LogLevel.create(.error, name: "error", label: "ERROR")
    public static let SEVERE = LogLevel.create(.severe, name: "severe", label: "SEVERE")

    public init(level: RawLevel, name: String, label: String) {
        self.level = level
        self.name = name
        self.label = label
    }

    static func create(_ level: PredefinedLevel, name: String, label: String) -> LogLevel {
        let result = LogLevel(level: level.rawValue, name: name, label: label)
        //let key =
        allLevels[result.level] = result
        return result
    }

    public static func getLevel(_ level: PredefinedLevel) -> LogLevel {
        switch level {
        case .trace:
            return TRACE
        case .debug:
            return DEBUG
        case .info:
            return INFO
        case .warn:
            return WARN
        case .error:
            return ERROR
        case .severe:
            return SEVERE
        }
    }

    static func getLevel(_ levelName: String) -> LogLevel {
        // we access all levels to make sure they've all been initialized
        _ = [TRACE, DEBUG, INFO, WARN, ERROR, SEVERE]
        for level in allLevels.values where (level.name == levelName) {
            return level
        }
        return TRACE    // fallback option
    }

    public func description() -> String {
        return "LogLevel level=\(label)"
    }
}

//
//  Formatter.swift
//  Swell
//
//  Created by Hubert Rabago on 6/20/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//

/// A Log Formatter implementation generates the string that will be sent to a log location
/// if the log level requirement is met by a call to log a message.
public protocol LogFormatter {

    /// Formats the message provided for the given logger
    func formatLog<T>(_ logger: CBLogger, level: LogLevel, message: @autoclosure () -> T,
                      filename: String?, line: Int?, function: String?) -> String

    /// Returns an instance of this class given a configuration string
    static func logFormatterForString(_ formatString: String) -> LogFormatter

    /// Returns a string useful for describing this class and how it is configured
    func description() -> String
}

public enum QuickFormatterFormat: Int {
    case messageOnly = 0x0001
    case levelMessage = 0x0101
    case nameMessage = 0x0011
    case levelNameMessage = 0x0111
    case dateLevelMessage = 0x1101
    case dateMessage = 0x1001
    case all = 0x1111
}

/// QuickFormatter provides some limited options for formatting log messages.
/// Its primary advantage over FlexFormatter is speed - being anywhere from 20% to 50% faster
/// because of its limited options.
open class QuickFormatter: LogFormatter {

    let format: QuickFormatterFormat

    public init(format: QuickFormatterFormat = .levelNameMessage) {
        self.format = format
    }

    open func formatLog<T>(_ logger: CBLogger, level: LogLevel, message givenMessage: @autoclosure () -> T, filename: String?, line: Int?, function: String?) -> String {
        var s: String
        let message = givenMessage()
        switch format {
        case .levelNameMessage:
            s = "\(level.label) \(logger.name): \(message)"
        case .dateLevelMessage:
            s = "\(Date()) \(level.label): \(message)"
        case .messageOnly:
            s = "\(message)"
        case .nameMessage:
            s = "\(logger.name): \(message)"
        case .levelMessage:
            s = "\(level.label): \(message)"
        case .dateMessage:
            s = "\(Date()) \(message)"
        case .all:
            s = "\(Date()) \(level.label) \(logger.name): \(message)"
        }
        return s
    }

    open class func logFormatterForString(_ formatString: String) -> LogFormatter {
        var format: QuickFormatterFormat
        switch formatString {
        case "LevelNameMessage":
            format = .levelNameMessage
        case "DateLevelMessage":
            format = .dateLevelMessage
        case "MessageOnly":
            format = .messageOnly
        case "LevelMessage":
            format = .levelMessage
        case "NameMessage":
            format = .nameMessage
        case "DateMessage":
            format = .dateMessage
        default:
            format = .all
        }
        return QuickFormatter(format: format)
    }

    open func description() -> String {
        var s: String
        switch format {
        case .levelNameMessage:
            s = "LevelNameMessage"
        case .dateLevelMessage:
            s = "DateLevelMessage"
        case .messageOnly:
            s = "MessageOnly"
        case .levelMessage:
            s = "LevelMessage"
        case .nameMessage:
            s = "NameMessage"
        case .dateMessage:
            s = "DateMessage"
        case .all:
            s = "All"
        }
        return "QuickFormatter format=\(s)"
    }
}

public enum FlexFormatterPart: Int {
    case date
    case name
    case level
    case message
    case line
    case `func`
}

/// FlexFormatter provides more control over the log format, allowing
/// the flexibility to specify what data appears and on what order.
open class FlexFormatter: LogFormatter {
    var format: [FlexFormatterPart]

    public init(parts: FlexFormatterPart...) {
        format = parts
        // Same thing as below
        //format = [FlexFormatterPart]()
        //for part in parts {
        //    format += part
        //}
    }

    /// This overload is needed (as of Beta 3) because
    /// passing an array to a variadic param is not yet supported
    init(parts: [FlexFormatterPart]) {
        format = parts
    }

    func getFunctionFormat(_ function: String) -> String {
        var result = function
        if result.hasPrefix("Optional(") {
            let len = "Optional(".count
            let start = result.index(result.startIndex, offsetBy: len)
            let end = result.index(result.endIndex, offsetBy: -len)
            let range = start..<end
            result = String(result[range])
        }
        if (!result.hasSuffix(")")) {
            result += "()"
        }
        return result
    }

    open func formatLog<T>(_ logger: CBLogger, level: LogLevel, message givenMessage: @autoclosure () -> T, filename: String?, line: Int?, function: String?) -> String {
        var logMessage = ""
        for (index, part) in format.enumerated() {
            switch part {
            case .message:
                let message = givenMessage()
                logMessage += "\(message)"
            case .name:
                logMessage += logger.name
            case .level:
                logMessage += level.label
            case .date:
                logMessage += Date().description
            case .line:
                if let filename = filename, let line = line {
                    logMessage += "[\((filename as NSString).lastPathComponent):\(line)]"
                }
            case .func:
                if let function = function {
                    let output = getFunctionFormat(function)
                    logMessage += "[\(output)]"
                }
            }

            if index < format.count - 1 {
                if format[index + 1] == .message {
                    logMessage += ":"
                }
                logMessage += " "
            }
        }
        return logMessage
    }

    open class func logFormatterForString(_ formatString: String) -> LogFormatter {
        var formatSpec = [FlexFormatterPart]()
        let parts = formatString.uppercased().components(separatedBy: CharacterSet.whitespaces)
        for part in parts {
            switch part {
            case "MESSAGE":
                formatSpec += [.message]
            case "NAME":
                formatSpec += [.name]
            case "LEVEL":
                formatSpec += [.level]
            case "LINE":
                formatSpec += [.line]
            case "FUNC":
                formatSpec += [.func]
            default:
                formatSpec += [.date]
            }
        }
        return FlexFormatter(parts: formatSpec)
    }

    open func description() -> String {
        var desc = ""
        for (index, part) in format.enumerated() {
            switch part {
            case .message:
                desc += "MESSAGE"
            case .name:
                desc += "NAME"
            case .level:
                desc += "LEVEL"
            case .date:
                desc += "DATE"
            case .line:
                desc += "LINE"
            case .func:
                desc += "FUNC"
            }

            if index < format.count - 1 {
                desc += " "
            }
        }
        return "FlexFormatter with \(desc)"
    }

}

//
//  LogLocation.swift
//  Swell
//
//  Created by Hubert Rabago on 6/26/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//

public protocol LogLocation {
    //class func getInstance(param: AnyObject? = nil) -> LogLocation

    func log(_ message: @autoclosure () -> String)

    func enable()

    func disable()

    func description() -> String
}

open class ConsoleLocation: LogLocation {
    var enabled = true

    // Use the static-inside-class-var approach to getting a class var instance
    class var instance: ConsoleLocation {
        enum Static {
            static let internalInstance = ConsoleLocation()
        }
        return Static.internalInstance
    }

    open class func getInstance() -> LogLocation {
        return instance
    }

    open func log(_ message: @autoclosure () -> String) {
        if enabled {
            print(message())
        }
    }

    open func enable() {
        enabled = true
    }

    open func disable() {
        enabled = false
    }

    open func description() -> String {
        return "ConsoleLocation"
    }
}

// Use the globally-defined-var approach to getting a class var dictionary
var internalFileLocationDictionary = [String: FileLocation]()

open class FileLocation: LogLocation {
    var enabled = true
    var filename: String
    var fileHandle: FileHandle?

    open class func getInstance(_ filename: String) -> LogLocation {
        let temp = internalFileLocationDictionary[filename]
        if let result = temp {
            return result
        } else {
            let result = FileLocation(filename: filename)
            internalFileLocationDictionary[filename] = result
            return result
        }
    }

    init(filename: String) {
        self.filename = filename
        self.setDirectory()
        fileHandle = nil
        openFile()
    }

    deinit {
        closeFile()
    }

    open func log(_ message: @autoclosure () -> String) {
        //message.writeToFile(filename, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
        if !enabled {
            return
        }

        let output = message() + "\n"
        if let handle = fileHandle {
            handle.seekToEndOfFile()
            if let data = output.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                handle.write(data)
            }
        }

    }

    func setDirectory() {
        let temp: NSString = self.filename as NSString
        if temp.range(of: "/").location != Foundation.NSNotFound {
            // "/" was found in the filename, so we use whatever path is already there
            if self.filename.hasPrefix("~/") {
                self.filename = (self.filename as NSString).expandingTildeInPath
            }

            return
        }

        //let dirs : [String]? = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .AllDomainsMask, true) as? [String]
        let dirs: AnyObject = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as AnyObject

        if let dir: String = dirs as? String {
            //let dir = directories[0]; //documents directory
            let path = (dir as NSString).appendingPathComponent(self.filename)
            self.filename = path
        }
    }

    func openFile() {
        // open our file
        //Swell.info("Opening \(self.filename)")
        if !FileManager.default.fileExists(atPath: self.filename) {
            FileManager.default.createFile(atPath: self.filename, contents: nil, attributes: nil)
        }
        fileHandle = FileHandle(forWritingAtPath: self.filename)
        //Swell.debug("fileHandle is now \(fileHandle)")
    }

    func closeFile() {
        // close the file, if it's open
        if let handle = fileHandle {
            handle.closeFile()
        }
        fileHandle = nil
    }

    open func enable() {
        enabled = true
    }

    open func disable() {
        enabled = false
    }

    open func description() -> String {
        return "FileLocation filename=\(filename)"
    }
}

//
//  CBLogger.swift
//  Swell
//
//  Created by Hubert Rabago on 6/20/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//

open class CBLogger {

    let name: String
    open var level: LogLevel
    open var formatter: LogFormatter
    var locations: [LogLocation]
    var enabled: Bool

    public init(name: String,
                level: LogLevel = .INFO,
                formatter: LogFormatter = QuickFormatter(),
                logLocation: LogLocation = ConsoleLocation.getInstance()) {

        self.name = name
        self.level = level
        self.formatter = formatter
        self.locations = [LogLocation]()
        self.locations.append(logLocation)
        self.enabled = true

        Swell.registerLogger(self)
    }

    open func log<T>(_ logLevel: LogLevel, message: @autoclosure () -> T, filename: String? = #file, line: Int? = #line, function: String? = #function) {
        if (self.enabled) && (logLevel.level >= level.level) {
            let logMessage = formatter.formatLog(self, level: logLevel, message: message(),
                                                 filename: filename, line: line, function: function)
            for location in locations {
                location.log(logMessage)
            }
        }
    }

    //**********************************************************************
    // Main log methods

    open func trace<T>(_ message: @autoclosure () -> T, filename: String? = #file, line: Int? = #line, function: String? = #function) {
        self.log(.TRACE, message: message(), filename: filename, line: line, function: function)
    }

    open func debug<T>(_ message: @autoclosure () -> T, filename: String? = #file, line: Int? = #line, function: String? = #function) {
        self.log(.DEBUG, message: message(), filename: filename, line: line, function: function)
    }

    open func info<T>(_ message: @autoclosure () -> T, filename: String? = #file, line: Int? = #line, function: String? = #function) {
        self.log(.INFO, message: message(), filename: filename, line: line, function: function)
    }

    open func warn<T>(_ message: @autoclosure () -> T, filename: String? = #file, line: Int? = #line, function: String? = #function) {
        self.log(.WARN, message: message(), filename: filename, line: line, function: function)
    }

    open func error<T>(_ message: @autoclosure () -> T, filename: String? = #file, line: Int? = #line, function: String? = #function) {
        self.log(.ERROR, message: message(), filename: filename, line: line, function: function)
    }

    open func severe<T>(_ message: @autoclosure () -> T, filename: String? = #file, line: Int? = #line, function: String? = #function) {
        self.log(.SEVERE, message: message(), filename: filename, line: line, function: function)
    }

    //*****************************************************************************************
    // Log methods that accepts closures - closures must accept no param and return a String

    open func log(_ logLevel: LogLevel, filename: String? = #file, line: Int? = #line, function: String? = #function, fn: () -> String) {

        if (self.enabled) && (logLevel.level >= level.level) {
            let message = fn()
            self.log(logLevel, message: message)
        }
    }

    open func trace(
        _ filename: String? = #file, line: Int? = #line, function: String? = #function,
        fn: () -> String
        ) {
        log(.TRACE, filename: filename, line: line, function: function, fn: fn)
    }

    open func debug(
        _ filename: String? = #file, line: Int? = #line, function: String? = #function,
        fn: () -> String) {
        log(.DEBUG, filename: filename, line: line, function: function, fn: fn)
    }

    open func info(
        _ filename: String? = #file, line: Int? = #line, function: String? = #function,
        fn: () -> String) {
        log(.INFO, filename: filename, line: line, function: function, fn: fn)
    }

    open func warn(
        _ filename: String? = #file, line: Int? = #line, function: String? = #function,
        fn: () -> String) {
        log(.WARN, filename: filename, line: line, function: function, fn: fn)
    }

    open func error(
        _ filename: String? = #file, line: Int? = #line, function: String? = #function,
        fn: () -> String) {
        log(.ERROR, filename: filename, line: line, function: function, fn: fn)
    }

    open func severe(
        _ filename: String? = #file, line: Int? = #line, function: String? = #function, fn: () -> String) {
        log(.SEVERE, filename: filename, line: line, function: function, fn: fn)
    }

    //**********************************************************************
    // Methods to expose this functionality to Objective C code

    class func getLogger(_ name: String) -> CBLogger {
        return CBLogger(name: name)
    }

    open func traceMessage(_ message: String) {
        self.trace(message, filename: nil, line: nil, function: nil)
    }

    open func debugMessage(_ message: String) {
        self.debug(message, filename: nil, line: nil, function: nil)
    }

    open func infoMessage(_ message: String) {
        self.info(message, filename: nil, line: nil, function: nil)
    }

    open func warnMessage(_ message: String) {
        self.warn(message, filename: nil, line: nil, function: nil)
    }

    open func errorMessage(_ message: String) {
        self.error(message, filename: nil, line: nil, function: nil)
    }

    open func severeMessage(_ message: String) {
        self.severe(message, filename: nil, line: nil, function: nil)
    }
}

//
//  LogSelector.swift
//  Swell
//
//  Created by Hubert Rabago on 7/2/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//

/// Implements the logic for determining which loggers are enabled to actually log anything.
/// The rules used by this are:
///  * By default, everything is enabled
///  * If a logger is specifically disabled, then that rule will be followed regardless of whether it was enabled by another rule
///  * If any one logger is specifically enabled, then all other loggers must be specifically enabled, too,
///    otherwise they wouldn't be enabled
open class LogSelector {

    open var enableRule: String = "" {
        didSet {
            enabled = parseCSV(enableRule)
        }
    }
    open var disableRule: String = "" {
        didSet {
            disabled = parseCSV(disableRule)
        }
    }

    open var enabled: [String] = [String]()
    open var disabled: [String] = [String]()

    public init() {

    }

    func shouldEnable(_ logger: CBLogger) -> Bool {
        let name = logger.name
        return shouldEnableLoggerWithName(name)
    }

    open func shouldEnableLoggerWithName(_ name: String) -> Bool {
        // If the default rules are in place, then yes
        if disableRule.isEmpty && enableRule.isEmpty {
            return true
        }

        // At this point, we know at least one rule has changed

        // If logger was specifically disabled, then no
        if isLoggerDisabled(name) {
            return false
        }

        // If logger was specifically enabled, then yes!
        if isLoggerEnabled(name) {
            return true
        }

        // At this point, we know that the logger doesn't have a specific rule

        // If any items were specifically enabled, then this wasn't, then NO
        if !enabled.isEmpty {
            return false
        }

        // At this point, we know there weren't any loggers specifically enabled, but
        //  the disableRule has been modified, and yet this logger wasn't
        return true
    }

    /// Returns true if the given logger name was specifically configured to be disabled
    func isLoggerEnabled(_ name: String) -> Bool {
        for enabledName in enabled where (name == enabledName) {
            return true
        }

        return false
    }

    /// Returns true if the given logger name was specifically configured to be disabled
    func isLoggerDisabled(_ name: String) -> Bool {
        for disabledName in disabled where (name == disabledName) {
            return true
        }

        return false
    }

    func parseCSV(_ string: String) -> [String] {
        var result = [String]()
        let temp = string.components(separatedBy: ",")
        for s: String in temp where (!s.isEmpty) {
            result.append(s)
        }
        return result
    }

}

//
//  Swell.swift
//  Swell
//
//  Created by Hubert Rabago on 6/26/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//

struct LoggerConfiguration {
    var name: String
    var level: LogLevel?
    var formatter: LogFormatter?
    var locations: [LogLocation]

    init(name: String) {
        self.name = name
        self.locations = [LogLocation]()
    }
    func description() -> String {
        var locationsDesc = ""
        for loc in locations {
            locationsDesc += loc.description()
        }
        return "\(name) \(String(describing: level)) \(String(describing: formatter?.description())) \(locationsDesc)"
    }
}

// We declare this here because there isn't any support yet for class var / class let
let kGlobalSwell = Swell()

open class Swell {

    lazy var swellLogger: CBLogger? = {
        getLogger("Shared")
    }()

    var selector = LogSelector()
    var allLoggers = [String: CBLogger]()
    var rootConfiguration = LoggerConfiguration(name: "ROOT")
    var sharedConfiguration = LoggerConfiguration(name: "Shared")
    var allConfigurations = [String: LoggerConfiguration]()
    var enabled = true

    init() {
        // This configuration is used by the shared logger
        sharedConfiguration.formatter = QuickFormatter(format: .levelMessage)
        sharedConfiguration.level = LogLevel.TRACE
        sharedConfiguration.locations += [ConsoleLocation.getInstance()]

        // The root configuration is where all other configurations are based off of
        rootConfiguration.formatter = QuickFormatter(format: .levelNameMessage)
        rootConfiguration.level = LogLevel.TRACE
        rootConfiguration.locations += [ConsoleLocation.getInstance()]

        readConfigurationFile()
    }

    //========================================================================================
    // Global/convenience log methods used for quick logging

    open class func trace<T>(_ message: @autoclosure () -> T) {
        kGlobalSwell.swellLogger?.trace(message())
    }

    open class func debug<T>(_ message: @autoclosure () -> T) {
        kGlobalSwell.swellLogger?.debug(message())
    }

    open class func info<T>(_ message: @autoclosure () -> T) {
        kGlobalSwell.swellLogger?.info(message())
    }

    open class func warn<T>(_ message: @autoclosure () -> T) {
        kGlobalSwell.swellLogger?.warn(message())
    }

    open class func error<T>(_ message: @autoclosure () -> T) {
        kGlobalSwell.swellLogger?.error(message())
    }

    open class func severe<T>(_ message: @autoclosure () -> T) {
        kGlobalSwell.swellLogger?.severe(message())
    }

    open class func trace(_ fn: () -> String) {
        kGlobalSwell.swellLogger?.trace(fn())
    }

    open class func debug(_ fn: () -> String) {
        kGlobalSwell.swellLogger?.debug(fn())
    }

    open class func info(_ fn: () -> String) {
        kGlobalSwell.swellLogger?.info(fn())
    }

    open class func warn(_ fn: () -> String) {
        kGlobalSwell.swellLogger?.warn(fn())
    }

    open class func error(_ fn: () -> String) {
        kGlobalSwell.swellLogger?.error(fn())
    }

    open class func severe(_ fn: () -> String) {
        kGlobalSwell.swellLogger?.severe(fn())
    }

    //====================================================================================================
    // Public methods

    /// Returns the logger configured for the given name.
    /// This is the recommended way of retrieving a Swell logger.
    open class func getLogger(_ name: String) -> CBLogger? {
        return kGlobalSwell.getLogger(name)
    }

    /// Turns off all logging.
    open class func disableLogging() {
        kGlobalSwell.disableLogging()
    }

    //====================================================================================================
    // Internal methods serving the public methods

    func disableLogging() {
        enabled = false
        for (_, value) in allLoggers {
            value.enabled = false
        }
    }

    func enableLogging() {
        enabled = true
        for (_, value) in allLoggers {
            value.enabled = selector.shouldEnable(value)
        }
    }

    // Register the given logger.  This method should be called
    // for ALL loggers created.  This facilitates enabling/disabling of
    // loggers based on user configuration.
    class func registerLogger(_ logger: CBLogger) {
        kGlobalSwell.registerLogger(logger)
    }

    func registerLogger(_ logger: CBLogger) {
        allLoggers[logger.name] = logger
        evaluateLoggerEnabled(logger)
    }

    func evaluateLoggerEnabled(_ logger: CBLogger) {
        logger.enabled = self.enabled && selector.shouldEnable(logger)
    }

    /// Returns the Logger instance configured for a given logger name.
    /// Use this to get Logger instances for use in classes.
    func getLogger(_ name: String) -> CBLogger? {
        if let logger = allLoggers[name] {
            return logger
        } else if let logger = createLogger(name) {
            allLoggers[name] = logger
            return logger
        }
        return nil
    }

    /// Creates a new Logger instance based on configuration returned by getConfigurationForLoggerName()
    /// This is intended to be in an internal method and should not be called by other classes.
    /// Use getLogger(name) to get a logger for normal use.
    func createLogger(_ name: String) -> CBLogger? {
        let config = getConfigurationForLoggerName(name)
        guard let level = config.level, let formatter = config.formatter else { return nil }

        let result = CBLogger(name: name, level: level, formatter: formatter, logLocation: config.locations[0])

        // Now we need to handle potentially > 1 locations
        if config.locations.count > 1 {
            for (index, location) in config.locations.enumerated() where (index > 0) {
                result.locations += [location]
            }
        }

        return result
    }

    //====================================================================================================
    // Methods for managing the configurations from the plist file

    /// Returns the current configuration for a given logger name based on Swell.plist
    /// and the root configuration.
    func getConfigurationForLoggerName(_ name: String) -> LoggerConfiguration {
        var config = LoggerConfiguration(name: name)

        // first, populate it with values from the root config
        config.formatter = rootConfiguration.formatter
        config.level = rootConfiguration.level
        config.locations += rootConfiguration.locations

        if name == "Shared" {
            if let level = sharedConfiguration.level {
                config.level = level
            }
            if let formatter = sharedConfiguration.formatter {
                config.formatter = formatter
            }
            if !sharedConfiguration.locations.isEmpty {
                config.locations = sharedConfiguration.locations
            }
        }

        // Now see if there's a config specifically for this logger
        // In later versions, we can consider tree structures similar to Log4j
        // For now, let's require an exact match for the name
        let keys = allConfigurations.keys
        for key in keys where (key == name) {
            // Look for the entry with the same name
            let temp = allConfigurations[key]
            if let spec = temp {
                if let formatter = spec.formatter {
                    config.formatter = formatter
                }
                if let level = spec.level {
                    config.level = level
                }
                if !spec.locations.isEmpty {
                    config.locations = spec.locations
                }
            }
        }

        return config
    }

    //====================================================================================================
    // Methods for reading the Swell.plist file

    func readConfigurationFile() {

        let filename: String? = Bundle.main.path(forResource: "Swell", ofType: "plist")

        var dict: NSDictionary?
        if let bundleFilename = filename {
            dict = NSDictionary(contentsOfFile: bundleFilename)
        }
        if let map: [String: AnyObject] = dict as? [String: AnyObject] {

            //-----------------------------------------------------------------
            // Read the root configuration
            let configuration = readLoggerPList("ROOT", map: map)
            //Swell.info("map: \(map)");

            // Now any values configured, we put in our root configuration
            if let formatter = configuration.formatter {
                rootConfiguration.formatter = formatter
            }
            if let level = configuration.level {
                rootConfiguration.level = level
            }
            if !configuration.locations.isEmpty {
                rootConfiguration.locations = configuration.locations
            }

            //-----------------------------------------------------------------
            // Now look for any keys that don't start with SWL, and if it contains a dictionary value, let's read it
            let keys = map.keys
            for key in keys {
                if !key.hasPrefix("SWL") {
                    let value: AnyObject? = map[key]
                    if let submap: [String: AnyObject] = value as? [String: AnyObject] {
                        let subconfig = readLoggerPList(key, map: submap)
                        applyLoggerConfiguration(key, configuration: subconfig)
                    }
                }
            }

            //-----------------------------------------------------------------
            // Now check if there is an enabled/disabled rule specified
            var item: AnyObject?
            // Set the LogLevel

            item = map["SWLEnable"]
            if let value: AnyObject = item {
                if let rule: String = value as? String {
                    selector.enableRule = rule
                }
            }

            item = map["SWLDisable"]
            if let value: AnyObject = item {
                if let rule: String = value as? String {
                    selector.disableRule = rule
                }
            }

        }

    }

    /// Specifies or modifies the configuration of a logger.
    /// If any aspect of the configuration was not provided, and there is a pre-existing value for it,
    /// the pre-existing value will be used for it.
    /// For example, if two consecutive calls were made:
    ///     configureLogger("MyClass", level: LogLevel.DEBUG, formatter: MyCustomFormatter())
    ///     configureLogger("MyClass", level: LogLevel.INFO, location: ConsoleLocation())
    ///  then the resulting configuration for MyClass would have MyCustomFormatter, ConsoleLocation, and LogLevel.INFO.
    func configureLogger(_ loggerName: String, level givenLevel: LogLevel? = nil, formatter givenFormatter: LogFormatter? = nil, location givenLocation: LogLocation? = nil) {

        var oldConfiguration: LoggerConfiguration?
        if allConfigurations.index(forKey: loggerName) != nil {
            oldConfiguration = allConfigurations[loggerName]
        }

        var newConfiguration = LoggerConfiguration(name: loggerName)

        if let level = givenLevel {
            newConfiguration.level = level
        } else if let level = oldConfiguration?.level {
            newConfiguration.level = level
        }

        if let formatter = givenFormatter {
            newConfiguration.formatter = formatter
        } else if let formatter = oldConfiguration?.formatter {
            newConfiguration.formatter = formatter
        }

        if let location = givenLocation {
            newConfiguration.locations += [location]
        } else if let locations = oldConfiguration?.locations, !locations.isEmpty {
            newConfiguration.locations = locations
        }

        applyLoggerConfiguration(loggerName, configuration: newConfiguration)
    }

    /// Store the configuration given for the specified logger.
    /// If the logger already exists, update its configuration to reflect what's in the logger.

    func applyLoggerConfiguration(_ loggerName: String, configuration: LoggerConfiguration) {
        // Record this custom config in our map
        allConfigurations[loggerName] = configuration

        // See if the logger with the given name already exists.
        // If so, update the configuration it's using.
        if let logger = allLoggers[loggerName] {

            // TODO - There should be a way to keep calls to logger.log while this is executing
            if let level = configuration.level {
                logger.level = level
            }
            if let formatter = configuration.formatter {
                logger.formatter = formatter
            }
            if !configuration.locations.isEmpty {
                logger.locations.removeAll(keepingCapacity: false)
                logger.locations += configuration.locations
            }
        }

    }

    func readLoggerPList(_ loggerName: String, map: [String: AnyObject]) -> LoggerConfiguration {
        var configuration = LoggerConfiguration(name: loggerName)
        var item: AnyObject?
        // Set the LogLevel

        item = map["SWLLevel"]
        if let value: AnyObject = item {
            if let level: String = value as? String {
                configuration.level = LogLevel.getLevel(level)
            }
        }

        // Set the formatter;  First, look for a QuickFormat spec
        item = map["SWLQuickFormat"]
        if let value: AnyObject = item {
            configuration.formatter = getConfiguredQuickFormatter(configuration, item: value)
        } else {
            // If no QuickFormat was given, look for a FlexFormat spec
            item = map["SWLFlexFormat"]
            if let value: AnyObject = item {
                configuration.formatter = getConfiguredFlexFormatter(configuration, item: value)
            } else {
                let formatKey = getFormatKey(map)
                print("formatKey=\(String(describing: formatKey))")
            }
        }

        // Set the location for the logs
        item = map["SWLLocation"]
        if let value: AnyObject = item {
            configuration.locations = getConfiguredLocations(configuration, item: value, map: map)
        }

        return configuration
    }

    func getConfiguredQuickFormatter(_ configuration: LoggerConfiguration, item: AnyObject) -> LogFormatter? {
        if let formatString: String = item as? String {
            let formatter = QuickFormatter.logFormatterForString(formatString)
            return formatter
        }
        return nil
    }

    func getConfiguredFlexFormatter(_ configuration: LoggerConfiguration, item: AnyObject) -> LogFormatter? {
        if let formatString: String = item as? String {
            let formatter = FlexFormatter.logFormatterForString(formatString)
            return formatter
        }
        return nil
    }

    func getConfiguredFileLocation(_ configuration: LoggerConfiguration, item: AnyObject) -> LogLocation? {
        if let filename: String = item as? String {
            let logLocation = FileLocation.getInstance(filename)
            return logLocation
        }
        return nil
    }

    func getConfiguredLocations(_ configuration: LoggerConfiguration, item: AnyObject, map: [String: AnyObject]) -> [LogLocation] {
        var results = [LogLocation]()
        if let configuredValue: String = item as? String {
            // configuredValue is the raw value in the plist

            // values is the array from configuredValue
            let values = configuredValue.lowercased().components(separatedBy: CharacterSet.whitespaces)

            for value in values {
                if value == "file" {
                    // handle file name
                    let filenameValue: AnyObject? = map["SWLLocationFilename"]
                    if let filename: AnyObject = filenameValue {
                        if let fileLocation = getConfiguredFileLocation(configuration, item: filename) {
                            results += [fileLocation]
                        }
                    }
                } else if value == "console" {
                    results += [ConsoleLocation.getInstance()]
                } else {
                    print("Unrecognized location value in Swell.plist: '\(value)'")
                }
            }
        }
        return results
    }

    func getFormatKey(_ map: [String: AnyObject]) -> String? {
        for (key, _) in map {
            if (key.hasPrefix("SWL")) && (key.hasSuffix("Format")) {
                let start = key.index(key.startIndex, offsetBy: 3)
                let end = key.index(key.endIndex, offsetBy: -6)
                let result = String(key[start..<end])
                return result
            }
        }

        return nil
    }

    func getFunctionFormat(_ function: String) -> String {
        var result = function
        if result.hasPrefix("Optional(") {
            let len = "Optional(".count
            let start = result.index(result.startIndex, offsetBy: len)
            let end = result.index(result.endIndex, offsetBy: -len)
            let range = start..<end
            result = String(result[range])
        }
        if (!result.hasSuffix(")")) {
            result += "()"
        }
        return result
    }

}

// swiftlint:enable all
