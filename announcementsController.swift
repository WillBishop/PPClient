//
//  announcementsController.swift
//  PP
//
//  Created by Will Bishop on 19/3/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SideMenu
class announcementsController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var announcementsTable: UITableView!

	var announcements = UserDefaults.standard.object(forKey: "cachedAnnouncements") as? [String: [String: Any]] ?? [String: [String: Any]]()
	
	var announcementList = UserDefaults.standard.object(forKey: "cachedannouncementsList") as? [String] ?? [String]()
	
	override func viewWillAppear(_ animated: Bool) {
		SideMenuManager.menuFadeStatusBar = false
		SideMenuManager.menuWidth = UIScreen.main.bounds.width / 2
		announcementsTable.backgroundColor = Style.sectionHeaderBackgroundColor

		let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(revealMenu))
		rightSwipe.direction = .right
		view.addGestureRecognizer(rightSwipe)

		var themeName = Style.loadTheme()
		
		announcementsTable.reloadData()
	
		
	}
	func revealMenu(){
		let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sidemenuController")
		
		
		present(vc, animated: true, completion: nil)
		
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		getAnnouncements()
		announcementsTable.dataSource = self
		announcementsTable.delegate = self
        // Do any additional setup after loading the view.
    }
	
	func getAnnouncements(){
		print("Starting")
		Alamofire.request("https://da.gihs.sa.edu.au/stirling/announcements/get", method: .get)
			.responseJSON { response in
				let statusCode = response.response!.statusCode
				if case 200 ... 299 = statusCode{
				let json = JSON(response.result.value!)
					print("done")
					for i in json{
						let sender = String(describing: i.1["sender"])
						let time = String(describing: i.1["sendTime"])
						let title = String(describing: i.1["title"])
						let content = String(describing: i.1["content"])
						let important = String(describing: i.1["important"])
						self.announcementList.append(title)
						self.announcements[title] = ["sender": sender, "time": time, "title": title, "content": content, "important": important]
						
					}
					UserDefaults.standard.set(self.announcements, forKey: "cachedAnnouncements")
					UserDefaults.standard.set(self.announcementList, forKey: "cachedannouncementsList")
					
				} else {
					print("Error, moving on")
				}
				self.announcementsTable.reloadData()
					
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return announcements.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = announcementsTable.dequeueReusableCell(withIdentifier: "announcement", for: indexPath) as! announcementCell
		//print(announcements)
		cell.announcementTitle.textColor = Style.sectionHeaderTitleColor
		cell.backgroundColor = Style.sectionHeaderBackgroundColor
		
		if announcementList.count > 0{
			let title = announcementList[indexPath.row]
			print("Assigning \(title)")
			cell.title = (announcements[title]?["title"] as? String)!
			if announcements[title]?["important"] as? String == "true" {
				cell.importance = true
			} else {
				cell.importance = false
			}
		}
		
		cell.update()

		return cell
	}

	

}


class announcementCell: UITableViewCell{
	var title = ""
	var importance = false
	@IBOutlet weak var announcementTitle: UILabel!
	@IBOutlet weak var announcementImportance: UILabel!
	
	func update() {
		announcementTitle.text = title
		announcementImportance.isHidden = !importance
	}


}
