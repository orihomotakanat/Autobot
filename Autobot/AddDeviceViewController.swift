//
//  AddDeviceViewController.swift
//  Autobot
//
//  Created by 田中智大 on 2017/09/16.
//  Copyright © 2017年 Tanaka, Tomohiro. All rights reserved.
//

import UIKit

class AddDeviceViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var roomName: UITextField!
    @IBOutlet var deviceSelectPicker: UIPickerView!
    
    let pickerViewList: Array = ["RaspberryPi3"] //deviceの機種
    //let controlPickerList: Array = ["Air conditionar"] //aircon, TVremote

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // - deviceSelectPicker
        deviceSelectPicker.setValue(UIColor.white, forKey: "textColor")
        deviceSelectPicker.backgroundColor = #colorLiteral(red: 0.001564681064, green: 0.05989853293, blue: 0.1638002098, alpha: 1)
        deviceSelectPicker.delegate = self
        deviceSelectPicker.dataSource = self
        self.view.addSubview(deviceSelectPicker)
        
        roomName.delegate = self
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
