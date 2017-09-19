//
//  linechartFormatter.swift
//  Autobot
//
//  Created by 田中智大 on 2017/09/19.
//  Copyright © 2017年 Tanaka, Tomohiro. All rights reserved.
//

import Foundation
import Charts

public class lineChartFormatter: NSObject, IAxisValueFormatter {
    
    public func showDate(dateArr: [Int]) -> [String] {
        var showedDateArr: [String] = [] //表示する日付
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "M/d\n" + "HH:mm"
        for dateElement in 0..<dateArr.count {
            let intToDate = Date(timeIntervalSince1970: TimeInterval(dateArr[dateElement]))
            let insertDateArr = dateformatter.string(from: intToDate)
            showedDateArr.append(insertDateArr)
        }
        
        return showedDateArr
    }
    
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        var showedXaxis: [String] = showDate(dateArr: timeStamps)

        return showedXaxis[Int(value)]
    }
}
