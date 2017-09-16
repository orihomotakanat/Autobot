//
//  iotDevices.swift
//  Autobot
//
//  Created by 田中智大 on 2017/09/16.
//  Copyright © 2017年 Tanaka, Tomohiro. All rights reserved.
//

import Foundation

class iotDevices: NSObject {
    
    var displayName: String
    var detailText: String
    var icon: String
    var storyboard: String
    
    init(dispName: String, detail: String, icon: String, storyboard: String) {
        self.displayName = dispName
        self.detailText = detail
        self.icon = icon
        self.storyboard = storyboard
        super.init()
    }
}
