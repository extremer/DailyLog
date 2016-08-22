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
    var selectedCellIndexPath: NSIndexPath?
    var selectedCellTag: Int?
    var selectedObjectIndex: Int?
    
    var firstViewLayout = false
    var newItemAdded = false

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
                //context.deleteObject(eachObject)
                DailyLogs += [WorkLogInfoToDailyLog(eachObject as! WorkLogInfo)]
                
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        DailyData = bindingLogsDaily(DailyLogs)
        DailyLogs.removeAll()
        //saveCoreData(context)
    }
    
    override func viewWillAppear(animated: Bool) {
        collectionView.reloadData()
        if firstViewLayout == false {
            let numbOfItems = collectionView.numberOfItemsInSection(0)
            view.layoutIfNeeded()
            if numbOfItems != 0 {
                let scrollIndex = NSIndexPath.init(forRow: numbOfItems-1, inSection: 0)
                collectionView.scrollToItemAtIndexPath(scrollIndex, atScrollPosition: UICollectionViewScrollPosition.Right, animated: false)
                
                let dateTransform = NSDateFormatter.init()
                dateTransform.dateFormat = "yyyy.MM.dd"
                //if let date = lasDateInCoreData {}
                let date = NSDate()
                shownDateTextField.text = dateTransform.stringFromDate(date)
                
            }
            firstViewLayout = true
        }
        if newItemAdded == true {
            collectionView.layoutIfNeeded() //이거 대박
            let numbOfItems = collectionView.numberOfItemsInSection(0)
            let scrollIndex = NSIndexPath.init(forRow: numbOfItems-1, inSection: 0)
            collectionView.scrollToItemAtIndexPath(scrollIndex, atScrollPosition: UICollectionViewScrollPosition.Right, animated: false)
            newItemAdded = false
        }
        //LogListTableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
        let today = NSDate()
        let lastIndex = newDailyData.endIndex - 1
        let lastIndexDate = newDailyData[lastIndex].date
        var order = NSCalendar.currentCalendar().compareDate(today, toDate: lastIndexDate, toUnitGranularity: .Day)
        while order != NSComparisonResult.OrderedSame {
            let calendar = NSCalendar.currentCalendar()
            let offset = NSDateComponents.init()
            var dayAfter = 1
            offset.setValue(dayAfter, forComponent: .Day)
            let day = calendar.dateByAddingComponents(offset, toDate: lastIndexDate
                , options: .MatchStrictly)
            newDailyData.append(dailyDataUnit.init(date: day!, logs: []))
            dayAfter += 1
            order = NSCalendar.currentCalendar().compareDate(today, toDate: day!, toUnitGranularity: .Day)
        }
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
        collectionView.layoutIfNeeded()
        let size = collectionView.bounds.size
        return CGSizeMake(size.width, size.height)
//        let size = UIScreen.mainScreen().bounds.size
//        return CGSizeMake(size.width, size.height)
    }
    
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail"{
            let naviC = segue.destinationViewController as! UINavigationController
            let detailViewController = naviC.topViewController as! LogDatailTableViewController
            if let selectedCellTag = selectedCellTag{
                if let selectedCellIndexPath = selectedCellIndexPath{
                    let selectedLog = DailyData[selectedCellTag].logs[selectedCellIndexPath.row]
                    detailViewController.logData = selectedLog
                    selectedObjectIndex = findIndexOfManagedObject(selectedLog)
                }
            }
        }
    }
    
    // unwind segue
    @IBAction func unwindToLogList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? LogDatailTableViewController {
            if sender.identifier == "DeleteLog" {
                if let selectedCellTag = selectedCellTag{
                    if let selectedCellIndexPath = selectedCellIndexPath{
                        let deletedLog = DailyData[selectedCellTag].logs[selectedCellIndexPath.row]
                        DailyData[selectedCellTag].logs.removeAtIndex(selectedCellIndexPath.row)
                        // deletet
                        deleteLogInfo(deletedLog)
                        collectionView.reloadData()
                        //?? reloadData바꿔보기~
                        
                    }
                }
            } else if sender.identifier == "SaveLog" {
                let log = sourceViewController.logData!
                
                if let index = selectedObjectIndex {
                    let selectedObject = DailyLogObjects[index]
                    
                    let colorData: NSData = NSKeyedArchiver.archivedDataWithRootObject(log.color!)
                    selectedObject.setValue(log.date, forKey: "day")
                    selectedObject.setValue(log.during, forKey: "during")
                    selectedObject.setValue(log.work, forKey: "work")
                    selectedObject.setValue(log.startTime, forKey: "startTime")
                    selectedObject.setValue(log.endTime, forKey: "endTime")
                    selectedObject.setValue(colorData, forKey: "color")

                    do {
                        try context.save()
                    }
                    catch let error as NSError{
                        print(error)
                    }
                    
                    //
                    
                    collectionView.reloadData()
                }
            }
        }
        selectedObjectIndex = nil
        selectedCellTag = nil
        selectedCellIndexPath = nil
    }
    
    func findIndexOfManagedObject(log: DailyLog) -> Int{
        // log와 같은 내용의 값을
        // DailyLogObjects에서 찾는다
        var idx = 0
        for obj in DailyLogObjects {
            let obj = obj as! WorkLogInfo
            let colorData: NSData = NSKeyedArchiver.archivedDataWithRootObject(log.color!)
            let d = obj.day
            let w = obj.work
            let s = obj.startTime
            let e = obj.endTime
            let dd = obj.during
            if log.date == obj.day && colorData == obj.color && log.work == obj.work && log.startTime == obj.startTime && log.endTime == obj.endTime && log.during == obj.during {
                break
            }
            idx += 1
        }
        return idx
    }
    
    func deleteLogInfo(log: DailyLog) {
        let index = findIndexOfManagedObject(log)
        context.deleteObject(DailyLogObjects[index])
        do {
            try context.save()
        }
        catch let error as NSError{
            print(error)
        }
    }
    
}


extension DailyListViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, logInfoDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DailyData[tableView.tag].logs.count //??
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LogListTableViewCell", forIndexPath: indexPath) as! LogListTableViewCell
        
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
       
        selectedCellTag = tableView.tag
        selectedCellIndexPath = indexPath
        
        // segue 호출
        performSegueWithIdentifier("ShowDetail", sender: self)
         //deselect
        //tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: ScrollViewDelegate

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // 현재 collectionviewcell을 가져온다
        let scrollPosition = scrollView.contentOffset   // current view의 시작point
        var idx = 0
        
        
        let visibleCells = collectionView.visibleCells()    //[0] as! basicCollectionViewCell
        var displayedCollectionViewCell: basicCollectionViewCell?
        for cell in visibleCells {
            let frame = cell.frame
            if scrollPosition.x == frame.origin.x {
                displayedCollectionViewCell = cell as? basicCollectionViewCell
                break
            }
            idx += 1
        }
        if let displayedCollectionViewCell = displayedCollectionViewCell {
            let displayedTableView = displayedCollectionViewCell.dailyTableView
            let date = DailyData[displayedTableView.tag].date
            let dateTransform = NSDateFormatter.init()
            dateTransform.dateFormat = "yyyy.MM.dd"
            shownDateTextField.text = dateTransform.stringFromDate(date)
        }
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
        
        DailyLogObjects += [managedObject]
        
        // DailyData 에 추가
        if DailyData.count == 0 {
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
                
            }
        }
        newItemAdded = true
        //DailyLogs += [newLog]   //
        collectionView.reloadData()
    }
}