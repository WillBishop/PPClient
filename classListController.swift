//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift

class diaryController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	
	@IBOutlet var diaryTable: UITableView!
	
	var classList = UserDefaults.standard.object(forKey: "cachedClasses") as? [String] ?? [String]()
	var classNote = UserDefaults.standard.object(forKey: "cachedNotes") as? [String: String?] ?? [String: String!]()
	
	
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
		let headers = [
			"Content-Type": "application/x-www-form-urlencoded"
		]
		let keychain = KeychainSwift()
		let username = keychain.get("username") as! String?
		let password = keychain.get("password") as! String?
		let parameters = [
			"username": username!,
			"password": password!
			
		]
		Alamofire.request("https://theapiiamusing.com/getDiary", method: .post,parameters: parameters, headers: headers)
			.responseJSON { response in
				if response.result.value != nil{
					self.classList.removeAll()
					self.classNote.removeAll()
					let json = JSON(response.result.value!)
					for i in json["classes"]{
						print(String(describing: i))
						self.classList.append(String(describing: i.1))
					}
					for i in json["details"]{
						let name = String(describing: i.1["class"])
						self.classNote[name] = String(describing: i.1["note"]).replacingOccurrences(of: "INSERTAPOSTROPHE", with: "'")
					}
					
					UserDefaults.standard.set(self.classList, forKey: "cachedClasses")
					UserDefaults.standard.set(self.classNote, forKey: "cachedNotes")
					
					print(self.classList)
					
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
		cell.name = classList[indexPath.row]
		
		//print(classList[indexPath.row])
		if classNote[classList[indexPath.row]] != nil{
			print("setting note")
			cell.note = classNote[classList[indexPath.row]]!!
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
	
	@IBOutlet weak var className: UILabel!
	@IBOutlet weak var classNote: UILabel!
	
	func update() {
		className.text = name
		classNote.text = note
	}
}
