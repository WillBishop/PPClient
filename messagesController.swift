//
//  messagesController.swift
//  Osmond
//
//  Created by Will Bishop on 2/5/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//
// https://da.gihs.sa.edu.au/stirling/student/classes/get/messages?username=b&password=gGq17FM8

import UIKit
import SideMenu
import Alamofire
import KeychainSwift
import SwiftyJSON

class messagesController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var messagesTable: UITableView!
	
	var messages = UserDefaults.standard.object(forKey: "cachedMessages") as? [String: [String: Any]] ?? [String: [String: Any]]()
	
	var messageList = UserDefaults.standard.object(forKey: "cachedMessagesList") as? [String] ?? [String]()
	
	override func viewWillAppear(_ animated: Bool) {
		SideMenuManager.menuFadeStatusBar = false
		SideMenuManager.menuWidth = UIScreen.main.bounds.width / 2
		messagesTable.backgroundColor = Style.sectionHeaderBackgroundColor
		
		let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(revealMenu))
		rightSwipe.direction = .right
		view.addGestureRecognizer(rightSwipe)
		
		_ = Style.loadTheme()
		
		messagesTable.reloadData()
		
		
	}
	func revealMenu(){
		let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sidemenuController")
		
		
		present(vc, animated: true, completion: nil)
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		getmessages()
		messagesTable.dataSource = self
		messagesTable.delegate = self
		// Do any additional setup after loading the view.
	}
	
	func getmessages(){
		let keychain = KeychainSwift()
		let stirlingUsername: String! = keychain.get("stirlingUsername")?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
		let stirlingPassword: String! = keychain.get("stirlingPassword")?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
		
		print("https://da.gihs.sa.edu.au/stirling/student/classes/get/messages?username=\(stirlingUsername!)&password=\(stirlingPassword!)")
		Alamofire.request("https://da.gihs.sa.edu.au/stirling/student/classes/get/messages?username=\(stirlingUsername!)&password=\(stirlingPassword!)", method: .get)
			.responseJSON { response in
				//let statusCode = response.response?.statusCode
				if response.response?.statusCode == 200{
					self.messages.removeAll()
					self.messageList.removeAll()
					let json = JSON(response.result.value!)
					print(json)
					
					for i in json{
						let sender = i.1["sender"]
						let sendTime = i.1["sendTime"]
						let sendDate = i.1["sendDate"]
						let content = i.1["content"]
					
						self.messageList.append(String(describing: sender))
						
						self.messages[String(describing: sender)] = [
							"sender": String(describing: sender),
							"sendTime": String(describing: sendTime),
							"sendDate": String(describing: sendDate),
							"content": String(describing: content)
						]
						
						
					}
					
					UserDefaults.standard.set(self.messages, forKey: "cachedMessages")
					UserDefaults.standard.set(self.messageList, forKey: "cachedMessagesList")
					
				} else {
					print("Error, moving on")
				}
				self.messagesTable.reloadData()
				
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		print(messageList.count)
		return messageList.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = messagesTable.dequeueReusableCell(withIdentifier: "message", for: indexPath) as! messagesCell
		//print(messages)
		cell.messageSender.textColor = Style.sectionHeaderTitleColor
		cell.backgroundColor = Style.sectionHeaderBackgroundColor
		
		if messageList.count > 0{
			cell.sender = NSAttributedString(string: messageList[indexPath.row], attributes: [NSForegroundColorAttributeName: Style.classnameColor])
			
			cell.date = messages[messageList[indexPath.row]]?["sendDate"] as! String
			cell.time = messages[messageList[indexPath.row]]?["sendTime"] as! String
			cell.body = messages[messageList[indexPath.row]]?["content"] as! String

			
		}
		
		cell.update()
		
		return cell
	}
	
	
	
}


class messagesCell: UITableViewCell{
	var title = ""
	var importance = false
	var body = ""
	var time = ""
	var date = ""
	var sender = NSAttributedString()
	
	
	@IBOutlet weak var messageTime: UILabel!
	
	@IBOutlet weak var messageBody: UILabel!
	@IBOutlet weak var messageDate: UILabel!
	
	@IBOutlet weak var messageSender: UILabel!
	
	func update() {
		messageBody.text = body
		messageDate.text = date
		messageTime.text = time
		messageSender.attributedText = sender
		
	}
	
	
}
