//
//  DailyListViewController.swift
//  DailyLog
//
//  Created by KangKyungwon on 2016. 7. 18..
//  Copyright © 2016년 KangKyungwon. All rights reserved.
//

import UIKit
import CoreData

class DailyListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, LogInfoDelegate, UIScrollViewDelegate, SegueDelegate {

    // MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var shownDateTextField: UITextField!
    
    var context: NSManagedObjectContext!
    var entity: NSEntityDescription!
    var fetchRequest: NSFetchRequest<WorkLogInfo>!
    
    var workText: String?   //
    var startTime: String?
    var endTime: String?
    var during: String?
    
    var dailyData = [dailyDataUnit]()
    
    var dailyLogObjects = [NSManagedObject]()
    var selectedCellIndexPath: IndexPath?
    var selectedCellTag: Int?
    var selectedObjectIndex: Int?
    
    var firstViewLayout = false
    var newItemAdded = false

    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate

//        let newVC = tabBarController?.viewControllers![1] as! AddNewLogViewController
//        newVC.delegate = self
//        newVC.tabbarC = self.tabBarController!
        
        var dailyLogs = [DailyLog]()
        context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        entity = NSEntityDescription.entity(forEntityName: "WorkLogInfo", in: context)
        
        fetchRequest = NSFetchRequest.init(entityName: "WorkLogInfo")
        do {
            
            let results = try context.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            dailyLogObjects = results as! [WorkLogInfo]

            for eachObject in dailyLogObjects {
                //context.deleteObject(eachObject)
                dailyLogs += [workLogInfoToDailyLog(info: eachObject as! WorkLogInfo)]   
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        dailyData = bindingLogsDaily(logs: dailyLogs)
        dailyLogs.removeAll()
    }
    // viewWillApear, viewDidLayoutSubview다시공부하기 
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.reloadData()
        if firstViewLayout == false {
            let numbOfItems = collectionView.numberOfItems(inSection: 0)
            
            view.layoutIfNeeded()
            if numbOfItems != 0 {
                let scrollIndex = IndexPath.init(row: numbOfItems-1, section: 0)
                collectionView.scrollToItem(at: scrollIndex, at: UICollectionViewScrollPosition.right, animated: false)
            }
            let dateTransform = DateFormatter.init()
            dateTransform.dateFormat = "yyyy.MM.dd"
            let date = NSDate()
            shownDateTextField.text = dateTransform.string(from: date as Date)
            firstViewLayout = true
        }
        if newItemAdded == true {
            collectionView.layoutIfNeeded() //이거 대박
            let numbOfItems = collectionView.numberOfItems(inSection: 0)
            let scrollIndex = IndexPath.init(row: numbOfItems-1, section: 0)
            collectionView.scrollToItem(at: scrollIndex, at: UICollectionViewScrollPosition.right, animated: false)
            newItemAdded = false
        }
        collectionView.layoutIfNeeded()
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
        context.delete(object)
        saveCoreData(context: context)
    }
    
    func workLogInfoToDailyLog(info: WorkLogInfo) -> DailyLog {
        let color: UIColor = NSKeyedUnarchiver.unarchiveObject(with: info.color! as Data) as! UIColor
        let newLog = DailyLog.init(date: info.day!, work: info.work!, startTime: info.startTime, endTime: info.endTime, during: info.during, color: color)
        return newLog
    }
    
    func genNSDateArray () -> [dailyDataUnit] {
        var genArray = [dailyDataUnit]()

        let calendar = NSCalendar.current
        let offset = NSDateComponents.init()
        let today = NSDate()
        
        for i in -30...30 {
            offset.setValue(i, forComponent: .day)
            //let day = calendar.date(byAdding: offset as DateComponents, to: today as Date, wrappingComponents: .matchStrictly)
            let day = calendar.date(byAdding: offset as DateComponents, to: today as Date)
            
            //genArray.append([(day!, empty)])
            genArray.append(dailyDataUnit.init(date: day! as NSDate, logs: []))
        }
        return genArray
    }
    
