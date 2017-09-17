//
//  DDBManager.swift
//  Autobot
//
//  Created by 田中智大 on 2017/09/17.
//  Copyright © 2017年 Tanaka, Tomohiro. All rights reserved.
//

import Foundation
import AWSDynamoDB

let UserDDBTableName = "UserInfoData" //username, device, roomname

class DDBDynamoDBManger : NSObject {
    class func describeTable() -> AWSTask<AnyObject> {
        let dynamoDB = AWSDynamoDB.default()
        
        // See if the test table exists.
        let describeTableInput = AWSDynamoDBDescribeTableInput()
        describeTableInput?.tableName = UserDDBTableName
        return dynamoDB.describeTable(describeTableInput!) as! AWSTask<AnyObject>
    }
    
}



class DDBTableRow :AWSDynamoDBObjectModel ,AWSDynamoDBModeling  {
    
    var username: String?
    var roomname: String?
    
    //set the default values of scores, wins and losses to 0
    var device: String?
    var method: String?

    
    //should be ignored according to ignoreAttributes
    var internalName:String?
    var internalState:NSNumber?
    
    class func dynamoDBTableName() -> String {
        return UserDDBTableName
    }
    
    class func hashKeyAttribute() -> String {
        return "username"
    }
    
    class func rangeKeyAttribute() -> String {
        return "roomname"
    }
    
    class func ignoreAttributes() -> [String] {
        return ["internalName", "internalState"]
    }
}
