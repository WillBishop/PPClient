//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift
import SideMenu
import UserNotifications


class diaryController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	
	@IBOutlet var diaryTable: UITableView!
	
	
	
	var classList = UserDefaults.standard.object(forKey: "cachedClasses") as? [String] ?? [String]() //Grab all the cached data
	var classNote = UserDefaults.standard.object(forKey: "cachedNotes") as? [String: String?] ?? [String: String!]()
	var classInfo = UserDefaults.standard.object(forKey: "cachedInfo") as? [String: [String: Any]] ?? [String: [String: Any]]()
	
	let displayNote = UITextView(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.width - 10, height:300)) //text view to be footer to table
	override func viewWillAppear(_ animated: Bool) {




		print("Starting")
		_ = Style.loadTheme() //loadTheme() returns a string, but I do not use it at this moment
		diaryTable.backgroundColor = Style.sectionHeaderBackgroundColor
		
		//self.navigationItem.setHidesBackButton(true, animated:true)
		
		displayNote.backgroundColor = Style.sectionHeaderBackgroundColor
		displayNote.textColor = Style.sectionHeaderTitleColor

		let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(revealMenu)) //Gesture to bring out side menu (swipe from left to right)
		rightSwipe.direction = .right
		view.addGestureRecognizer(rightSwipe)
		
		
	}
	
	
	func revealMenu(){
		let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sidemenuController")
		
	
		present(vc, animated: true, completion: nil)
		
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		displayNote.text = "Click a class to reveal more information"
		displayNote.font = UIFont.systemFont(ofSize: 14.0)
		displayNote.isEditable = false //Theoretically allows the user to highlight and copy, but not actually edit the text (client-side)
		
		let customView = UIView(frame: CGRect(x:10, y:10, width:100, height:200))

		customView.addSubview(displayNote)
		
		diaryTable.tableFooterView = customView //Not only hides unused cells, but lets the note view scale with the amount of classes
		
		
		
	
		
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
	override func viewDidAppear(_ animated: Bool) {
		registerLocal() //Register to allow local notifications
		
	}
	
	func dateGenerator(_ hour:Int, _ minute:Int) -> DateComponents{
		let calendar = Calendar.autoupdatingCurrent
		let components = calendar.dateComponents([.year, .day, .month], from: Date())
		var date = DateComponents()
		
		date.year = components.year
		date.month = components.month
		date.day = components.day
		date.hour = hour
		date.minute = minute
		
		return date
		
	}
	func registerLocal() { //In the future, each class will have a time associated with it, and then can have a weekly schedule from that
		let options: UNAuthorizationOptions = [.alert, .sound] //Badges is not yet required
		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options: options) {
			(granted, error) in
			if !granted {
				print("Something went wrong")
			}
		}
		center.getNotificationSettings { (set) in
			if set.authorizationStatus != .authorized{
				print("User disabled notifications")
				//TODO: Request permission again
			} else {
				print("Notifications Enabled")
			}
		}
		
	}
	
	func scheduleNotification(_ className:String, _ classTeacher:String, _ classRoom:String,_ classTime:DateComponents){
		let center = UNUserNotificationCenter.current()
		let notification = UNMutableNotificationContent()
		notification.title = className
		notification.body = "with \(classTeacher)" //teacher encompasses the room as well
		notification.sound = UNNotificationSound.default()
		
		let trigger = UNCalendarNotificationTrigger(dateMatching: classTime, repeats: false)
		//print("Scheduling for \(classTime)")
		
		let identifier = className
		
		let request = UNNotificationRequest(identifier: identifier, content: notification, trigger: trigger)
		center.add(request)

	}
	
	func getDiary(){
		
		let keychain = KeychainSwift()
		let username = keychain.get("username")!
		//username = username.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
		//print(username)
		let password = keychain.get("password")!
		//var password = "@abc#".encodeUrl()
		//print(password)
		//print("Starting")
		Alamofire.request("https://da.gihs.sa.edu.au/stirling/classes/daily/get?username=\(username)&password=\(password)", method: .get)
			.responseJSON { response in
				print(response.response?.statusCode ?? "Got nothing")
				print("Done")
				if response.result.value != nil{
					self.classList.removeAll() //Remove all existing data to prevent overlapping data
					self.classNote.removeAll()
					self.classInfo.removeAll()
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
							attendance = "✓"
						} else {
							attendance = "✘"
						}
						let numericalStart = String(describing: i.1["startTime"]).replacingOccurrences(of: " AM", with: "").replacingOccurrences(of: " PM", with: "")
						
						var numericalstartTime = numericalStart.components(separatedBy: ":")
						
						if (String(describing: i.1["startTime"]).range(of: "PM") != nil){
							if Int(numericalstartTime[0])! != 12{
								numericalstartTime[0] = String(Int(numericalstartTime[0])! + 12)
							}
							
						}
						

						
						
						
						self.classInfo[name] = ["time": "\(String(describing: i.1["startTime"]))-\(String(describing: i.1["endTime"]))", "room": String(describing: i.1["roomName"]), "teacher":   String(describing: (i.1["teacherName"])), "presence": attendance, "numericalstartHour": numericalstartTime[0], "numericalstartMinute": numericalstartTime[1]]
						
						let classRoom = self.classInfo[name]?["room"] as! String
						let classHour = self.classInfo[name]?["numericalstartHour"] as! String
						let classMinute = self.classInfo[name]?["numericalstartMinute"] as! String
						let teacher = "\(self.classInfo[name]?["teacher"] as! String) in \(String(classRoom.characters.prefix(5)))"
						
						let classstartTime = self.dateGenerator(Int(classHour)!, Int(classMinute)!)
						self.scheduleNotification(name, teacher, classRoom, classstartTime)
						//print(self.classInfo)
					}
					
					UserDefaults.standard.set(self.classList, forKey: "cachedClasses")
					UserDefaults.standard.set(self.classNote, forKey: "cachedNotes")
					UserDefaults.standard.set(self.classInfo, forKey: "cachedInfo")
					
					
					//print(self.classInfo)
					
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
		cell.backgroundColor = Style.sectionHeaderBackgroundColor
		let className = classList[indexPath.row]
		
		cell.name = className
		
		//Display Settings
		cell.className.font = UIFont.boldSystemFont(ofSize: 17.0) //All Style.* in the file ensures everything conforms to the selected theme
		cell.className.textColor = Style.sectionHeaderTitleColor
		
		cell.classNote.lineBreakMode = .byWordWrapping
		cell.classNote.numberOfLines = 2
		cell.classNote.frame.size.width = 350.0
		cell.classNote.sizeToFit()
		//
		
		
		if classNote[classList[indexPath.row]] != nil{
			cell.note = (classNote[className])!!


		}
		if classInfo.count > 0{
			//print("Scheduling")
			
			let classRoom = classInfo[className]?["room"] as! String
			let teacher = "\(classInfo[className]?["teacher"] as! String) in \(String(classRoom.characters.prefix(5)))"
			cell.teacher = teacher
			cell.time = classInfo[className]?["time"] as! String
			cell.presence = "Presence: \(classInfo[className]?["presence"] as! String)"
			
			
			//print(Int(classHour)!)
			//print(Int(classMinute)!)
			
			
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
		let cell: UITableViewCell = diaryTable.cellForRow(at: indexPath)!
		cell.contentView.backgroundColor = Style.sectionHeaderBackgroundColorHighlighted //Allow custom selected colours
		UIView.animate(withDuration: 0.3, animations: {self.displayNote.text = selectedclassNote!})
		
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
	
	
	
	func update() {
		classNote.isHidden = true
		className.text = name
		classNote.text = note
		classPresence.text = presence
		classTime.text = time
		classInfo.text = teacher
	}
}
