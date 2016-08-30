//
//  BasicCollectionViewCell.swift
//  DailyLog
//
//  Created by KangKyungwon on 2016. 7. 18..
//  Copyright © 2016년 KangKyungwon. All rights reserved.
//

import UIKit

class BasicCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dailyTableView: UITableView!
    
    func setTableViewDataSourceDelegate <D: protocol<UITableViewDelegate, UITableViewDataSource>>
        (dataSourceDelegate: D, forIndex index: Int) {
        dailyTableView.delegate = dataSourceDelegate
        dailyTableView.dataSource = dataSourceDelegate
        dailyTableView.tag = index    //??
        dailyTableView.reloadData()
    }
}
