//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift

class diaryController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	
	@IBOutlet var diaryTable: UITableView!
	
	var classList = UserDefaults.standard.object(forKey: "cachedClasses") as? [String] ?? [String]()
	var classNote = UserDefaults.standard.object(forKey: "cachedNotes") as? [String: String?] ?? [String: String!]()
	var classInfo = UserDefaults.standard.object(forKey: "cachedInfo") as? [String: [String: Any]] ?? [String: [String: Any]]()
	
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		
		let date = NSDate()
		_ = DateFormatter.Style.long
		
		let calender = NSCalendar.current
		let month = calender.component(.month, from: date as Date)
		let day = calender.component(.day, from: date as Date)
		var sounds = ["1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "10th", "11th", "12th", "14th", "15th", "16th", "17th", "18th", "19th", "20th", "21st", "22nd", "23rd", "24th", "25th", "26th", "27th", "28th", "29th", "30th", "30st"]
		var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
		self.navigationController?.navigationBar.topItem?.title = "Diary - \(sounds[day - 1]) of \(months[month - 1])"
		
		diaryTable.delegate = self
		diaryTable.dataSource = self
		getDiary()
		// Do any additional setup after loading the view.
	}
	
	func getDiary(){
		let keychain = KeychainSwift()
		let username = keychain.get("username")!
		let password = keychain.get("password")!
		
		Alamofire.request("https://da.gihs.sa.edu.au/stirling/classes/daily/get?username=\(username)&password=\(password)", method: .get)
			.responseJSON { response in
				if response.result.value != nil{
					self.classList.removeAll()
					self.classNote.removeAll()
					let json = JSON(response.result.value!)
					
					for i in json["daymapDiaryClasses"]{
						let name = String(describing: i.1["className"])
						
						self.classList.append(String(describing: i.1["className"]))
						
						if i.1["classNotes"].exists(){
							self.classNote[name] = String(describing: i.1["classNotes"])
						} else {
							self.classNote[name] = "No lesson plans have been entered for this lesson"
						}
						var attendance = "✓"
						if String(describing: i.1["classAttendance"]) == "PRESENT"{
							let attendance = "✓"
						} else {
							let attendance = "✘"
						}
						self.classInfo[name] = ["time": "\(String(describing: i.1["startTime"])) until \(String(describing: i.1["endTime"]))", "room": String(describing: i.1["roomName"]), "teacher":   String(describing: (i.1["teacherName"])), "presence": attendance]
					}
					
					UserDefaults.standard.set(self.classList, forKey: "cachedClasses")
					UserDefaults.standard.set(self.classNote, forKey: "cachedNotes")
					UserDefaults.standard.set(self.classInfo, forKey: "cachedInfo")
					
					
					print(self.classInfo)
					
				} else {
					//TODO Better error managment, this is just here to prevent an app crash, while still retaining some useful information for debugging
					print(response)
					print("Error moving on")
				}
				self.diaryTable.reloadData()
		}
		
		
		
		
		
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = diaryTable.dequeueReusableCell(withIdentifier: "class", for: indexPath) as! diaryList
		let className = classList[indexPath.row]
		
		cell.name = className
		cell.accessoryType = .disclosureIndicator
		cell.accessoryView?.frame.origin.y = 0
		
		//Display Settings
		cell.className.font = UIFont.boldSystemFont(ofSize: 17.0)
		
		cell.classNote.lineBreakMode = .byWordWrapping
		cell.classNote.numberOfLines = 2
		cell.classNote.frame.size.width = 350.0
		cell.classNote.sizeToFit()
		//
		
		
		if classNote[classList[indexPath.row]] != nil{
			cell.note = (classNote[className])!!


		}
		if classInfo.count > 0{
			cell.teacher = classInfo[className]?["teacher"] as! String
			cell.time = classInfo[className]?["time"] as! String
			cell.presence = "Presence: \(classInfo[className]?["presence"] as! String)"
		}
		
		cell.update()
		
		return cell
		
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return classList.count
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedClass = classList[indexPath.row]
		let selectedclassNote = classNote[selectedClass]
		UserDefaults.standard.set(selectedClass, forKey: "selectedClass")
		UserDefaults.standard.set(selectedclassNote!, forKey: "selectedclassNote")
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let mainController = storyboard.instantiateViewController(withIdentifier: "displayNote") as UIViewController
		//
		
		navigationController?.pushViewController(mainController, animated: true)
		
		
	}
	
	
	
}
class diaryList : UITableViewCell{
	var name = ""
	var note = ""
	var teacher = ""
	var time = ""
	var presence = ""
	
	@IBOutlet weak var className: UILabel!
	@IBOutlet weak var classNote: UILabel!
	@IBOutlet weak var classPresence: UILabel!
	@IBOutlet weak var classTime: UILabel!
	@IBOutlet weak var classInfo: UILabel!
	
	
	
	//TODO: Add other class info, such as teachers, presence, time etc
	func update() {
		classNote.isHidden = true
		className.text = name
		classNote.text = note
		classPresence.text = presence
		classTime.text = time
		classInfo.text = teacher
	}
}
