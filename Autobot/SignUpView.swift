//
//  SignUpView.swift
//  Autobot
//
//  Created by Tanaka, Tomohiro on 2017/09/11.
//  Copyright © 2017年 Tanaka, Tomohiro. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class SignUpView: UIViewController {

    var pool: AWSCognitoIdentityUserPool?
    var sentTo: String?
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey) //今回FacebookやAmazonのproviderは設定してないのでここは特になし
    }
    
    //Keyboard close
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //Keyboardを閉じる
        userName.resignFirstResponder()
        passWord.resignFirstResponder()
        
        return true
    }
    
    
    /* //特に必要ないので省略
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    */
    
    //次のSegueへ移動する
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let signUpConfirmView = segue.destination as? ConfirmView {
            signUpConfirmView.sentTo = self.sentTo
            signUpConfirmView.user = self.pool?.getUser(self.userName.text!)
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        guard let userNameValue = self.userName.text, !userNameValue.isEmpty,
            let passwordValue = self.passWord.text, !passwordValue.isEmpty else {
                let alertController = UIAlertController(title: "Missing Required Fields",
                                                        message: "Username / Password are required for registration.",
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion:  nil)
                return
            }
        
        var attributes = [AWSCognitoIdentityUserAttributeType]() //属性: email,phoneNum
        
        //phoneをattributesへ格納
        if let phoneValue = self.phone.text, !phoneValue.isEmpty {
            let phone = AWSCognitoIdentityUserAttributeType()
            phone?.name = "phone_number"
            phone?.value = phoneValue
            attributes.append(phone!)
        }
        
        //emailをattributesへ格納
        if let emailValue = self.email.text, !emailValue.isEmpty {
            let email = AWSCognitoIdentityUserAttributeType()
            email?.name = "email"
            email?.value = emailValue
            attributes.append(email!)
        }
        
        
        //sign up the user
        self.pool?.signUp(userNameValue, password: passwordValue, userAttributes: attributes, validationData: nil).continueWith {[weak self] (task) -> Any? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                    alertController.addAction(retryAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else if let result = task.result  {
                    // handle the case where user has to confirm his identity via email / SMS
                    if (result.user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed) {
                        strongSelf.sentTo = result.codeDeliveryDetails?.destination
                        strongSelf.performSegue(withIdentifier: "confirmSignUpSegue", sender:sender)
                    } else {
                        let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                    }
                }
                
            })
            return nil
        } //self.pool?.signUp(userNameValue, passwaord:... end
        
    } //@IBAction func signUp end
    
    /* //Keyboard close
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //Keyboardを閉じる
        queryStringParameters.resignFirstResponder( )
        methodPath.resignFirstResponder()
        
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
