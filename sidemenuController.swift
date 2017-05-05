//
//  sidemenuController.swift
//  PP
//
//  Created by Will Bishop on 26/3/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import UIKit
import SideMenu
import Foundation

class sidemenuController: UITableViewController {
	
	@IBOutlet var menuList: UITableView!
	
	var headers = ["I'll rename this", "About", "Classes"]
	var sections = [
		"I'll rename this": [
			"Diary", "Homework", "All Classes", "Grades", "Messages", "Announcements"],
		"About": [
			"Settings"],
		"Classes": UserDefaults.standard.object(forKey: "cachedClasses") as? [String] ?? [String]()
	]
	var selectedCell = String()
    override func viewDidLoad() {
        super.viewDidLoad()
    }

	
	
	
	override func viewWillAppear(_ animated: Bool) {
		
		let accountType = getaccountType()
		print(sections)
		
		if accountType[0] as! String == "Teacher"{
			headers.append("Admin")
			sections["Admin"] = ["Post"]
			sections["Classes"] = sections["Daymap"]?.filter{$0 != "Homework"}
		} else if accountType[0] as! String == "Student"{
			
		} else if accountType[0] as! String == "Parent"{
			sections["Classes"]?.append("Students")
		}
		
		if accountType[1] as! Int > 1 && (accountType[1] as! Int != 2){
			print(accountType[1] as! Int > 1)
			print(accountType[1] as! Int != 2)
			
			headers.append("Admin")
			sections["Admin"] = ["Post"]
		}
		self.navigationItem.title = "Menu"
		self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Style.sectionHeaderTitleColor]
		tableView.tableFooterView = UIView()
		navigationController?.navigationBar.barTintColor = Style.sectionHeaderBackgroundColor
		print("Presented sidemenu")
		tableView.backgroundColor = Style.tableheaderColor
	}
	
	func getaccountType() -> [Any]{
		//get account type code
		return ["Student", 1]
	}
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.backgroundColor = Style.tablecellColor
		
		let selectedHeader = indexPath[0]
		let selectedRow = indexPath[1]
		let nameofCell = sections[headers[selectedHeader]]![selectedRow]
		print("setting")
		let cellrowText = sections[headers[selectedHeader]]![selectedRow].replacingOccurrences(of: "10 ", with: "")
		print(cellrowText)
		
		let cellText = NSAttributedString(string: cellrowText, attributes: [NSForegroundColorAttributeName: Style.sectionHeaderTitleColor])
			
		print("Here1")
		cell.textLabel?.attributedText = cellText

		
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = menuList.dequeueReusableCell(withIdentifier: "menuItem")!
		if indexPath.section == 0{
			cell.textLabel?.text = sections[headers[indexPath.section]]?[indexPath.row]
		} else if indexPath.section == 1{
			cell.textLabel?.text = sections[headers[indexPath.section]]?[indexPath.row]
		
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
		returnedView.backgroundColor = Style.tableheaderColor
		
		let label = UILabel(frame: CGRect(x: 10, y: 2, width: view.frame.size.width, height: 25))
		label.text = self.tableView(tableView, titleForHeaderInSection: section)
		label.textColor = Style.sectionHeaderTitleColor
		returnedView.addSubview(label)
		
		return returnedView
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (sections[headers[section]]?.count)!

	}
	override func numberOfSections(in tableView: UITableView) -> Int {
		return headers.count
	}
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return headers[section]
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destviewController: wrapperviewController = segue.destination as! wrapperviewController
		var selectCell = tableView.indexPathForSelectedRow!
		
		let selectedHeader = selectCell[0]
		let selectedRow = selectCell[1]
		
		selectedCell = sections[headers[selectedHeader]]![selectedRow]
		
		//selectedCell = sections[headers[selectedSection]]![selectedRow]
		destviewController.selectedView = selectedCell
	}

	
}
