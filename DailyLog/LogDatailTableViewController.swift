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
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var logData: DailyLog?
    
    var startPickerHidden = true
    var endPickerHidden = true
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        if let log = logData {
            eventNameTextView.text = log.work
            startTimeTextField.text = log.startTime!
            endTimeTextField.text = log.endTime!
        }
        eventNameTextView.delegate = self
        
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
        logData?.work = eventNameTextView.text
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}
