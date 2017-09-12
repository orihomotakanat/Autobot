//
//  ConfirmView.swift
//  Autobot
//
//  Created by Tanaka, Tomohiro on 2017/09/11.
//  Copyright © 2017年 Tanaka, Tomohiro. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class ConfirmView: UIViewController, UITextFieldDelegate {
    
    var sentTo: String?
    var user: AWSCognitoIdentityUser?
    
    @IBOutlet weak var sentToLabel: UILabel!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var confirmCode: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userName.text = self.user!.username
        self.sentToLabel.text = "Code sent to: \(self.sentTo!)"
        
        userName.delegate = self
        confirmCode.delegate = self
    }
    
    //Keyboard close
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userName.resignFirstResponder()
        confirmCode.resignFirstResponder()
        
        return true
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Complete registration
    @IBAction func confirm(_ sender: Any) {
        guard let confirmationCodeValue = self.confirmCode.text, !confirmationCodeValue.isEmpty else {
            let alertController = UIAlertController(title: "Confirmation code missing.",
                                                    message: "Please enter a valid confirmation code.",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        
        self.user?.confirmSignUp(self.confirmCode.text!, forceAliasCreation: true).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    strongSelf.present(alertController, animated: true, completion:  nil)
                } else {
                    let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                }
            })
            return nil
        } //self.user?.confirmSignUp end
        
    } //@IBAction func confirm end
    
    //Redeem the code
    @IBAction func resend(_ sender: Any) {
        self.user?.resendConfirmationCode().continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let _ = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else if let result = task.result {
                    let alertController = UIAlertController(title: "Code Resent",
                                                            message: "Code resent to \(String(describing: result.codeDeliveryDetails?.destination!))",
                        preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self?.present(alertController, animated: true, completion: nil)
                }
            })
            return nil
        } //self.user?.resendConfirmationCode()... end
    } //@IBAction func resend end
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
