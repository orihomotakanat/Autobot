//
//  iotDevices.swift
//  Autobot
//
//  Created by 田中智大 on 2017/09/16.
//  Copyright © 2017年 Tanaka, Tomohiro. All rights reserved.
//

import Foundation

class iotDevices: NSObject {
    
    var roomName: String
    var device: String
    var icon: String
    var storyboard: String
    
    init(roomName: String, device: String, icon: String, storyboard: String) {
        self.roomName = roomName
        self.device = device
        self.icon = icon
        self.storyboard = storyboard
        super.init()
    }
}
