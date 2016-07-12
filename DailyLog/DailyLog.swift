//
//  DailyLog.swift
//  DailyLog
//
//  Created by KangKyungwon on 2016. 7. 3..
//  Copyright © 2016년 KangKyungwon. All rights reserved.
//

import UIKit

class DailyLog {
    var work: String!
    var color: UIColor?
    var startTime: String?
    var endTime: String?
    var during: String? //NSTimeInterval?  //??
    
    
    init(work: String, startTime: String?, endTime: String?, during: String?, color: UIColor?) {
        self.work = work
        self.startTime = startTime
        self.endTime = endTime
        self.during = during
        self.color = color
    }
}
