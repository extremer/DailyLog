//
//  LogListViewController.swift
//  DailyLog
//
//  Created by KangKyungwon on 2016. 7. 3..
//  Copyright © 2016년 KangKyungwon. All rights reserved.
//

import UIKit

class LogListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, logInfoDelegate {
    
    // MARK: Properties
    @IBOutlet weak var LogListTableView: UITableView!
    
    var addLog: Bool!
    var color: UIColor?     //
    //var colorName: String?  //
    var workText: String?   //
    var startTime: String?
    var endTime: String?
    var during: String?
    
    var DailyLogs = [DailyLog]()
    
    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = UIApplication.sharedApplication().delegate as? UITabBarControllerDelegate
        
        let newVC = tabBarController?.viewControllers![1] as! ViewController
            //self.tabBarController!.storyboard?.instantiateViewControllerWithIdentifier("addNewWork") as? ViewController {
        newVC.delegate = self
        newVC.tabbarC = self.tabBarController!
        
        if addLog != nil {
        if addLog == true {
            if let work = workText{
                //새로 추가되는 거라면!
                let newDailyLog = DailyLog.init(work: work, startTime: startTime, endTime: endTime, during: during, color: color)
                DailyLogs += [newDailyLog]
            }
        }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        LogListTableView.reloadData()
    }
    
    // MARK: function
    func writeLogInfo(workName:String, startTime:String, endTime:String, during:String, color: UIColor) {
        let newLog = DailyLog.init(work: workName, startTime: startTime, endTime: endTime, during: during, color: color)
        DailyLogs += [newLog]
        
        //tabBarController?.selectedIndex = 0
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
                    let strTime = "\(min)분"// \(sec)초"
                    return strTime
                }
            }
            else {
                let strTime = "\(hour)시간 \(min)분"// \(sec)초"
                return strTime
            }
        }
        return nil
    }
    
    // MARK: TableView
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        //
//    }
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
                    cell.colorLabel.backgroundColor = color
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
}
