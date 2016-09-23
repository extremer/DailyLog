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
    
    var dateFormatter = DateFormatter()
    
    @IBAction func cancel(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventNameTextView.delegate = self
        eventNameTextView.isScrollEnabled = false
        colorButton.backgroundColor = logData?.color
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if viewDidLayoutSubviewsComplete == false {
            // startTime, endTime이 nil이 아니면 datePicker에 setting
            if let log = logData {
                eventNameTextView.text = log.work
                startTimeTextField.text = log.startTime!
                endTimeTextField.text = log.endTime!
                eventNameTextView.frame = calculateTextViewHeight(textView: eventNameTextView)
                
                dateFormatter.dateFormat = "h:mm:ss a"
                let startDate = dateFormatter.date(from: log.startTime!)
                let endDate = dateFormatter.date(from: log.endTime!)
                if let startDate = startDate {
                    startDatePicker.date = startDate
                }
                if let endDate = endDate {
                    endDatePicker.date = endDate
                }
                let diff = endDatePicker.date.timeIntervalSince(startDatePicker.date)
                duringTemp = timeIntervalToString(time: diff)
            }
            viewDidLayoutSubviewsComplete = true
            tableView.reloadData()
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
    
    func timeIntervalToString(time: TimeInterval) -> String? {
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.zeroFormattingBehavior = .pad
        dateComponentsFormatter.allowedUnits = [NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second]
        return dateComponentsFormatter.string(from: time)
    }
    
    func limitDatePicker() {
        startDatePicker.maximumDate = endDatePicker.date;
        endDatePicker.minimumDate = startDatePicker.date;
    }
    
    func calculateTextViewHeight(textView: UITextView) -> CGRect {
        // textView의 가로길이는 고정하고 세로 길이를 구함
        // sizeThatFits: return 'best' size to fit given size. does not actually resize view. Default is return existing view size
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        return newFrame
    }
    
    // MARK: Action
    @IBAction func startPickerChanged(sender: AnyObject) {
        // startTime을 바꿔줌 text, data
        startTimeTextField.text = dateFormatter.string(from: startDatePicker.date)
        
        let diff = endDatePicker.date.timeIntervalSince(startDatePicker.date)
        duringTemp = timeIntervalToString(time: diff)
        limitDatePicker();
    }
    
    @IBAction func endPickerChanged(sender: AnyObject) {
        endTimeTextField.text = dateFormatter.string(from: endDatePicker.date)
        
        let diff = endDatePicker.date.timeIntervalSince(startDatePicker.date)
        duringTemp = timeIntervalToString(time: diff)
        limitDatePicker();
    }
    
    
    // MARK: tableView
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            toggleStartPicker()
            tableView.deselectRow(at: indexPath, animated: true)
        case (1, 2):
            toggleEndPicker()
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            ()
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            // textView height에 따라 바뀜 
             return eventNameTextView.frame.height
        } else if startPickerHidden && indexPath.section == 1 && indexPath.row == 1 {
            return 0
        } else if endPickerHidden && indexPath.section == 1 && indexPath.row == 3 {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
  
    // MARK: UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        // text없으면 저장 비활성화
        saveButton.isEnabled = !(eventNameTextView.text.isEmpty)
        let newFrame = calculateTextViewHeight(textView: textView)
        if newFrame.height != textView.frame.height {
            
            textView.frame = newFrame
  //          textView.layoutIfNeeded()
            textView.updateConstraints()
            textView.sizeToFit()
            tableView.beginUpdates()
            tableView.endUpdates()

   //     tableView.reloadData()
          //  textView.becomeFirstResponder()
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    // MARK: Segue
    //func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "SelectColor" {
            let targetVC = segue.destination as! ColorSelectionTableViewController
            
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
        if let sourceViewController = sender.source as? ColorSelectionTableViewController {
            if let selectedColor = sourceViewController.selectedColor {
                let buttonColor = selectedColor.color
                colorButton.backgroundColor = buttonColor
            }
        }
    }
}
