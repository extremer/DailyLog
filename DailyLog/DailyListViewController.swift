//
//  DailyListViewController.swift
//  DailyLog
//
//  Created by KangKyungwon on 2016. 7. 18..
//  Copyright © 2016년 KangKyungwon. All rights reserved.
//

import UIKit
import CoreData

class DailyListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var shownDateTextField: UITextField!
    
    var context: NSManagedObjectContext!
    var entity: NSEntityDescription!
    var fetchRequest: NSFetchRequest!
    
    var workText: String?   //
    var startTime: String?
    var endTime: String?
    var during: String?
    
    //var DailyLogs = [[DailyLog]]()
    var DailyData = [dailyDataUnit]()  //[(date: NSDate, logs: [DailyLog])]()
    
    var DailyLogs = [DailyLog]()
    var DailyLogObjects = [NSManagedObject]()
    
    
    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        
        self.tabBarController?.delegate = UIApplication.sharedApplication().delegate as? UITabBarControllerDelegate
        
        let newVC = tabBarController?.viewControllers![1] as! ViewController
        newVC.delegate = self
        newVC.tabbarC = self.tabBarController!
        
        // DailyData를 CoreData에 저장해야함 
        // var date: NSDate!
        // var logs: [DailyLog]  이게 어레이라서 문제, 그것도 클래스 어레이 
        context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        entity = NSEntityDescription.entityForName("WorkLogInfo", inManagedObjectContext: context)
        
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
        DailyData = bindingLogsDaily(DailyLogs)
        //saveCoreData(context)
    }
    
    override func viewWillAppear(animated: Bool) {
        collectionView.reloadData()
        
        let numbOfItems = collectionView.numberOfItemsInSection(0)
        view.layoutIfNeeded()
        let scrollIndex = NSIndexPath.init(forRow: numbOfItems-1, inSection: 0)
        collectionView.scrollToItemAtIndexPath(scrollIndex, atScrollPosition: UICollectionViewScrollPosition.Right, animated: false)
        //LogListTableView.reloadData()
    }
    
    // MARK: Function
    
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
        let newLog = DailyLog.init(date: info.day!, work: info.work!, startTime: info.startTime, endTime: info.endTime, during: info.during, color: color)
        return newLog
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
                    let strTime = "\(min)분 \(sec)초"
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
    
    func genNSDateArray () -> [dailyDataUnit] {
        var genArray = [dailyDataUnit]()

        let calendar = NSCalendar.currentCalendar()
        let offset = NSDateComponents.init()
        let today = NSDate()
        
        for i in -30...30 {
            offset.setValue(i, forComponent: .Day)
            let day = calendar.dateByAddingComponents(offset, toDate: today, options: .MatchStrictly)
            //genArray.append([(day!, empty)])
            genArray.append(dailyDataUnit.init(date: day!, logs: []))
        }
        return genArray
    }
    
    func bindingLogsDaily(logs: [DailyLog]) -> [dailyDataUnit] {
        // 1. DailyLog를 시간순 정렬
        
        // 일단 정렬이 되어있다고 치고.. 
        
        // 2. dailyDataUnit array에 날짜 비교해가며 순차적으로 추가
        // DailyData
        
        var newDailyData = [dailyDataUnit]()
        for log in logs {
            let date = log.date
            if let date = date {
                if newDailyData.count == 0 {
                    newDailyData.append(dailyDataUnit.init(date: date, logs: [log]))
                }
                else {
                    let lastIndex = newDailyData.endIndex - 1
                    let lastIndexDate = newDailyData[lastIndex].date
                    
                    var order = NSCalendar.currentCalendar().compareDate(date, toDate: lastIndexDate, toUnitGranularity: .Day)
                    if order == NSComparisonResult.OrderedSame {
                        // data의 마지막 날짜와 log의 추가하려는 날짜가 같으면
                        newDailyData[lastIndex].logs += [log]
                    }
                    else {
                        // date의 마지막 날짜와 log 추가 날짜가 다르면..
                        let calendar = NSCalendar.currentCalendar()
                        let offset = NSDateComponents.init()
                        var dayAfter = 1
                        while order != NSComparisonResult.OrderedSame {
                            offset.setValue(dayAfter, forComponent: .Day)
                            let day = calendar.dateByAddingComponents(offset, toDate: lastIndexDate
                                , options: .MatchStrictly)
                            newDailyData.append(dailyDataUnit.init(date: day!, logs: []))
                            dayAfter += 1
                            order = NSCalendar.currentCalendar().compareDate(date, toDate: day!, toUnitGranularity: .Day)
                        }
                        let lastIndex = newDailyData.endIndex - 1
                        newDailyData[lastIndex].logs += [log]
                    }
                }
            }
        }
        // 오늘까지 추가하기
//        let today = NSDate()
//        let lastIndex = newDailyData.endIndex - 1
//        let lastIndexDate = newDailyData[lastIndex].date
//        var order = NSCalendar.currentCalendar().compareDate(today, toDate: lastIndexDate, toUnitGranularity: .Day)
//        while order != NSComparisonResult.OrderedSame {
//            let calendar = NSCalendar.currentCalendar()
//            let offset = NSDateComponents.init()
//            var dayAfter = 1
//            let day = calendar.dateByAddingComponents(offset, toDate: lastIndexDate
//                , options: .MatchStrictly)
//            newDailyData.append(dailyDataUnit.init(date: day!, logs: []))
//            dayAfter += 1
//            order = NSCalendar.currentCalendar().compareDate(today, toDate: day!, toUnitGranularity: .Day)
//        }
        return newDailyData
    }
    
    // MARK: CollectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return data.count
        return DailyData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellIdentifier = "basicCollectionViewCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! basicCollectionViewCell
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let collectionViewCell = cell as? basicCollectionViewCell else { return }
        
        
        // indexPath.row 를 넘길 때 날짜 매칭을 해서, 해당 날짜에 해당하는 데이터가 없으면 ? 
        // 있으면 그  indexPath.row 를 계산해서 넘기며 되는데 ...
        collectionViewCell.setTableViewDataSourceDelegate(self, forIndex: indexPath.row)
        
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // collectionView Cell Size. Height나중에 필요하면 고치기
        let screenSize = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        //let screenHeight = screenSize.height
        return CGSize.init(width: screenWidth, height: screenWidth)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    

}


