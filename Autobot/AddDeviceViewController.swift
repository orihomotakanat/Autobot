//
//  AddDeviceViewController.swift
//  Autobot
//
//  Created by 田中智大 on 2017/09/16.
//  Copyright © 2017年 Tanaka, Tomohiro. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSCognitoIdentityProvider

class AddDeviceViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var roomName: UITextField!
    @IBOutlet weak var uuid: UITextField!
    
    @IBOutlet var deviceSelectPicker: UIPickerView!
    
    
    //cognitoCredentials for inserting to DynamoDB
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    
    let pickerViewList: Array = ["RaspberryPi3"] //deviceの機種
    let temporaryMethod: String = "aircon" //Method
    
    //For insertToDDB
    var tableRow: DDBTableRow?
    //var dataChanged = false //Update機能は後に
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // - CognitoUserPool
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        if (self.user == nil) {
            self.user = self.pool?.currentUser()
        }
        
        // - deviceSelectPicker
        deviceSelectPicker.setValue(UIColor.white, forKey: "textColor")
        deviceSelectPicker.backgroundColor = #colorLiteral(red: 0.001564681064, green: 0.05989853293, blue: 0.1638002098, alpha: 1)
        deviceSelectPicker.delegate = self
        deviceSelectPicker.dataSource = self
        self.view.addSubview(deviceSelectPicker)
        
        roomName.delegate = self
        uuid.delegate = self
    }
    
    //Save device setting to DDB
    @IBAction func insertToDDB(_ sender: Any) {
        let tableRow = DDBTableRow()
        tableRow?.username = (self.user?.username)!
        tableRow?.roomname = self.roomName.text
        tableRow?.uuid = self.uuid.text
        tableRow?.device = pickerViewList[0]
        tableRow?.method = temporaryMethod
        if (self.roomName.text!.utf16.count > 0) {
            self.insertTableRow(tableRow!)
        } else {
            let alertController = UIAlertController(title: "Error: Invalid Input", message: "Range Key Value cannot be empty.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    //insert to DDB funcation
    func insertTableRow(_ tableRow: DDBTableRow) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        dynamoDBObjectMapper.save(tableRow) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
                
                let alertController = UIAlertController(title: "Failed to insert the data into the table.", message: error.description, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else { //Fail to insertでない場合
                let alertController = UIAlertController(title: "Succeeded", message: "Successfully registered your device", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
                self.roomName.text = nil

                //self.dataChanged = true //Update機能は後に
            }
            
            return nil
        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //PickeViewrに表示する列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //PickerViewに表示する行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewList.count
    }
    
    //PickerViewに表示するデータ(delegateMethod)
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewList[row]
    }

    //pickerが選択された際に呼ばれる(delegateMethod) ForDebug
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("row: \(row)")
        print("value: \(pickerViewList[row])")
    }
    
    //Keyboard close
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        roomName.resignFirstResponder()
        uuid.resignFirstResponder()
        return true
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
