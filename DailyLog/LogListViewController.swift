//
//  LogListViewController.swift
//  DailyLog
//
//  Created by KangKyungwon on 2016. 7. 3..
//  Copyright © 2016년 KangKyungwon. All rights reserved.
//

import UIKit
import CoreData

class LogListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, logInfoDelegate {
    
    // MARK: Properties
    @IBOutlet weak var LogListTableView: UITableView!
    
    var context: NSManagedObjectContext!
    var entity: NSEntityDescription!
    //var managedObject: NSManagedObject!
    var fetchRequest: NSFetchRequest!
    
    //var color: UIColor?     //
    var workText: String?   //
    var startTime: String?
    var endTime: String?
    var during: String?
    
    var DailyLogs = [DailyLog]()
    var DailyLogObjects = [NSManagedObject]()
    
    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = UIApplication.sharedApplication().delegate as? UITabBarControllerDelegate
        
        let newVC = tabBarController?.viewControllers![1] as! ViewController
        newVC.delegate = self
        newVC.tabbarC = self.tabBarController!
        
        context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        entity = NSEntityDescription.entityForName("WorkLogInfo", inManagedObjectContext: context)
        
        // Core Data 최초 불러오기
        fetchRequest = NSFetchRequest.init(entityName: "WorkLogInfo")
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            DailyLogObjects = results as! [WorkLogInfo]
            DailyLogs.removeAll()
            for eachObject in DailyLogObjects {
                DailyLogs += [WorkLogInfoToDailyLog(eachObject as! WorkLogInfo)]
                //context.deleteObject(eachObject)
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        saveCoreData(context)
    }
    
    override func viewWillAppear(animated: Bool) {
        LogListTableView.reloadData()
    }
    
    // MARK: function
    func saveCoreData(context: NSManagedObjectContext) {
        do {
            try context.save()
        }
        catch let error as NSError{
            print(error)
        }
    }
    func deleteData(context: NSManagedObjectContext, object: NSManagedObject) {
        context.deleteObject(object)
        saveCoreData(context)
    }
    
    
    func WorkLogInfoToDailyLog(info: WorkLogInfo) -> DailyLog {
        let color: UIColor = NSKeyedUnarchiver.unarchiveObjectWithData(info.color!) as! UIColor
        let newLog = DailyLog.init(work: info.work!, startTime: info.startTime, endTime: info.endTime, during: info.during, color: color)
        return newLog
    }
    
    func writeLogInfo(workName:String, startTime:String, endTime:String, during:String, color: UIColor) {
        let newLog = DailyLog.init(work: workName, startTime: startTime, endTime: endTime, during: during, color: color)
        DailyLogs += [newLog]
        
        // Save Into CoreData
        let colorData: NSData = NSKeyedArchiver.archivedDataWithRootObject(color)
        let managedObject = NSEntityDescription.insertNewObjectForEntityForName("WorkLogInfo", inManagedObjectContext: context) as NSManagedObject
        managedObject.setValue(colorData, forKey: "color")
        managedObject.setValue(during, forKey: "during")
        managedObject.setValue(workName, forKey: "work")
        managedObject.setValue(startTime, forKey: "startTime")
        managedObject.setValue(endTime, forKey: "endTime")
        
        DailyLogObjects += [managedObject]
        
        do {
            try context.save()
        }
        catch let error as NSError{
            print(error)
        }
        LogListTableView.reloadData()
    }
    
    func changeTimeFormatToShow(time: String) -> String? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let date: NSDate? = dateFormatter.dateFromString(time)
        if let date = date {
            dateFormatter.dateFormat = "H"
            let hour = dateFormatter.stringFromDate(date)
            
            dateFormatter.dateFormat = "m"
            let min = dateFormatter.stringFromDate(date)
            
            dateFormatter.dateFormat = "s"
            let sec = dateFormatter.stringFromDate(date)
            
            if hour == "0" {
                if min == "0" {
                    let strTime = "\(sec)초"
                    return strTime
                }
                else {
                    let strTime = "\(min)분"
                    return strTime
                }
            }
            else {
                let strTime = "\(hour)시간 \(min)분"
                return strTime
            }
        }
        return nil
    }
    
    // MARK: TableView
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//       //
//    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DailyLogs.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "LogListTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? LogListTableViewCell
        if let cell = cell {
            let DailyLog = DailyLogs[indexPath.row]
            if let work = DailyLog.work {
                cell.workLabel.text = work
                if let color = DailyLog.color {
                    cell.colorLabel.backgroundColor = UIColor.clearColor()//color
                    cell.colorLabel.layer.backgroundColor = color.CGColor
                }
                else {
                    cell.colorLabel.text = ""
                }
                if let during = DailyLog.during {
                    let strTime = changeTimeFormatToShow(during)
                    cell.timeLabel.text = strTime
                }
                else {
                    cell.timeLabel.text = ""
                }
            }
        }
        return cell!
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let object = DailyLogObjects[indexPath.row]
            context.deleteObject(object)
            saveCoreData(context)
            DailyLogs.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
}
