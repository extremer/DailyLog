//
//  dailyDataUnit.swift
//  DailyLog
//
//  Created by KangKyungwon on 2016. 7. 20..
//  Copyright © 2016년 KangKyungwon. All rights reserved.
//

import Foundation

class dailyDataUnit {
    var date: NSDate!
    var logs: [DailyLog]
    
    init (date: NSDate, logs: [DailyLog]) {
        self.date = date
        self.logs = logs
    }
}