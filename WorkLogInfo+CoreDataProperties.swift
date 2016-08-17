//
//  WorkLogInfo+CoreDataProperties.swift
//  DailyLog
//
//  Created by KangKyungwon on 2016. 7. 14..
//  Copyright © 2016년 KangKyungwon. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension WorkLogInfo {

    @NSManaged var day: NSDate?
    @NSManaged var color: NSData?
    @NSManaged var during: String?
    @NSManaged var endTime: String?
    @NSManaged var startTime: String?
    @NSManaged var work: String?

}
