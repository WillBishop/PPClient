//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift
import UserNotifications
import Crashlytics

class diaryController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	
	@IBOutlet var diaryTable: UITableView!
	
	
	
	var classList = UserDefaults.standard.object(forKey: "cachedClasses") as? [String] ?? [String]() //Grab all the cached data
	var classShortend = UserDefaults.standard.object(forKey: "cachedShortend") as? [String] ?? [String]()
	var classNote = UserDefaults.standard.object(forKey: "cachedNotes") as? [String: String?] ?? [String: String!]()
	var classInfo = UserDefaults.standard.object(forKey: "cachedInfo") as? [String: [String: Any]] ?? [String: [String: Any]]()
	var alreadyAlerted = UserDefaults.standard.object(forKey: "alreadyAlerted") as? Bool ?? false
	
	override func viewWillAppear(_ animated: Bool) {
		_ = Style.loadTheme() //loadTheme() returns a string, but I do not use it at this moment
		diaryTable.backgroundColor = Style.sectionHeaderBackgroundColor
		diaryTable.tableFooterView = UIView()
		let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(revealMenu)) //Gesture to bring out side menu (swipe from left to right)
		rightSwipe.direction = .right
		view.addGestureRecognizer(rightSwipe)
		navigationItem.title = "Diary"
		let widget = UserDefaults(suiteName: "group.osmond.cache")
		widget?.set(classList, forKey: "cachedClasses")
		
	
	}
	
	
	func revealMenu(){
		let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sidemenuController")
		
	
		present(vc, animated: true, completion: nil)
		
	}
	override func viewDidLoad() {
		super.viewDidLoad()
				
	
		
		diaryTable.delegate = self
		diaryTable.dataSource = self
		getDiary()
		// Do any additional setup after loading the view.
	}
	override func viewDidAppear(_ animated:			Bool) {
		if #available(iOS 10.0, *) {
			registerLocal()
		} else {
			//TODO  Notification support prior to IOS 10, need to download IOS 9 SDKS
		} //Register to allow local notifications
		
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
	@available(iOS 10.0, *)
	func registerLocal() { //In the future, each class will have a time associated with it, and then can have a weekly schedule from that
		let options: UNAuthorizationOptions = [.alert, .sound] //Badges is not yet required
		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options: options) {
			(granted, error) in
			if !granted {
				//print("Something went wrong")
			}
		}
		center.getNotificationSettings { (set) in
			if set.authorizationStatus != .authorized{
				//print("User disabled notifications")
				//TODO: Request permission again
			} else {
				//print("Notifications Enabled")
			}
		}
		
	}
	
	@available(iOS 10.0, *)
	func scheduleNotification(_ className:String, _ classTeacher:String, _ classRoom:String,_ classTime:DateComponents){
		let center = UNUserNotificationCenter.current()
		let notification = UNMutableNotificationContent()
		notification.title = className
		notification.body = "with \(classTeacher)" //teacher encompasses the room as well
		notification.sound = UNNotificationSound.default()
		
		let trigger = UNCalendarNotificationTrigger(dateMatching: classTime, repeats: false)
		////print("Scheduling for \(classTime)")
		
		let identifier = className
		
		let request = UNNotificationRequest(identifier: identifier, content: notification, trigger: trigger)
		center.add(request)

	}
	
	
	func getDiary(){
		
		let keychain = KeychainSwift()
		let username = keychain.get("stirlingUsername")!
	
		let password = keychain.get("stirlingPassword")!
		let date = NSDate()
		_ = DateFormatter.Style.long
		
		let calender = NSCalendar.current
		let month = calender.component(.month, from: date as Date)
		let day = calender.component(.day, from: date as Date)
		let year = calender.component(.year, from: date as Date)
		let todayDate = "\(day)/\(month)/\(String(describing: year))"
		//print(todayDate)

		Alamofire.request("https://da.gihs.sa.edu.au/stirling/student/classes/get/daily?username=\(username.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&password=\(password.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&date=\(todayDate)", method: .get)
			.responseJSON { response in
				print(response.response?.statusCode ?? "Got nothing")
				//print("Done")
				if response.response?.statusCode == 200{
					self.classList.removeAll() //Remove all existing data to prevent overlapping data
					self.classNote.removeAll()
					self.classInfo.removeAll()
					self.classShortend.removeAll()
					let json = JSON(response.result.value!)
					print(json)
					for i in json["daymapDailyClasses"]{
						
						let name = String(describing: i.1["className"])
						
						self.classList.append(String(describing: i.1["className"]))
						self.classShortend.append(String(describing: i.1["className"]).replacingOccurrences(of: "10 ", with: ""))
						
						self.classNote[name] = String(describing: i.1["classNotes"][0])
						//print(self.classNote[name]!!)
						if String(describing: self.classNote[name]!!) == "null"{
							self.classNote[name] = "No lesson plans have been entered for this class"
						}
						
						var attendance = "✓"
						if String(describing: i.1["attendance"]) == "PRESENT"{
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
						

						
						self.classInfo[name] = ["time": String(describing: i.1["startTime"]), "room": String(describing: i.1["roomName"]), "teacher":   String(describing: (i.1["teacher"])), "presence": attendance, "numericalstartHour": numericalstartTime[0], "numericalstartMinute": numericalstartTime[1], "homework": String(describing: (i.1["homework"]))]
						
						let classRoom = self.classInfo[name]?["room"] as! String
						let classHour = self.classInfo[name]?["numericalstartHour"] as! String
						let classMinute = self.classInfo[name]?["numericalstartMinute"] as! String
						let teacher = "\(self.classInfo[name]?["teacher"] as! String) in \(String(classRoom.characters.prefix(5)))"
						
						let classstartTime = self.dateGenerator(Int(classHour)!, Int(classMinute)!)
						if #available(iOS 10.0, *) {
							self.scheduleNotification(name, teacher, classRoom, classstartTime)
						} else {
							//Notification support for older devices (4s (maybe just 4) and below (any iPhone 3 users at GIHS?))
						}
						//print(self.classInfo)
					}
					
					UserDefaults.standard.set(self.classList, forKey: "cachedClasses")
					UserDefaults.standard.set(self.classShortend, forKey: "cachedShortend")
					print(self.classShortend)
					UserDefaults.standard.set(self.classNote, forKey: "cachedNotes")
					UserDefaults.standard.set(self.classInfo, forKey: "cachedInfo")
					
					
					//print(self.classInfo)
					
				} else {
					if self.alreadyAlerted == false{
						UserDefaults.standard.set(true, forKey: "alreadyAlerted")
						Answers.logCustomEvent(withName: "Failed to fetch data", customAttributes: ["Status Code": String(describing: response.response?.statusCode)])
						let alertController = UIAlertController(title: "Could not complete request", message: "The Stirling server is currently not responding. This could be due to invalid credentials", preferredStyle: UIAlertControllerStyle.alert)
						
						let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default) {
							UIAlertAction in
							return
						}
						
						let settingsAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.default) {
							UIAlertAction in
							print("Go to settings")
							//todo go to settings
	//						UserDefaults.standard.set("Settings", forKey: "selectedView")
	//						let storyboard = UIStoryboard(name: "Main", bundle: nil)
	//						
	//						let initialViewController = storyboard.instantiateViewController(withIdentifier: "Settings")
	//						wrapperviewController().embedView(initialViewController)
						}
						alertController.addAction(cancelAction)
						alertController.addAction(settingsAction)
						self.present(alertController, animated: true, completion: nil)
						
						print(response)
						print("Error moving on")
					}
				}
				self.diaryTable.reloadData()
		}
		
		
		
		
		
	}
	func dismissed(){
		print("Dismissed")
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = diaryTable.dequeueReusableCell(withIdentifier: "class", for: indexPath) as! diaryList
		cell.backgroundColor = Style.sectionHeaderBackgroundColor
		let className = classList[indexPath.row]
		
		let classAttributed = NSAttributedString(string: className.replacingOccurrences(of: "10 ", with: ""), attributes: [NSForegroundColorAttributeName: Style.classnameColor])
			
		cell.name = classAttributed//Year 10 is hardcoded, FIX!
		
		//Display Settings
		cell.className.font = UIFont.boldSystemFont(ofSize: 17.0) //All Style.* in the file ensures everything conforms to the selected theme
		cell.className.textColor = Style.sectionHeaderTitleColor
		
		
//		if classNote[classList[indexPath.row]] != nil{
//			cell.note = (classNote[className])!!
//
//
//		}
		let style = NSMutableParagraphStyle()
		style.lineSpacing = 0
		
		let attributes = [NSParagraphStyleAttributeName: style, NSForegroundColorAttributeName: UIColor.lightGray]
		
		let notetoUse = classNote[className]!!.replacingOccurrences(of: "\n\n\n", with: "\n")

		
		let filltext = NSAttributedString(string: notetoUse, attributes: attributes)
		cell.note = filltext
		cell.classNote.textContainer.maximumNumberOfLines = 3
		cell.classNote.textContainer.lineBreakMode = .byTruncatingTail
		
//		cell.classNote.text = classNote[className] as! String
//		(cell.classNote.font?.lineHeight)! * 5
		
		if classInfo.count > 0{
			//print("Scheduling")
			
			var classRoom = classInfo[className]?["room"] as! String
			classRoom = String(classRoom.characters.prefix(5))
			let teacher = (classInfo[className]?["teacher"] as! String)

			cell.teacher = NSAttributedString(string: teacher, attributes: [NSForegroundColorAttributeName: Style.sectionHeaderTitleColor])
			let time = classInfo[className]?["time"] as! String
			cell.time = time.components(separatedBy: "-")[0]
			cell.presence = classRoom
		}
		
		cell.update()
		
		return cell
		
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return classList.count
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		//Crashlytics.sharedInstance().crash()
		UserDefaults.standard.set(classList[(diaryTable.indexPathForSelectedRow?.row)!], forKey: "selectedClass")
		let selectedClass = classList[indexPath.row]
		_ = classNote[selectedClass]
		let cell: UITableViewCell = diaryTable.cellForRow(at: indexPath)!
		cell.contentView.backgroundColor = Style.sectionHeaderBackgroundColorHighlighted //Allow custom selected colours
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let mainController = storyboard.instantiateViewController(withIdentifier: "classOverview") as UIViewController
		
		
		//navigationController?.present(mainController, animated: true, completion: nil)
		let wrapper = wrapperviewController()
		wrapper.navigationController?.present(mainController, animated: true, completion: nil)
	}
	

	
	
}
	
class diaryList : UITableViewCell{
	var name = NSAttributedString()
	var note = NSAttributedString()
	var teacher = NSAttributedString()
	var time = ""
	var presence = ""
	
	@IBOutlet weak var className: UILabel!
	//@IBOutlet weak var classNote: UILabel!
	@IBOutlet weak var classPresence: UILabel!
	@IBOutlet weak var classTime: UILabel!
	@IBOutlet weak var classInfo: UILabel!
	@IBOutlet weak var classNote: UITextView!
	var accessoryButton: UIButton?
	
	
	
	func update() {
		
		
		className.attributedText = name
		classNote.attributedText = note
		classNote.font = UIFont(name: "System Font Regular", size: 15.0)
		classPresence.text = presence
		classTime.text = time
		classInfo.attributedText = teacher
	}
}
