//
//  BasicCollectionViewCell.swift
//  DailyLog
//
//  Created by KangKyungwon on 2016. 7. 18..
//  Copyright © 2016년 KangKyungwon. All rights reserved.
//

import UIKit

protocol SegueDelegate {
    func performSegueWith(ID: String, selectedTag: Int, selectedIndexPath: IndexPath)
}

class BasicCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var dailyTableView: UITableView!
    var tableViewTag: Int!
    var logs: [DailyLog]!
    var delegate: SegueDelegate?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.tag = tableViewTag
        return logs.count
        //return dailyData[tableView.tag].logs.count //??
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogListTableViewCell", for: indexPath as IndexPath) as! LogListTableViewCell
        
        let DailyLog = logs[indexPath.row]
        if let work = DailyLog.work {
            cell.workLabel.text = work
            if let color = DailyLog.color {
                cell.colorLabel.backgroundColor = UIColor.clear//color
                cell.colorLabel.layer.backgroundColor = color.cgColor
            }
            else {
                cell.colorLabel.text = ""
            }
            if let during = DailyLog.during {
                let strTime = changeTimeFormatToShow(time: during)
                cell.timeLabel.text = strTime
            }
            else {
                cell.timeLabel.text = ""
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // segue 호출
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.performSegueWith(ID: "ShowDetail", selectedTag: tableViewTag, selectedIndexPath: indexPath)
    }
    
    func changeTimeFormatToShow(time: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let date: NSDate? = dateFormatter.date(from: time) as NSDate?
        if let date = date {
            dateFormatter.dateFormat = "H"
            let hour = dateFormatter.string(from: date as Date)
            
            dateFormatter.dateFormat = "m"
            let min = dateFormatter.string(from: date as Date)
            
            dateFormatter.dateFormat = "s"
            let sec = dateFormatter.string(from: date as Date)
            
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
}
