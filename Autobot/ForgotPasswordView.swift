//
//  ForgotPasswordView.swift
//  Autobot
//
//  Created by Tanaka, Tomohiro on 2017/09/11.
//  Copyright © 2017年 Tanaka, Tomohiro. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class ForgotPasswordView: UIViewController {
    
    var pool: AWSCognitoIdentityUserPool?
    var user: AWSCognitoIdentityUser?

    @IBOutlet weak var userName: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey) //今回はFacebookやAmazonのプロバイダは使用していないのでここは特に関係なし
    }
    
    //Keyboard close
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //Keyboardを閉じる
        userName.resignFirstResponder()
        
        return true
    }
    
    //Back to SignInView
    @IBAction func backToSignInView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newPasswordViewController = segue.destination as? ResetPasswordView {
            newPasswordViewController.user = self.user
        }
    }
    
    //forgotPassword
    @IBAction func forgotPassword(_ sender: Any) {
        guard let username = self.userName.text, !username.isEmpty else {
            
            let alertController = UIAlertController(title: "Missing UserName",
                                                    message: "Please enter a valid user name.",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        
        self.user = self.pool?.getUser(self.userName.text!)
        self.user?.forgotPassword().continueWith{[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else {return nil}
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else {
                    strongSelf.performSegue(withIdentifier: "confirmForgotPasswordSegue", sender: sender)
                }
            })
            return nil
        } //self.user?.forgotPassword() end
    } //@IBAction func forgotPassword end
    
    
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
