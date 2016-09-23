//
//  AddNewLogViewController.swift
//  DailyLog
//
//  Created by KangKyungwon on 2016. 6. 30..
//  Copyright © 2016년 KangKyungwon. All rights reserved.
//

import UIKit

protocol LogInfoDelegate {
    func writeLogInfo(date: NSDate, workName:String, startTime:String, endTime:String, during:String, color: UIColor)
}

class AddNewLogViewController: UIViewController, UITextFieldDelegate, UITabBarDelegate, UITabBarControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var stopWatchButton: UIButton!
    //@IBOutlet weak var workText: UITextField!
    //@IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var workInfoTableView: UITableView!
    
    var delegate: LogInfoDelegate?
    var tabbarC: UITabBarController?
    
    var stopWatch = StopWatch()
    var stopWatchButtonPushed: Bool = false
    var timer: Timer?
    var dateFormatter = DateFormatter()
    var strStartTime: String?
    var startDate: NSDate?
    
    var buttonColor: UIColor!
    var workName: String?
    var buttonColorIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonColor = UIColor.darkGray
        buttonColorIndex = 0
        dateFormatter.dateFormat = "h:mm:ss a"
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let setting = UserDefaults.standard
        let startedTime = setting.value(forKey: "startTime")
        let text = setting.value(forKey: "text")
        let colorData = setting.value(forKey: "color")
        
        if let startTime = startedTime {
            if let text = text {
                let infoCell = workInfoTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LogInfoCell
                infoCell.workText.text = text as? String
                
                if let colorData = colorData {
                    let color = NSKeyedUnarchiver.unarchiveObject(with: (colorData as! NSData) as Data)
                    infoCell.colorButton.backgroundColor = color as? UIColor
                }
                // stopwatch 진행
                stopWatch.start()
                stopWatch.startTime = startTime as? NSDate
                strStartTime = dateFormatter.string(from: (stopWatch.startTime ?? NSDate()) as Date)
                startDate = stopWatch.startTime
                stopWatchButton.setTitle("중단", for: .normal)
                stopWatchButtonPushed = !stopWatchButtonPushed
            }
        }
    }
    

    // MARK: Action
    @IBAction func pushSWButton(sender: AnyObject) {
        if stopWatchButtonPushed == false {
            // start SW
            let infoCell = workInfoTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LogInfoCell
            workName = infoCell.workText.text
            if workName == "" {
                // text가 비어있으면 start버튼 눌리지 않음
                
                let alert = UIAlertController(title: "일정이 없어요!", message:"지금 하려는 일을 적어주세요!", preferredStyle: .alert)
                let action = UIAlertAction(title: "넹 :)", style: .default, handler: { (action: UIAlertAction) in
                    infoCell.workText.becomeFirstResponder()
                    // Main thread로 돌리는 코드
//                    dispatch_async(dispatch_get_main_queue(), {
//                        self.workText.becomeFirstResponder()
//                    })
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                stopWatch.start()
                // workName 저장(혹시 중간에 앱이 종료될 때를 대비하여)
                let setting = UserDefaults.standard
                setting.set(workName, forKey: "text")
                setting.synchronize()
                
                strStartTime = dateFormatter.string(from: (stopWatch.startTime ?? NSDate()) as Date)
                startDate = stopWatch.startTime
                stopWatchButton.setTitle("중단", for: .normal)
                stopWatchButtonPushed = !stopWatchButtonPushed
            }
        }
        else {
            // stop SW
            self.stopWatch.stop()
            stopWatchButton.setTitle("시작", for: .normal)
            stopWatchButtonPushed = !stopWatchButtonPushed
            
            passTimeData()
            
            self.dismiss(animated: true, completion: nil)
            tabbarC?.selectedIndex = 0
        }
    }
    
    @IBAction func stopAddNewWork(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //workText.resignFirstResponder()
        let infoCell = workInfoTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LogInfoCell
        infoCell.workText.resignFirstResponder()
        return true
    }
    
    // MARK: Function
    func updateTimer() {
        timerLabel.text = stopWatch.elapsedTimeString
    }
    
    struct StopWatch {
        public var startTime: NSDate?
        public var endTime: NSDate?
        private var accumulatedTime: TimeInterval = 0.0
        
        var elapsedTimeInterval: TimeInterval {
            get {
                return accumulatedTime + NSDate().timeIntervalSince((startTime ?? NSDate()) as Date)
            }
        }
        var elapsedTimeString: String {
            get {
                return timeIntervalToString(time: elapsedTimeInterval) ?? "0:00.00"
            }
        }
        func timeIntervalToString(time: TimeInterval) -> String? {
            let dateComponentsFormatter = DateComponentsFormatter()
            dateComponentsFormatter.zeroFormattingBehavior = .pad
            dateComponentsFormatter.allowedUnits = [NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second]
            return dateComponentsFormatter.string(from: time)
        }
        mutating func start() {
            //startTime = nil
            accumulatedTime = 0.0
            startTime = NSDate()
            //self.update
            
            //앱이 도중에 꺼질 일을 대비하여 startTime 저장
            let setting = UserDefaults.standard
            setting.set(startTime, forKey: "startTime")
            setting.synchronize()
        }
        mutating func stop() {
            accumulatedTime += NSDate().timeIntervalSince((startTime ?? NSDate()) as Date)
            endTime = startTime?.addingTimeInterval(accumulatedTime)
            startTime = nil
            
            // startTime -> nil로 저장
            let setting = UserDefaults.standard
            setting.set(startTime, forKey: "startTime")
            setting.set(nil, forKey: "text")
            setting.set(nil, forKey: "color")
            setting.synchronize()
        }
    }
    
    func passTimeData() {
        let infoCell = workInfoTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LogInfoCell
        let text = infoCell.workText.text // workText.text
        let endTime = dateFormatter.string(from: stopWatch.endTime! as Date)
        let during = stopWatch.elapsedTimeString

        delegate?.writeLogInfo(date: startDate!, workName: text!, startTime: strStartTime!, endTime: endTime, during: during, color: buttonColor)
        
        infoCell.workText.text = nil
        infoCell.resignFirstResponder()
    }
    
    // MARK: TableViewController
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cellIdentifier = "LogInfoCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? LogInfoCell
            if let cell = cell {
                cell.colorButton.backgroundColor = buttonColor
            }
            return cell!
        }
        else if indexPath.row == 1 {
            let cellIdentifier = "selectColor"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            return cell!
        }
        else {
            let cellIdentifier = "selectWork"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            return cell!
        }
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navC = segue.destination as! UINavigationController
        let targetVC = navC.topViewController as! ColorSelectionTableViewController
        targetVC.selectedRow = buttonColorIndex
    }
    
    @IBAction func unwindToNewLog(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ColorSelectionTableViewController {
            if let selectedColor = sourceViewController.selectedColor {
                buttonColor = selectedColor.color
                buttonColorIndex = sourceViewController.selectedRow
                let infoCell = workInfoTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LogInfoCell
                infoCell.colorButton.backgroundColor = buttonColor
                let setting = UserDefaults.standard
                let colorData = NSKeyedArchiver.archivedData(withRootObject: buttonColor)
                setting.set(colorData, forKey: "color")
                setting.synchronize()
            }
        }
    }
}

