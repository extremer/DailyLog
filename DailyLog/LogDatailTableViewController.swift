//
//  LogDatailTableViewController.swift
//  DailyLog
//
//  Created by KangKyungwon on 2016. 8. 19..
//  Copyright © 2016년 KangKyungwon. All rights reserved.
//

import UIKit

class LogDatailTableViewController: UITableViewController, UITextViewDelegate {

    @IBOutlet weak var eventNameTextView: UITextView!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var colorButton: UIButton!
    
    var logData: DailyLog?
    var duringTemp: String?
    
    var startPickerHidden = true
    var endPickerHidden = true
    
    var viewDidLayoutSubviewsComplete = false
    
    let dateFormatter = NSDateFormatter()
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        eventNameTextView.delegate = self
        colorButton.backgroundColor = logData?.color
    }
    

    override func viewDidLayoutSubviews() {
        if viewDidLayoutSubviewsComplete == false {
            // startTime, endTime이 nil이 아니면 datePicker에 setting
            if let log = logData {
                eventNameTextView.text = log.work
                startTimeTextField.text = log.startTime!
                endTimeTextField.text = log.endTime!
                
                dateFormatter.dateFormat = "h:mm:ss a"
                let startDate = dateFormatter.dateFromString(log.startTime!)
                let endDate = dateFormatter.dateFromString(log.endTime!)
                if let startDate = startDate {
                    startDatePicker.date = startDate
                }
                if let endDate = endDate {
                    endDatePicker.date = endDate
                }
                let diff = endDatePicker.date.timeIntervalSinceDate(startDatePicker.date)
                duringTemp = timeIntervalToString(diff)
            }
            viewDidLayoutSubviewsComplete = true
        }
    }
    
    // MARK: function
    func toggleStartPicker() {
        startPickerHidden = !startPickerHidden
        
        // Force table to update its contents
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    func toggleEndPicker() {
        endPickerHidden = !endPickerHidden
        
        // Force table to update its contents
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func timeIntervalToString(time: NSTimeInterval) -> String? {
        let dateComponentsFormatter = NSDateComponentsFormatter()
        dateComponentsFormatter.zeroFormattingBehavior = .Pad
        dateComponentsFormatter.allowedUnits = [NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second]
        return dateComponentsFormatter.stringFromTimeInterval(time)
    }
    
    func limitDatePicker() {
        
        startDatePicker.maximumDate = endDatePicker.date;
        endDatePicker.minimumDate = startDatePicker.date;
        //    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        //    NSDate *currentDate = [NSDate date];
        //    NSDateComponents *comps = [[NSDateComponents alloc] init];
        //    [comps setYear:30];
        //    NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
        //    [comps setYear:-30];
        //    NSDate *minDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
        //
        //    [datePicker setMaximumDate:maxDate];
        //    [datePicker setMinimumDate:minDate];
    }
    
    // MARK: Action
    @IBAction func startPickerChanged(sender: AnyObject) {
        // startTime을 바꿔줌 text, data
        dateFormatter.dateFormat = "h:mm:ss a"
        startTimeTextField.text = dateFormatter.stringFromDate(startDatePicker.date)
        
        let diff = endDatePicker.date.timeIntervalSinceDate(startDatePicker.date)
        duringTemp = timeIntervalToString(diff)
        limitDatePicker();
    }
    
    @IBAction func endPickerChanged(sender: AnyObject) {
        dateFormatter.dateFormat = "h:mm:ss a"
        endTimeTextField.text = dateFormatter.stringFromDate(endDatePicker.date)
        
        let diff = endDatePicker.date.timeIntervalSinceDate(startDatePicker.date)
        duringTemp = timeIntervalToString(diff)
        limitDatePicker();
    }
    
    
    // MARK: tableView
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            toggleStartPicker()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        case (1, 2):
            toggleEndPicker()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        default:
            ()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if startPickerHidden && indexPath.section == 1 && indexPath.row == 1 {
            return 0
        } else if endPickerHidden && indexPath.section == 1 && indexPath.row == 3 {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
  
    // MARK: UITextViewDelegate
    func textViewDidChange(textView: UITextView) {
        saveButton.enabled = !(eventNameTextView.text.isEmpty)
        
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SelectColor" {
            let targetVC = segue.destinationViewController as! ColorSelectionTableViewController
            
            targetVC.selectedRow = 0    //buttonColorIndex
        } else if segue.identifier == "SaveLog" {
            logData?.color = colorButton.backgroundColor
            logData?.startTime = startTimeTextField.text
            logData?.endTime = endTimeTextField.text
            logData?.work = eventNameTextView.text
            logData?.during = duringTemp
        }
    }
    
    @IBAction func unwindToNewLog(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? ColorSelectionTableViewController {
            if let selectedColor = sourceViewController.selectedColor {
                let buttonColor = selectedColor.color
                //buttonColorIndex = sourceViewController.selectedRow
                colorButton.backgroundColor = buttonColor
            }
        }
    }
}
