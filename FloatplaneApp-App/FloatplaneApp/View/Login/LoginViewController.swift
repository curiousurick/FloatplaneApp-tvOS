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
    
    private let loginOp = OperationManager.instance.loginOperation
    
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var loginButton: LoginButton!
    @IBOutlet var floatPlaneLabel: UILabel!
    
    private var moveToLoginButton: Bool = false
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        get {
            if moveToLoginButton {
                moveToLoginButton = false
                return [loginButton]
            }
            return super.preferredFocusEnvironments
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ensurePlaceholderColor()
        
        let robotoFont: UIFont = .roboto(size: 48, weight: .black)
        floatPlaneLabel.font = UIFontMetrics.default.scaledFont(for: robotoFont)
        floatPlaneLabel.adjustsFontForContentSizeCategory = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        let navController = UIStoryboard.main.getTopNavigationController()
//        AppDelegate.instance.replaceRootController(viewController: navController)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        // Just finished entering both text fields
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        if reason == .committed &&
            !username.isEmpty &&
            !password.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .milliseconds(500))) {
                self.moveToLoginButton = true
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
        }
    }
    
    @IBAction func loginButtonPressed(sender: UIButton!) {
        let request = LoginRequest(username: usernameField.text ?? "", password: passwordField.text ?? "")
        loginOp.get(request: request) { response, error in
            if let user = response?.user {
                UserStore.instance.setUser(user: user)
                DispatchQueue.main.async {
                    self.performSegue(
                        withIdentifier: SegueIdentifier.LoginViewController.unwindFromLoginSegue,
                        sender: self
                    )
                }
            }
            else {
                self.displayLoginFailureAlert(message: error?.message)
            }
        }
    }
    
    func ensurePlaceholderColor() {
        DispatchQueue.main.async {
            let textColor = UIColor.loginTextColor
            self.usernameField.textColor = textColor
            self.usernameField.attributedPlaceholder = NSAttributedString(
                string: "Username",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
            self.passwordField.textColor = textColor
            self.passwordField.attributedPlaceholder = NSAttributedString(
                string: "Password",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        ensurePlaceholderColor()
    }
    
    func displayLoginFailureAlert(message: String?) {
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

