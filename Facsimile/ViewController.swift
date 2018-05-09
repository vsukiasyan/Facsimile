//
//  ViewController.swift
//  Facsimile
//
//  Created by Vic Sukiasyan on 5/8/18.
//  Copyright © 2018 Vic Sukiasyan. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    
    var signupModeActive = true
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signupOrLoginBtn: UIButton!
    @IBOutlet weak var switchLoginModeBtn: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }

    @IBAction func signupOrLogin(_ sender: Any) {
        if email.text == "" || password.text == "" {
            displayAlert(title: "Error in form", message: "Please enter an email AND password.")
        } else {
            let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            spinner.center = self.view.center
            spinner.hidesWhenStopped = true
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(spinner)
            spinner.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            if signupModeActive {
                let user = PFUser()
                user.username = email.text
                user.password = password.text
                user.email = email.text
                
                user.signUpInBackground(block: { (success, error) in
                    spinner.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if let error = error {
                        self.displayAlert(title: "Could not sign you up.", message: error.localizedDescription)
                    } else {
                        print("Signed up")
                    }
                })
            } else {
                PFUser.logInWithUsername(inBackground: email.text!, password: password.text!, block: { (user, error) in
                    spinner.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if user != nil {
                        print("Login successful")
                    } else {
                        var errorText = "Unknown error, please try again."
                        if let error = error {
                            errorText = error.localizedDescription
                            
                        }
                        self.displayAlert(title: "Could not log you in", message: errorText)
                    }
                })
            }
        }
    }
    
    @IBAction func switchLoginMode(_ sender: Any) {
        if signupModeActive {
            signupModeActive = false
            signupOrLoginBtn.setTitle("Login", for: [])
            switchLoginModeBtn.setTitle("Sign Up", for: [])
        } else {
            signupModeActive = true
            signupOrLoginBtn.setTitle("Sign Up", for: [])
            switchLoginModeBtn.setTitle("Login", for: [])
        }
    }
    
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

