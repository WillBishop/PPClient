//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift
import UserNotifications


class diaryController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	
	@IBOutlet var diaryTable: UITableView!
	
	
	
	var classList = UserDefaults.standard.object(forKey: "cachedClasses") as? [String] ?? [String]() //Grab all the cached data
	var classNote = UserDefaults.standard.object(forKey: "cachedNotes") as? [String: String?] ?? [String: String!]()
	var classInfo = UserDefaults.standard.object(forKey: "cachedInfo") as? [String: [String: Any]] ?? [String: [String: Any]]()
	
	//let displayNote = UITextView(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.width - 10, height:300)) //text view to be footer to table
	override func viewWillAppear(_ animated: Bool) {

//		let noClasses = UITextView(frame: CGRect(x:0, y:0, width:view.frame.width, height:view.frame.height))
//		noClasses.text = "No classes today, yay!"
		//diaryTable.tableFooterView = UIView()
		print("Starting")
	
		_ = Style.loadTheme() //loadTheme() returns a string, but I do not use it at this moment
		diaryTable.backgroundColor = Style.sectionHeaderBackgroundColor
		
		//self.navigationItem.setHidesBackButton(true, animated:true)
		
		//displayNote.backgroundColor = Style.sectionHeaderBackgroundColor
		//displayNote.textColor = Style.sectionHeaderTitleColor

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
		
//		displayNote.text = "Click a class to reveal more information"
//		displayNote.font = UIFont.systemFont(ofSize: 14.0)
//		displayNote.isEditable = false //Theoretically allows the user to highlight and copy, but not actually edit the text (client-side)
//		
//		let customView = UIView(frame: CGRect(x:10, y:10, width:100, height:200))
//
//		customView.addSubview(displayNote)
		
		//diaryTable.tableFooterView = customView //Not only hides unused cells, but lets the note view scale with the amount of classes
		
		
		
	
		
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
		let username = keychain.get("stirlingUsername")!
		//username = username.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
	
		let password = keychain.get("stirlingPassword")!
		//var password = "@abc#".encodeUrl()
		print(password)
		//print("Starting")
		let date = "12/04/17" //Hardcoded date for testing
		
		print("https://da.gihs.sa.edu.au/stirling/student/classes/get/daily?username=\(username.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&password=\(password.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&date=12/04/2017")
		Alamofire.request("https://da.gihs.sa.edu.au/stirling/student/classes/get/daily?username=\(username.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&password=\(password.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&date=\(date)", method: .get)
			.responseJSON { response in
				print(response.response?.statusCode ?? "Got nothing")
				print("Done")
				if response.result.value != nil{
					self.classList.removeAll() //Remove all existing data to prevent overlapping data
					self.classNote.removeAll()
					self.classInfo.removeAll()
					let json = JSON(response.result.value!)
					
					for i in json["daymapDailyClasses"]{
						
						let name = String(describing: i.1["className"])
						
						self.classList.append(String(describing: i.1["className"]))
						
						self.classNote[name] = String(describing: i.1["classNotes"])
						print(self.classNote[name]!!)
						if String(describing: self.classNote[name]!!) == "NONE_AVAILABLE"{
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
						

						
						
						
						self.classInfo[name] = ["time": String(describing: i.1["startTime"]), "room": String(describing: i.1["roomName"]), "teacher":   String(describing: (i.1["teachers"][0])), "presence": attendance, "numericalstartHour": numericalstartTime[0], "numericalstartMinute": numericalstartTime[1], "homework": String(describing: (i.1["homework"]))]
						
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
			var seperated = teacher.components(separatedBy: " ")
			
			let lastnameLetter = String((seperated[1].characters.first!))
			
			
			let teacherName = seperated[0] + " " + lastnameLetter + String(seperated[1].characters.dropFirst()).lowercased()

			cell.teacher = NSAttributedString(string: teacherName, attributes: [NSForegroundColorAttributeName: Style.sectionHeaderTitleColor])
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
		print("Setting")
		UserDefaults.standard.set(classList[(diaryTable.indexPathForSelectedRow?.row)!], forKey: "selectedClass")
		let selectedClass = classList[indexPath.row]
		_ = classNote[selectedClass]
		let cell: UITableViewCell = diaryTable.cellForRow(at: indexPath)!
		cell.contentView.backgroundColor = Style.sectionHeaderBackgroundColorHighlighted //Allow custom selected colours
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let mainController = storyboard.instantiateViewController(withIdentifier: "classOverview") as UIViewController
		
		
		print(classList[(diaryTable.indexPathForSelectedRow?.row)!])
		//navigationController?.present(mainController, animated: true, completion: nil)
		let wrapper = wrapperviewController()
		print("Going... going...")
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
