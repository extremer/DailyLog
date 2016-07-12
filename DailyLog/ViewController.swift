//
//  ViewController.swift
//  DailyLog
//
//  Created by KangKyungwon on 2016. 6. 30..
//  Copyright © 2016년 KangKyungwon. All rights reserved.
//

import UIKit

protocol logInfoDelegate {
    func writeLogInfo(workName:String, startTime:String, endTime:String, during:String, color: UIColor)
}

class ViewController: UIViewController, UITextFieldDelegate, UITabBarDelegate, UITabBarControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties
    @IBOutlet weak var SWButton: UIButton!
    //@IBOutlet weak var workText: UITextField!
    //@IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var workInfoTableView: UITableView!
    
    var delegate: logInfoDelegate?                      ///////////////////////////////////////////
    var tabbarC: UITabBarController?
    
    var stopWatch = StopWatch()
    var SWButtonPushed: Bool = false
    var timer: NSTimer?
    var dateFormatter = NSDateFormatter()
    var strStartTime: String?
    
    var buttonColor: UIColor!
    var workName: String?
    var buttonColorIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonColor = UIColor.darkGrayColor()
        buttonColorIndex = 0
        dateFormatter.dateFormat = "HH:mm:ss"
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Action
    @IBAction func pushSWButton(sender: AnyObject) {
        if SWButtonPushed == false {
            // start SW
            let infoCell = workInfoTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! LogInfoCell
            if infoCell.workText.text == "" {
                // text가 비어있으면 start버튼 눌리지 않음
                
                let alert = UIAlertController(title: "일정이 없어요!", message:"지금 하려는 일을 적어주세요!", preferredStyle: .Alert)
                let action = UIAlertAction(title: "넹 :)", style: .Default, handler: { (action: UIAlertAction) in
                    infoCell.workText.becomeFirstResponder()
                    // Main thread로 돌리는 코드
//                    dispatch_async(dispatch_get_main_queue(), {
//                        self.workText.becomeFirstResponder()
//                    })
                })
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else {
                stopWatch.start()
                strStartTime = dateFormatter.stringFromDate(stopWatch.startTime ?? NSDate())
                SWButton.setTitle("중단", forState: .Normal)
                SWButtonPushed = !SWButtonPushed
                
                
            }
        }
        else {
            // stop SW
            self.stopWatch.stop()
            SWButton.setTitle("시작", forState: .Normal)
            SWButtonPushed = !SWButtonPushed
            
            passTimeData()
            
            self.dismissViewControllerAnimated(true, completion: nil)
            tabbarC?.selectedIndex = 0
        }
    }
    
    @IBAction func stopAddNewWork(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //workText.resignFirstResponder()
        let infoCell = workInfoTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! LogInfoCell
        infoCell.workText.resignFirstResponder()
        return true
    }
    
    // MARK: Function
    func updateTimer() {
        timerLabel.text = stopWatch.elapsedTimeString
    }
    
    struct StopWatch {
        private var startTime: NSDate?
        private var endTime: NSDate?
        private var accumulatedTime: NSTimeInterval = 0.0
        
        var elapsedTimeInterval: NSTimeInterval {
            get {
                return accumulatedTime + NSDate().timeIntervalSinceDate(startTime ?? NSDate())
            }
        }
        var elapsedTimeString: String {
            get {
                return timeIntervalToString(elapsedTimeInterval) ?? "0:00.00"
            }
        }
        func timeIntervalToString(time: NSTimeInterval) -> String? {
            let dateComponentsFormatter = NSDateComponentsFormatter()
            dateComponentsFormatter.zeroFormattingBehavior = .Pad
            dateComponentsFormatter.allowedUnits = [NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second]
            return dateComponentsFormatter.stringFromTimeInterval(time)
        }
        mutating func start() {
            //startTime = nil
            accumulatedTime = 0.0
            startTime = NSDate()
            //self.update
            
        }
        mutating func stop() {
            accumulatedTime += NSDate().timeIntervalSinceDate(startTime ?? NSDate())
            endTime = startTime?.dateByAddingTimeInterval(accumulatedTime)
            startTime = nil
        }
    }
    
    func passTimeData() {
        let infoCell = workInfoTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! LogInfoCell
        let text = infoCell.workText.text // workText.text
        let endTime = dateFormatter.stringFromDate(stopWatch.endTime!)
        let during = stopWatch.elapsedTimeString

        delegate?.writeLogInfo(text!, startTime: strStartTime!, endTime: endTime, during: during, color: buttonColor)
        
        infoCell.workText.text = nil
        infoCell.resignFirstResponder()
    }
    
    // MARK: TableViewController
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cellIdentifier = "LogInfoCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? LogInfoCell
            if let cell = cell {
                cell.colorButton.backgroundColor = buttonColor
            }
            return cell!
        }
        else if indexPath.row == 1 {
            let cellIdentifier = "selectColor"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
            return cell!
        }
        else {
            let cellIdentifier = "selectWork"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
            return cell!
        }
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navC = segue.destinationViewController as! UINavigationController
        let targetVC = navC.topViewController as! ColorSelectionTableViewController
        targetVC.selectedRow = buttonColorIndex
        //targetVC.selectedColor = buttonColor
    }
    
    @IBAction func unwindToNewLog(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? ColorSelectionTableViewController {
            if let selectedColor = sourceViewController.selectedColor {
                buttonColor = selectedColor.color
                buttonColorIndex = sourceViewController.selectedRow
                let infoCell = workInfoTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! LogInfoCell
                infoCell.colorButton.backgroundColor = buttonColor
            }
        }
    }
}

