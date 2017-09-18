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

class RoomTemperatureInfo: UIViewController {
    
    //APIGateway settings
    //let serviceClient = AUTOBOTLambdaMicroserviceClient.client(forKey: "AUTOBOTLambdaMicroserviceClient")
    let serviceClient = AUTOBOTLambdaMicroserviceClient.default()
    
    //APIGateway - variables
    let headerParameters = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]
    var queryParameters = [String: String]()
    let toLambdaPath = "/GetDataOfDDB" //APIGateway method path
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(serviceClient)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Show temperature history graph
        queryParameters.updateValue("IoTDeviceData", forKey: "TableName") //DynamoDB TableData
        let apiRequest = AWSAPIGatewayRequest(httpMethod: "GET", urlString: toLambdaPath, queryParameters: queryParameters, headerParameters: headerParameters, httpBody: nil)
        
        serviceClient.invoke(apiRequest).continueWith(block: {[weak self](task: AWSTask) -> AnyObject? in
            guard self != nil else { return nil }
            
            let result: AWSAPIGatewayResponse! = task.result
            //For debug
            let responseString = String(data: result.responseData!, encoding: String.Encoding.utf8)
            print(responseString!)
            print(result.statusCode)
            
            return nil
        })
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
