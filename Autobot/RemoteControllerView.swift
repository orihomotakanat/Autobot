//
//  RemoteControllerView.swift
//  Autobot
//
//  Created by Tanaka, Tomohiro on 2017/09/11.
//  Copyright © 2017年 Tanaka, Tomohiro. All rights reserved.
//

import UIKit

class RemoteControllerView: UIViewController {
    //TapticEngine
    let tapticGenerator = UIImpactFeedbackGenerator(style: .heavy)
    let tapticNotficationGenerator = UINotificationFeedbackGenerator()

    //Timer
    @IBOutlet var reservedTimerPicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Preparation of tapticEngine
        tapticGenerator.prepare()
        tapticNotficationGenerator.prepare() //tapticEngine for timer
        
        
        // Do any additional setup after loading the view.
        reservedTimerPicker.setValue(UIColor.white, forKey: "textColor")
        reservedTimerPicker.backgroundColor = #colorLiteral(red: 0.001564681064, green: 0.05989853293, blue: 0.1638002098, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //TurnningOn
    func turnedOn() {
        //処理
        print("Turn on")
        tapticGenerator.impactOccurred()
    }
    
    
    //When pushing reserve button
    @IBAction func pushedReserve(_ sender: Any) {
        //処理
        turnedOn()
        
    }
    
    //When pusing on button
    @IBAction func pushedOn(_ sender: Any) {
        //処理
        turnedOn()
    }
    
    //When pushing off button
    @IBAction func pushedOff(_ sender: Any) {
        //処理
        print("Turn off")
        tapticGenerator.impactOccurred()
    }
    
    
    
    //Back to UserDeviceView.swift
    @IBAction func backToUserDeviceView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
