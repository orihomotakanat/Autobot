//
//  RemoteControllerView.swift
//  Autobot
//
//  Created by Tanaka, Tomohiro on 2017/09/11.
//  Copyright © 2017年 Tanaka, Tomohiro. All rights reserved.
//

import UIKit
import SwiftyJSON
import AWSIoT
import AWSCore

class RemoteControllerView: UIViewController {
    //TapticEngine
    let tapticGenerator = UIImpactFeedbackGenerator(style: .heavy)
    let tapticNotficationGenerator = UINotificationFeedbackGenerator()

    //Timer
    @IBOutlet var reservedTimerPicker: UIDatePicker!
    
    //AWSIoT
    var iotDataManager: AWSIoTDataManager!
    let thingName = "room"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Preparation of tapticEngine
        tapticGenerator.prepare()
        tapticNotficationGenerator.prepare() //tapticEngine for timer
                
        // Do any additional setup after loading the view.
        reservedTimerPicker.setValue(UIColor.white, forKey: "textColor")
        reservedTimerPicker.backgroundColor = #colorLiteral(red: 0.001564681064, green: 0.05989853293, blue: 0.1638002098, alpha: 1)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        iotDataManager = AWSIoTDataManager.default()
        iotDataManager.connectUsingWebSocket(withClientId: UUID().uuidString, cleanSession: true, statusCallback: mqttEventCallback)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        iotDataManager = AWSIoTDataManager.default()
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
    
    //MQTT callback
    func mqttEventCallback( _ status: AWSIoTMQTTStatus ) {
        DispatchQueue.main.async {
            print("connection status = \(status.rawValue)")
            switch(status)
            {
            case .connecting:
                print( "Connecting..." )
                
            case .connected:
                print( "Connected" )
                //
                // Register the device shadows once connected.
                //
                
                self.iotDataManager.getShadow(self.thingName)
                
            case .disconnected:
                print( "Disconnected" )
                
            case .connectionRefused:
                print( "Connection Refused" )
                
            case .connectionError:
                print( "Connection Error" )
                
            case .protocolError:
                print( "Protocol Error" )
                
            default:
                print("unknown state: \(status.rawValue)")
            }
        }
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
