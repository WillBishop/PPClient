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
class announcementsController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var announcementsTable: UITableView!

	var announcements = UserDefaults.standard.object(forKey: "cachedAnnouncements") as? [String: [String: Any]] ?? [String: [String: Any]]()
	
	var announcementList = UserDefaults.standard.object(forKey: "cachedannouncementsList") as? [String] ?? [String]()
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationItem.setHidesBackButton(true, animated:true)
		var image = UIImage(named: "hamburger")?.withRenderingMode(.alwaysOriginal)
		
		let rect: CGRect = CGRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height)
		let cgImage: CGImage = image!.cgImage!.cropping(to: rect)!
		image = UIImage(cgImage: cgImage, scale: (image?.size.width)! / 22, orientation: (image?.imageOrientation)!);		let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(revealMenu))
		self.navigationItem.leftBarButtonItem = button
		
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
		let cell = announcementsTable.dequeueReusableCell(withIdentifier: "announcement", for: indexPath)
		print(announcements)
		if announcementList.count > 0{
			let title = announcementList[indexPath.row]
			cell.textLabel?.text = announcements[title]?["title"] as? String
		}


		return cell
	}

	

}
