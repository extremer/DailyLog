//
//  ColorSelectionTableViewController.swift
//  DailyLog
//
//  Created by KangKyungwon on 2016. 7. 11..
//  Copyright © 2016년 KangKyungwon. All rights reserved.
//

import UIKit

class ColorSelectionTableViewController: UITableViewController {
    // MARK: Properties
    
    var colors = [Color]()
    var selectedColor: Color?
    var selectedRow: Int!
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        //dismissViewControllerAnimated(true, completion: nil)
        let isPresentingInAddNewLog = presentingViewController is AddNewLogViewController
        if isPresentingInAddNewLog{
            dismiss(animated: true, completion: nil)
        }
        else{
            // 네비게이션 스택에서 가장 위 meal scene의 view Controller를 pop
            navigationController!.popViewController(animated: true)
        }
    }

    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        let color0 = Color.init(color: UIColor.darkGray, colorName: "기본색상")
        let color1 = RGBToUIColor(red: 213, green: 28, blue: 59, name: "빨간색")
        let color2 = RGBToUIColor(red: 213, green: 97, blue: 29, name: "주황색")
        let color3 = RGBToUIColor(red: 28, green: 43, blue: 213, name: "파랑색")
        let color4 = RGBToUIColor(red: 28, green: 213, blue: 101, name: "초록색")
        let color5 = RGBToUIColor(red: 133, green: 29, blue: 213, name: "보라색")
        let color6 = RGBToUIColor(red: 213, green: 170, blue: 28, name: "노랑색")
        
        let color7 = RGBToUIColor(red: 213, green:104, blue: 122, name: "옅은 빨간색")
        let color8 = RGBToUIColor(red: 213, green: 145, blue: 105, name: "옅은 주황색")
        let color9 = RGBToUIColor(red: 105, green: 113, blue: 213, name: "옅은 파랑색")
        let color10 = RGBToUIColor(red: 105, green: 213, blue: 147, name: "옅은 초록색")
        let color11 = RGBToUIColor(red: 166, green: 105, blue: 213, name: "옅은 보라색")
        let color12 = RGBToUIColor(red: 213, green: 188, blue: 105, name: "옅은 노랑색")
        colors += [color0, color1, color2, color3, color4, color5, color6, color7, color8, color9, color10, color11, color12]
    }
    
    // MARK: Function
    func RGBToUIColor(red: Float, green: Float, blue: Float, name: String) -> Color {
        let uic = UIColor.init(colorLiteralRed: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1)
        let c = Color.init(color: uic, colorName: name)
        return c
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 13
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ColorSelectionCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ColorSelectionTableViewCell
        let color = colors[indexPath.row]
        
        cell.colorLabel.backgroundColor = color.color
        cell.colorNameLabel.text = color.colorName
        
        
        if selectedRow == indexPath.row {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        selectedColor = colors[indexPath.row]
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "selectNewColor", sender: tableView)
    }
}
