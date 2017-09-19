//
//  RoomTemperatureInfo.swift
//  Autobot
//
//  Created by Tanaka, Tomohiro on 2017/09/11.
//  Copyright © 2017年 Tanaka, Tomohiro. All rights reserved.
//

import UIKit
import SwiftyJSON
import AWSIoT
import AWSCore
import AWSAPIGateway
import SwiftyJSON
import Charts

var timeStamps: [Int] = [] //all timeStamps of user data - 後にfunc invoke...の中に入れる

class RoomTemperatureInfo: UIViewController {
    
    //AWSIoT
    let thingName = "your-thing-name" //thingName "your-thing-name"
    var iotDataManager: AWSIoTDataManager!
    @IBOutlet var currentTemperatureLabel: UILabel!
    @IBOutlet var currentHumidityLabel: UILabel!
    
    //APIGateway settings
    let serviceClient = AUTOBOTLambdaMicroserviceClient.default()
    
    //APIGateway - variables
    let headerParameters = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]
    var queryParameters = [String: String]()
    let toLambdaPath = "/GetDataOfDDB" //APIGateway method path
    
    //ForLineChartFormat
    @IBOutlet var roomTemperatureView: LineChartView! {
        didSet {
            //X-Axis
            roomTemperatureView.xAxis.labelPosition = .bottom //x軸ラベル下側に表示
            roomTemperatureView.xAxis.labelFont = UIFont.systemFont(ofSize: 13) //x軸のフォントの大きさ
            roomTemperatureView.xAxis.labelCount = Int(4)
            roomTemperatureView.xAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //x軸ラベルの色
            roomTemperatureView.xAxis.axisLineColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //x軸の色
            roomTemperatureView.xAxis.axisLineWidth = CGFloat(1) //x軸の太さ
            roomTemperatureView.xAxis.drawGridLinesEnabled = false //x軸のグリッド表示(今回は表示しない)
            roomTemperatureView.xAxis.valueFormatter = lineChartFormatter() //x軸の仕様
            
            
            //Y-Axis
            roomTemperatureView.rightAxis.enabled = false
            roomTemperatureView.leftAxis.enabled = true
            roomTemperatureView.leftAxis.axisMaximum = 40
            roomTemperatureView.leftAxis.axisMinimum = 0
            roomTemperatureView.leftAxis.labelFont = UIFont.systemFont(ofSize: 11) //y左軸のフォントの大きさ
            roomTemperatureView.leftAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //y軸ラベルの色
            roomTemperatureView.leftAxis.axisLineColor = #colorLiteral(red: 0.001564681064, green: 0.05989853293, blue: 0.1638002098, alpha: 1) //今回はy軸消すためにBGと同じ色にしている
            roomTemperatureView.leftAxis.drawAxisLineEnabled = false //y左軸の表示(今回は表示しない)
            roomTemperatureView.leftAxis.labelCount = Int(4) //y軸ラベルの表示数
            roomTemperatureView.leftAxis.drawGridLinesEnabled = true //y軸のグリッド表示(今回は表示する)
            roomTemperatureView.leftAxis.gridColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) //y軸グリッドの色
            
            //Others - UISettings
            roomTemperatureView.noDataFont = UIFont.systemFont(ofSize: 30) //Noデータ時の表示フォント
            roomTemperatureView.noDataTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //Noデータ時の文字色
            roomTemperatureView.noDataText = "Loading..."//"Keep Waiting" //Noデータ時に表示する文字 今回はインジケータで表示するのでなし
            roomTemperatureView.legend.enabled = false //"■ months"のlegendの表示
            roomTemperatureView.dragDecelerationEnabled = true //指を離してもスクロール続くか
            roomTemperatureView.dragDecelerationFrictionCoef = 0.6 //ドラッグ時の減速スピード(0-1)
            roomTemperatureView.chartDescription?.text = nil //Description(今回はなし)
            //roomTemperatureView.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1) //Background Color
            //.animateは表示直前で呼ぶためにグラフ描画の直前の部分かく
            
        }
    }
    let currentTime = Date().timeIntervalSince1970 //Int (Unixtime)

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        iotDataManager = AWSIoTDataManager.default()
        iotDataManager.connectUsingWebSocket(withClientId: UUID().uuidString, cleanSession: true, statusCallback: mqttEventCallback)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Show temperature history graph
        invokeApiGw()
        timeStamps.removeAll() //timeStampはglobalVarialbeなため値が保持される。ここで配列を空にしておく。
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.currentTemperatureLabel.text = "load.."
        self.currentHumidityLabel.text = "load.."
    }
    
    //invokeAPIGW - GETonly
    func invokeApiGw() {
        var roomTemperatures: [Double] = [] //user all roomTemperature
        var userDataPairs: [Int: Double] = [:] //add user data as Key-Value
        
        
        queryParameters.updateValue("IoTDeviceData", forKey: "TableName") //DynamoDB TableData "IoTDeviceData", Test: "sampleFromIoT"
        let apiRequest = AWSAPIGatewayRequest(httpMethod: "GET", urlString: toLambdaPath, queryParameters: queryParameters, headerParameters: headerParameters, httpBody: nil)
        
        serviceClient.invoke(apiRequest).continueWith(block: {[weak self](task: AWSTask) -> AnyObject? in
            guard self != nil else { return nil }
            
            let result: AWSAPIGatewayResponse! = task.result
            //For debug
            let responseString = String(data: result.responseData!, encoding: String.Encoding.utf8)
            print(responseString!)
            print(result.statusCode)
            
            
            //Fetching Data from DDB
            var userJsonData = JSON(data: result.responseData!)
            let jsonDataCount = Int(userJsonData["Items"].count)
            let timeRange: Int = Int(self!.currentTime) - 86400 //timeRange: 1day
            
            
            // - store data as Key-Value & arrange data in time range of 1day
            if jsonDataCount <= 1 {
                print("Error")
            } else {
                for countNumber in 0...jsonDataCount-1 {
                    //if 1day前以外のデータはappendしない様に設定する curretUnixTime - unixtimeFromDynamo <= 3day
                    if userJsonData["Items"][countNumber]["timeStamp"].intValue >= timeRange {
                        let timeStamp = userJsonData["Items"][countNumber]["timeStamp"].intValue //timeStamp
                        let roomTemperature = userJsonData["Items"][countNumber]["data"]["roomTemperature"].doubleValue //roomTemperature
                        userDataPairs[timeStamp] = roomTemperature //key-value式で各時間に対する温度を格納
                    }
                }
            }
            

            // - Arrangement of timeStamp - roomTemperature pair
            for (timeStamp, roomTemperature) in userDataPairs.sorted(by: {$0 < $1}) {
                timeStamps.append(timeStamp)
                roomTemperatures.append(roomTemperature)
            }
            
            DispatchQueue.main.async {
                self?.drawLineChart(xValArr: timeStamps, yValArr: roomTemperatures)
            }
            
            return nil
        })
    }
    
    //draw room temeprature history graph as LineChart
    func drawLineChart(xValArr: [Int], yValArr: [Double]) {
        var yValues : [ChartDataEntry] = [ChartDataEntry]()
        
        for i in 0 ..< xValArr.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: yValArr[i])
            yValues.append(dataEntry)
        }
        
        let data = LineChartData()
        let dataSets = LineChartDataSet(values: yValues, label: "Dates")
        
        /** Graphs UI settings **/
        // - Gradient inner of graph
        let gradientColors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 0.2196078449, green: 1, blue: 0.8549019694, alpha: 1).withAlphaComponent(0.3).cgColor] as CFArray
        let colorLocations:[CGFloat] = [0.7, 0.0]
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
        dataSets.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
        
        // - Line, Plot, Line-format etc...
        dataSets.lineWidth = 3.0
        dataSets.drawCirclesEnabled = false
        dataSets.mode = .cubicBezier
        dataSets.fillAlpha = 0.8 //Curve-line is not trasparent
        dataSets.drawFilledEnabled = true //paint under curve-line
        dataSets.drawValuesEnabled = false //Label of plot
        dataSets.highlightColor = #colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1) //x, y line when choosing plot
        dataSets.colors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)] //Color of drawing graph
        /** UP TO THIS POINT **/
        
        data.addDataSet(dataSets)
        roomTemperatureView.animate(xAxisDuration: 1.2, yAxisDuration: 1.5, easingOption: .easeInOutElastic) //Animation settings when showed
        self.roomTemperatureView.data = data
        
    }
    
    //Fetch current room temperature and humidity and show under view
    func fetchCurrentData() {
        let subscribeTopic = "\(thingName)/present"
        print(subscribeTopic)
        iotDataManager.subscribe(toTopic: subscribeTopic, qoS: .messageDeliveryAttemptedAtMostOnce, messageCallback: { (payload) in
            //let stringValue = NSString(data: payload, encoding: String.Encoding.utf8.rawValue)!
            let currentPayload = JSON(data: payload) //Subscribed payload
            let currentTemperature = currentPayload["currentTemperature"].stringValue
            let currentHumidity = currentPayload["currentHumidity"].stringValue
            
            self.currentTemperatureLabel.text = currentTemperature
            self.currentHumidityLabel.text = currentHumidity

        })
    }
    
    //MQTTcallback
    func mqttEventCallback( _ status: AWSIoTMQTTStatus )
    {
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
                self.fetchCurrentData()
                
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func backToRemoteControllerView(_ sender: Any) {
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
