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

import UIKit
import FloatplaneApp_Operations
import FloatplaneApp_Models
import FloatplaneApp_DataStores

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    private let loginOp = OperationManagerImpl.instance.loginOperation
    
    @IBOutlet var usernameField: LoginImageTextField!
    @IBOutlet var passwordField: LoginImageTextField!
    @IBOutlet var loginButton: LoginButton!
    @IBOutlet var floatPlaneLabel: UILabel!
    
    private var viewToFocus: UIFocusEnvironment? {
        didSet {
            self.setNeedsFocusUpdate()
            self.updateFocusIfNeeded()
        }
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        get {
            if let viewToFocus = viewToFocus {
                self.viewToFocus = nil
                return [viewToFocus]
            }
            return super.preferredFocusEnvironments
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let robotoFont: UIFont = .roboto(size: 48, weight: .black)
        floatPlaneLabel.font = UIFontMetrics.default.scaledFont(for: robotoFont)
        floatPlaneLabel.adjustsFontForContentSizeCategory = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        usernameField.updatePlaceholderView()
        passwordField.updatePlaceholderView()
        // Just finished entering both text fields
        let username = usernameField.textField.text ?? ""
        let password = passwordField.textField.text ?? ""
        if reason == .committed &&
            !username.isEmpty &&
            !password.isEmpty {
            // Does not work if you do it immediately.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.viewToFocus = self.loginButton
            }
        }
    }
    
    @IBAction func loginButtonPressed(sender: UIButton!) {
        Task {
            let username = usernameField.textField.text ?? ""
            let password = passwordField.textField.text ?? ""
            let request = LoginRequest(username: username, password: password)
            let opResponse = await loginOp.get(request: request)
            if let user = opResponse.response?.user {
                UserStoreImpl.instance.setUser(user: user)
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        AppDelegate.instance.rootViewController.getFirstPageAndLoadMainView()
                    }
                }
            }
            else {
                var message: String?
                if let loginFailedError = opResponse.error as? LoginFailedError {
                    message = loginFailedError.response.message
                }
                self.displayLoginFailureAlert(message: message)
            }
        }
    }
    
    func displayLoginFailureAlert(message: String? = nil) {
        let title = "Sorry, we had trouble logging you in"
        let defaultErrorMessage = "Your Floatplane username or password could not be verified. Please try again."
        let alert = UIAlertController(title: title, message: message ?? defaultErrorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