extension DailyListViewController: UITableViewDelegate, UITableViewDataSource, logInfoDelegate {
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = DailyData[tableView.tag].date
        let dateTransform = NSDateFormatter.init()
        dateTransform.dateFormat = "yyyy.MM.dd"
        shownDateTextField.text = dateTransform.stringFromDate(date)
        return DailyData[tableView.tag].logs.count //??
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LogListTableViewCell", forIndexPath: indexPath) as! LogListTableViewCell
        //cell.testLabel.text = data[tableView.tag][indexPath.item]   // row? item?
        
        let DailyLog = DailyData[tableView.tag].logs[indexPath.row] //DailyLogs[indexPath.row]
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

        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //deselect
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func writeLogInfo(date: NSDate, workName:String, startTime:String, endTime:String, during:String, color: UIColor) {
        let newLog = DailyLog.init(date: date, work: workName, startTime: startTime, endTime: endTime, during: during, color: color)
        var lastIndex = DailyData.endIndex - 1
        
        
        // Save Into CoreData
        let colorData: NSData = NSKeyedArchiver.archivedDataWithRootObject(color)
        let managedObject = NSEntityDescription.insertNewObjectForEntityForName("WorkLogInfo", inManagedObjectContext: context) as NSManagedObject
        managedObject.setValue(date, forKey: "day")
        managedObject.setValue(colorData, forKey: "color")
        managedObject.setValue(during, forKey: "during")
        managedObject.setValue(workName, forKey: "work")
        managedObject.setValue(startTime, forKey: "startTime")
        managedObject.setValue(endTime, forKey: "endTime")
        
        do {
            try context.save()
        }
        catch let error as NSError{
            print(error)
        }

        // DailyData 에 추가
        if DailyData.count == 0 {
            //DailyData += [(date, [newLog])]
            DailyData.append(dailyDataUnit.init(date: date, logs: [newLog]))
        }
        else {
            let lastIndexDate = DailyData[lastIndex].date
            var order = NSCalendar.currentCalendar().compareDate(date, toDate: lastIndexDate, toUnitGranularity: .Day)
            if order == NSComparisonResult.OrderedSame {
                // array의 마지막 날짜가 오늘이라면 오늘 로그에 추가
                DailyData[lastIndex].logs += [newLog]
            }
            else {
                // array의 마지막 날짜가 오늘이 아니라면 오늘까지 추가
                let calendar = NSCalendar.currentCalendar()
                let offset = NSDateComponents.init()
                var dayAfter = 1
                while order != NSComparisonResult.OrderedSame {
                    offset.setValue(dayAfter, forComponent: .Day)
                    let day = calendar.dateByAddingComponents(offset, toDate: lastIndexDate, options: .MatchStrictly)
                    // 오늘이 되기 전까지는 계속 추가하기
                    DailyData.append(dailyDataUnit.init(date: day!, logs: []))
                    dayAfter += 1
                    lastIndex += 1
                    order = NSCalendar.currentCalendar().compareDate(date, toDate: day!, toUnitGranularity: .Day)
                }
                DailyData[lastIndex].logs += [newLog]
//                DailyData.append(dailyDataUnit.init(date: date, logs: [newLog]))
                
            }
        }
        
        DailyLogs += [newLog]   //
        collectionView.reloadData()
    }
}