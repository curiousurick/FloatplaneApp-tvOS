//  Copyright © 2023 George Urick
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Logging
import Foundation

/// Simple wrapping for Apple's Logging framework. Instead of having the log level as a parameter, you explicitly call
/// the log function for a given level.
/// It will print to console if the log level is less severe than the function severity.
/// For example Log4S().error("Message") will be logged only if the log level is set to a lower severity than error.
///
/// Severity level in order (from Apple documentation
/// trace - Appropriate for messages that contain information normally of use only when tracing the execution of a
/// program.
///
/// debug - Appropriate for messages that contain information normally of use only when debugging a program.
///
/// info - Appropriate for informational messages.
///
/// notice - Appropriate for conditions that are not error conditions, but that may require special handling.
///
/// warning - Appropriate for messages that are not error conditions, but more severe than warning
///
/// error - Appropriate for error conditions.
///
/// critical - Appropriate for critical error conditions that usually require immediate attention.
/// When a `critical` message is logged, the logging backend (`LogHandler`) is free to perform
/// more heavy-weight operations to capture system state (such as capturing stack traces) to facilitate
/// debugging.
public class Log4S {
    private var logger: Logger

    public init(file: String = #file) {
        let label = URL(fileURLWithPath: file).deletingPathExtension().lastPathComponent
        logger = Logger(label: label)
    }

    /// Sets the minimum severity level for logging.
    /// If the logLevel is higher severity than the log function, it will not log.
    /// Default logLevel is info
    var logLevel: Logger.Level = .info {
        didSet {
            logger.logLevel = logLevel
        }
    }

    /// Logs if logLevel is less severe than .debug
    public func debug(
        _ message: Logger.Message,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        logMessage(
            level: .debug,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    /// Logs if logLevel is less severe than .info
    public func info(
        _ message: Logger.Message,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        logMessage(
            level: .info,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    /// Logs if logLevel is less severe than .notice
    public func notice(
        _ message: Logger.Message,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        logMessage(
            level: .notice,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    /// Logs if logLevel is less severe than .error
    public func error(
        _ message: Logger.Message,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        logMessage(
            level: .error,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    /// Logs if logLevel is less severe than .trace
    public func trace(
        _ message: Logger.Message,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        logMessage(
            level: .trace,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    /// Logs if logLevel is less severe than .warn
    public func warn(
        _ message: Logger.Message,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        logMessage(
            level: .warning,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    /// Logs if logLevel is less severe than .critical
    public func critical(
        _ message: Logger.Message,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        logMessage(
            level: .critical,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    private func logMessage(
        level: Logger.Level,
        message: Logger.Message,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        logger.log(
            level: level,
            message,
            metadata: nil,
            source: nil,
            file: file,
            function: function,
            line: line
        )
    }
}
