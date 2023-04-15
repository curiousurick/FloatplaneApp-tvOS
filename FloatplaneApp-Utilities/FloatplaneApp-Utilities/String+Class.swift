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

import Foundation

/// Extension to make it easy to get the class name of any type
public extension String {
    /// Returns the simple class name of the given object.
    /// If a nil value is given, this cannot infer the intended type.
    static func fromClass(_ any: Any?) -> String {
        if let any = any {
            return String(describing: type(of: any))
        }
        // Will return "Optional<Any>(nil)" because we can't get the type of a nil value
        return "\(String(describing: type(of: any)))(nil)"
    }

    /// Returns the simple class name of the given type.
    /// To me this looks nicer than calling String(describing: Whatever.self)
    static func fromClass(_ type: Any.Type) -> String {
        String(describing: type)
    }
}
