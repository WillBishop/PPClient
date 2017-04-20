//
//  classoverviewController.swift
//  PP
//
//  Created by Will Bishop on 16/4/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import UIKit

class classoverviewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	
	var classInfo = UserDefaults.standard.object(forKey: "cachedInfo") as? [String: [String: Any]]
	var classNote = UserDefaults.standard.object(forKey: "cachedNotes") as? [String: String?]
	var sections = ["Todays Lesson", "Todays Resources", "Upcoming Assignments"]
	var classContent = [String]()
	
	@IBOutlet weak var classOverview: UITableView!
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		let classTitle = UserDefaults.standard.object(forKey: "selectedClass") ?? ""
		print("Gone")
		print("Got \(classTitle)")
		navigationItem.title = (classTitle as? String)
		
		classContent.append(((classNote?[classTitle as! String])!)!)

		
		classOverview.estimatedRowHeight = 44 //Standard height
		classOverview.isUserInteractionEnabled = false //Stops users from selecting cell, will remove in future
		classOverview.tableFooterView = UIView() //Hides unused cells
		classOverview.rowHeight = UITableViewAutomaticDimension //Auto resizes cells based on content size
		classOverview.dataSource = self
		classOverview.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = classOverview.dequeueReusableCell(withIdentifier: "classList") as! classList
		//cell.classComment.text = classContent[indexPath.row]
		if indexPath.section == 0{
			cell.classComment.text = classContent[indexPath.row]
		} else if indexPath.section == 1{
			cell.classComment.text = "Test.pdf"
			cell.accessoryType = .disclosureIndicator
		} else if indexPath.section == 2{
			cell.classComment.text = "Test"
			cell.accessoryType = .disclosureIndicator
		}
		return cell
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sections[section]
	}
	
}

class classList: UITableViewCell{
	@IBOutlet weak var classComment: UILabel!
	
	var label = ""
	func update(){
		classComment.text = label
		
	}
}
