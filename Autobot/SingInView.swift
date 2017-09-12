//
//  SingInView.swift
//  Autobot
//
//  Created by Tanaka, Tomohiro on 2017/09/11.
//  Copyright © 2017年 Tanaka, Tomohiro. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class SingInView: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    var pwAuthCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    var userNameText: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.userName.text = userNameText //Username
        self.passWord.text = nil //Password
    }
    
    //When pushing "Sign In"
    @IBAction func signInPressed(_ sender: Any) {
        if (self.userName.text != nil && self.passWord.text != nil) { //Username&Password are NOT nil
            let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.userName.text!, password: self.passWord.text!) //username&passwordの入力値をauthDetailsへ格納
            self.pwAuthCompletion?.set(result: authDetails) //authDetailsをCognitioUserPoolに登録する用に格納
        } else { //UsernameまたはPasswordがnilの場合
            let alertController = UIAlertController(title: "Missing information",
                                                    message: "Please enter a valid username and password",
                                                    preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
            alertController.addAction(retryAction) //AlertViewを上記内容で表示する
        }
    } //@IBAction func siginInPressed end
    
    
    //Keyboard close
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //Keyboardを閉じる
        userName.resignFirstResponder()
        passWord.resignFirstResponder()
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension SingInView: AWSCognitoIdentityPasswordAuthentication {
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.pwAuthCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            if (self.userNameText == nil) {
                self.userNameText = authenticationInput.lastKnownUsername
            }
        }
    } //public func getDetails end
    
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as NSError? {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self.present(alertController, animated: true, completion:  nil)
            } else {
                self.userName.text = nil
                self.dismiss(animated: true, completion: nil)
            }
        }
    }//public func didCompleteStepWithError end
} //extension SingInView end
