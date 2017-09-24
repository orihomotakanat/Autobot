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
    
    //thingName
    let thingName = "your-thing-name" //** 後に移動前segueからcellの値を受け取るようにする **

    //Timer
    @IBOutlet var reservedTimerPicker: UIDatePicker!
    
    //AWSIoT
    var iotDataManager: AWSIoTDataManager!
    
    //DeviceStatus
    @IBOutlet var deviceStatus: UILabel!
    
    
    //Timer
    @IBOutlet var Hour: UILabel!
    @IBOutlet var Minute: UILabel!
    @IBOutlet var Second: UILabel!
    @IBOutlet var colonHourAndMinute: UILabel!
    @IBOutlet var colonMinutesAndSecond: UILabel!
    
    var counter: Int = 0 //タイマーのカウント
    var internalHour: Int = 0 //Hour
    var internalMin: Int = 0 //Min
    var internalSec: Int = 0 //Second
    
    var presentTime = Timer()
    var reservedConfirmation = true //trueの時1回目のカウントの時
    var alreadyStartedTimer = true //trueの時はまだOnになってないorOFFが押された時、falseの時はTimerが動いている時
    var timerIdentifier = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Preparation of tapticEngine
        tapticGenerator.prepare()
        tapticNotficationGenerator.prepare() //tapticEngine for timer
        
        //CoundDownTimer: default -> invisible
        Hour.isHidden = true
        Minute.isHidden = true
        Second.isHidden = true
        colonHourAndMinute.isHidden = true
        colonMinutesAndSecond.isHidden = true
                
        // Do any additional setup after loading the view.
        reservedTimerPicker.setValue(UIColor.white, forKey: "textColor")
        //IndexPath
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
        let publishTopic = "\(thingName)/control/on"
        print("Turn on")
        iotDataManager.publishString("turn on", onTopic: publishTopic, qoS:.messageDeliveryAttemptedAtMostOnce)
        tapticGenerator.impactOccurred()

    }
    
    
    //When pushing reserve button
    @IBAction func pushedReserve(_ sender: Any) {
        //処理 //ここだけtimer側にturndOn()を記載
        if alreadyStartedTimer {
            presentTime = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.passed), userInfo: nil, repeats: true)
            alreadyStartedTimer = false
        }
        
    }
    
    //When pusing on button
    @IBAction func pushedOn(_ sender: Any) {
        //処理
        //CoundDownTimer: turnOn -> invisible
        reservedTimerPicker.isHidden = true
        Hour.isHidden = true
        Minute.isHidden = true
        Second.isHidden = true
        colonHourAndMinute.isHidden = true
        colonMinutesAndSecond.isHidden = true
        
        //TurnOn
        turnedOn()
        
        reservedConfirmation = false
        presentTime.invalidate()
    }
    
    //When pushing off button
    @IBAction func pushedOff(_ sender: Any) {
        
        //CoundDownTimer: turnOff -> pickerView; visible
        reservedTimerPicker.isHidden = false
        Hour.isHidden = true
        Minute.isHidden = true
        Second.isHidden = true
        colonHourAndMinute.isHidden = true
        colonMinutesAndSecond.isHidden = true
        
        presentTime.invalidate()
        reservedConfirmation = true //reserveされていない状態に戻す
        alreadyStartedTimer = true //timerが作動していない状態に戻す
        
        //処理
        let publishTopic = "\(thingName)/control/off"
        print("Turn off")
        iotDataManager.publishString("turn on", onTopic: publishTopic, qoS:.messageDeliveryAttemptedAtMostOnce)
        tapticGenerator.impactOccurred()
    }
    
    //reserve Timer用の設定
    func passed(timeCount: Timer){
        if reservedConfirmation {
            counter = Int(reservedTimerPicker.countDownDuration)
            
            //CoundDownTimer: reserved -> pickerView; invisible
            reservedTimerPicker.isHidden = true
            Hour.isHidden = false
            Minute.isHidden = false
            Second.isHidden = false
            colonHourAndMinute.isHidden = false
            colonMinutesAndSecond.isHidden = false
            
            reservedConfirmation = false
        }
        
        internalHour = Int(counter/3600) //Hour
        internalMin = Int((counter - internalHour * 3600) / 60) //Min
        internalSec = Int(counter - internalHour*3600 - internalMin*60) //sec
        counter = counter - 1
        //Timer設定
        if counter == 0 {
            //ここにAirconの機能を入れる
            turnedOn()
            
            tapticNotficationGenerator.notificationOccurred(.success)
            presentTime.invalidate() //Timer停止
            reservedConfirmation = true //reserveされていない状態に戻す
            alreadyStartedTimer = true //timerが作動していない状態に戻す
            
            //ON表示
            Hour.isHidden = true
            Minute.isHidden = true
            Second.isHidden = true
            colonHourAndMinute.isHidden = true
            colonMinutesAndSecond.isHidden = true
        
            print("Timer is stopped & Start Aircon")
            
        } else {
            Hour.text = String(format: "%02d", internalHour) //タイマーのカウントする
            Minute.text = String(format: "%02d", internalMin)
            Second.text = String(format: "%02d", internalSec)
            print(counter) //For debug
            
        }
    }
    
    
    
    //MQTT callback
    func mqttEventCallback( _ status: AWSIoTMQTTStatus ) {
        DispatchQueue.main.async {
            print("connection status = \(status.rawValue)")
            switch(status)
            {
            case .connecting:
                print( "Connecting..." )
                self.deviceStatus.text = "Connecting..."
                
            case .connected:
                print( "Connected" )
                self.deviceStatus.text = "Connected"
                //
                // Register the device shadows once connected.
                //
                self.iotDataManager.getShadow(self.thingName)
                
                
            case .disconnected:
                print( "Disconnected" )
                self.deviceStatus.text = "Disconnected"
                
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