    func bindingLogsDaily(logs: [DailyLog]) -> [dailyDataUnit] {
        // DailyLog: 전체 Log Data
        // dailyDataUnit: 날짜별로 묶은 Log Data
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
                    
                    var order = NSCalendar.current.compare(date as Date, to: lastIndexDate as! Date, toGranularity: .day)
                    //var order = NSCalendar.currentCalendar.compareDate(date, toDate: lastIndexDate, toUnitGranularity: .Day)
                    if order == ComparisonResult.orderedSame {
                        // data의 마지막 날짜와 log의 추가하려는 날짜가 같으면
                        newDailyData[lastIndex].logs += [log]
                    }
                    else {
                        // date의 마지막 날짜와 log 추가 날짜가 다르면..
                        let calendar = NSCalendar.current
                        let offset = NSDateComponents.init()
                        var dayAfter = 1
                        while order != ComparisonResult.orderedSame {
                            offset.setValue(dayAfter, forComponent: .day)
                            let day = calendar.date(byAdding: offset as DateComponents, to: lastIndexDate as! Date)
                            newDailyData.append(dailyDataUnit.init(date: day! as NSDate, logs: []))
                            dayAfter += 1
                            order = NSCalendar.current.compare(date as Date, to: day!, toGranularity: .day)
                        }
                        let lastIndex = newDailyData.endIndex - 1
                        newDailyData[lastIndex].logs += [log]
                    }
                }
            }
        }
        // 데이터가 오늘 이전까지만 있더라도, CollectionViewCell은 오늘까지 추가하기
        let today = NSDate()
        let lastIndex = newDailyData.endIndex - 1
        if lastIndex == -1 {
            return newDailyData
        }
        let lastIndexDate = newDailyData[lastIndex].date
        var order = NSCalendar.current.compare(today as Date, to: lastIndexDate as! Date, toGranularity: .day)
        
        var dayAfter = 1
        while order != ComparisonResult.orderedSame {
            let calendar = NSCalendar.current
            let offset = NSDateComponents.init()
            offset.setValue(dayAfter, forComponent: .day)
            let day = calendar.date(byAdding: offset as DateComponents, to: lastIndexDate as! Date)

            newDailyData.append(dailyDataUnit.init(date: day! as NSDate, logs: []))
            dayAfter += 1
            order = NSCalendar.current.compare(today as Date, to: day! as Date, toGranularity: .day)
        }
        return newDailyData
    }
    
    // MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return data.count
        return dailyData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "basicCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath as IndexPath) as! BasicCollectionViewCell
        cell.logs = dailyData[indexPath.row].logs
        cell.tableViewTag = indexPath.row
        cell.delegate = self
        cell.dailyTableView.reloadData()

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard cell is BasicCollectionViewCell else { return }
        
        //collectionViewCell.setTableViewDataSourceDelegate(dataSourceDelegate: self, forIndex: indexPath.row)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.layoutIfNeeded()
        let size = collectionView.bounds.size
        return CGSize(width: size.width, height: size.height)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "ShowDetail"{
            let naviC = segue.destination as! UINavigationController
            let detailViewController = naviC.topViewController as! LogDatailTableViewController
            if let selectedCellTag = selectedCellTag{
                if let selectedCellIndexPath = selectedCellIndexPath{
                    let selectedLog = dailyData[selectedCellTag].logs[selectedCellIndexPath.row]
                    detailViewController.logData = selectedLog
                    selectedObjectIndex = findIndexOfManagedObject(log: selectedLog)
                }
            }
        }
    }
    func performSegueWith(ID: String, selectedTag: Int, selectedIndexPath: IndexPath)
    {
        selectedCellTag = selectedTag
        selectedCellIndexPath = selectedIndexPath
        performSegue(withIdentifier: "ShowDetail", sender: self)
    }
    // unwind segue
    @IBAction func unwindToLogList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? LogDatailTableViewController {
            if sender.identifier == "DeleteLog" {
                if let selectedCellTag = selectedCellTag{
                    if let selectedCellIndexPath = selectedCellIndexPath{
                        let deletedLog = dailyData[selectedCellTag].logs[selectedCellIndexPath.row]
                        dailyData[selectedCellTag].logs.remove(at: selectedCellIndexPath.row)
                        deleteLogInfo(log: deletedLog)
                        collectionView.reloadData()
                    }
                }
            } else if sender.identifier == "SaveLog" {
                let log = sourceViewController.logData!
                
                if let index = selectedObjectIndex {
                    let selectedObject = dailyLogObjects[index]
                    
                    let colorData: NSData = NSKeyedArchiver.archivedData(withRootObject: log.color!) as NSData
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
        for obj in dailyLogObjects {
            let obj = obj as! WorkLogInfo
            let colorData: NSData = NSKeyedArchiver.archivedData(withRootObject: log.color!) as NSData
            if log.date == obj.day && colorData == obj.color && log.work == obj.work && log.startTime == obj.startTime && log.endTime == obj.endTime && log.during == obj.during {
                break
            }
            idx += 1
        }
        return idx
    }
    
    func deleteLogInfo(log: DailyLog) {
        let index = findIndexOfManagedObject(log: log)
        context.delete(dailyLogObjects[index])
        do {
            try context.save()
        }
        catch let error as NSError{
            print(error)
        }
    }
    // MARK: LogInfoDelegate
    func writeLogInfo(date: NSDate, workName:String, startTime:String, endTime:String, during:String, color: UIColor) {
        let newLog = DailyLog.init(date: date, work: workName, startTime: startTime, endTime: endTime, during: during, color: color)
        var lastIndex = dailyData.endIndex - 1
        
        // DailyData 에 추가
        if dailyData.count == 0 {
            dailyData.append(dailyDataUnit.init(date: date, logs: [newLog]))
        }
        else {
            let lastIndexDate = dailyData[lastIndex].date
            var order = NSCalendar.current.compare(date as Date, to: lastIndexDate as! Date, toGranularity: .day)
            
            if order == ComparisonResult.orderedSame {
                // array의 마지막 날짜가 오늘이라면 오늘 로그에 추가
                dailyData[lastIndex].logs += [newLog]
            }
            else {
                // array의 마지막 날짜가 오늘이 아니라면 오늘까지 추가
                let calendar = NSCalendar.current
                let offset = NSDateComponents.init()
                var dayAfter = 1
                while order != ComparisonResult.orderedSame {
                    offset.setValue(dayAfter, forComponent: .day)
                    let day = calendar.date(byAdding: offset as DateComponents, to: lastIndexDate as! Date)
                    //let day = calendar.dateByAddingComponents(offset, toDate: lastIndexDate, options: .MatchStrictly)
                    // 오늘이 되기 전까지는 계속 추가하기
                    dailyData.append(dailyDataUnit.init(date: day! as NSDate, logs: []))
                    dayAfter += 1
                    lastIndex += 1
                    order = NSCalendar.current.compare(date as Date, to: day!, toGranularity: .day)
                }
                dailyData[lastIndex].logs += [newLog]
                
            }
        }
        newItemAdded = true
        collectionView.reloadData()
        
        // Save Into CoreData
        let colorData: NSData = NSKeyedArchiver.archivedData(withRootObject: color) as NSData
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: "WorkLogInfo", into: context) as NSManagedObject
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
        
        dailyLogObjects += [managedObject]
    }
    // MARK: ScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // scroll의 위치와 collectionCell 인덱스를 비교하여, scroll이 끝났을 때 상단 날짜 업데이트하기
        let scrollPosition = scrollView.contentOffset   // current view의 시작point

        let visibleCells = collectionView.visibleCells    //[0] as! basicCollectionViewCell
        var displayedCollectionViewCell: BasicCollectionViewCell?
        for cell in visibleCells {
            let frame = cell.frame
            if scrollPosition.x == frame.origin.x {
                displayedCollectionViewCell = cell as? BasicCollectionViewCell
                break
            }
        }
        if let displayedCollectionViewCell = displayedCollectionViewCell {
            let date = dailyData[displayedCollectionViewCell.tableViewTag!].date
            
            let dateTransform = DateFormatter.init()
            dateTransform.dateFormat = "yyyy.MM.dd"
            shownDateTextField.text = dateTransform.string(from: date as! Date)
        }
    }
}
