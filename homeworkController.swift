//
//  homeworkController.swift
//  PP
//
//  Created by Will Bishop on 25/3/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import UIKit
import SideMenu

class homeworkController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	let displayHomework = UITextView(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.width - 10, height:300))
	
	var classInfo = UserDefaults.standard.object(forKey: "cachedInfo") as? [String: [String: Any]] ?? [String: [String: Any]]()
	var classList = UserDefaults.standard.object(forKey: "cachedClasses") as? [String] ?? [String]()

	@IBOutlet weak var homeworkTable: UITableView!
	
	override func viewWillAppear(_ animated: Bool) {
		var themeName = Style.loadTheme()
		SideMenuManager.menuFadeStatusBar = false
		SideMenuManager.menuWidth = UIScreen.main.bounds.width / 2
		homeworkTable.backgroundColor = Style.sectionHeaderBackgroundColor
		navigationController?.navigationBar.barTintColor = Style.secionHeaderNavigationBarColor
		
		//self.navigationItem.setHidesBackButton(true, animated:true)
		var image = UIImage(named: "hamburger")?.withRenderingMode(.alwaysOriginal)
		
		if themeName == "Light"{image = UIImage(named: "hamburger")?.withRenderingMode(.alwaysOriginal)}
		if themeName == "Dark"{image = UIImage(named: "hamburgerLight")?.withRenderingMode(.alwaysOriginal)}
		
		
		let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(revealMenu))
		
		self.navigationItem.leftBarButtonItem = button
		
		displayHomework.backgroundColor = Style.sectionHeaderBackgroundColor
		displayHomework.textColor = Style.sectionHeaderTitleColor
		
		let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(revealMenu))
		rightSwipe.direction = .right
		view.addGestureRecognizer(rightSwipe)

	}
	
	func revealMenu(){
		let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sidemenuController")
		
		
		present(vc, animated: true, completion: nil)
		
	}
    override func viewDidLoad() {
		let customView = UIView(frame: CGRect(x:10, y:10, width:100, height:200))
		
		customView.addSubview(displayHomework)
		
		homeworkTable.tableFooterView = customView
		homeworkTable.dataSource = self
		homeworkTable.delegate = self
		
		displayHomework.text = "Click a class to reveal more information"
		displayHomework.font = UIFont.systemFont(ofSize: 14.0)
		displayHomework.isEditable = false

        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = homeworkTable.dequeueReusableCell(withIdentifier: "class", for: indexPath) as! diaryList
		cell.backgroundColor = Style.sectionHeaderBackgroundColor
		let className = classList[indexPath.row]
		cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
		cell.textLabel?.textColor = Style.sectionHeaderTitleColor
		cell.textLabel?.text = className
		return cell
   

	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedClass = classList[indexPath.row]
		let homework = classInfo[selectedClass]?["homework"] as? String
		let cell: UITableViewCell = homeworkTable.cellForRow(at: indexPath)!
		cell.contentView.backgroundColor = Style.sectionHeaderBackgroundColorHighlighted
		self.displayHomework.text = "This will work at a later date"
	}
	
}
