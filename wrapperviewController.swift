//
//  wrapperviewController.swift
//  PP
//
//  Created by Will Bishop on 5/4/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import UIKit
import SideMenu



class wrapperviewController: UIViewController {

	var selectedView = UserDefaults.standard.object(forKey: "selectedView") as? String ?? "Diary"
	/* In the future, the selectedView may be stored in UserDefaults, that way when the user closes the app, when the launch it again it will open to where they left off. This kind of behaviour is promoted in the Apple Guideline */
		
	
	@IBOutlet weak var embeddedView: UIView!
	
	override func viewWillAppear(_ animated: Bool) {
		//selectedView = "Diary"
		_ = Style.loadTheme()
		print("Selected \(selectedView)")
		
		
		
		//self.navigationItem.titleView = setTitle(title: "Diary", subtitle: "12th of April")
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		
		let initialViewController = storyboard.instantiateViewController(withIdentifier: selectedView)
		embedView(initialViewController)
		
		let themeName = Style.loadTheme()
		SideMenuManager.menuFadeStatusBar = false
		SideMenuManager.menuWidth = UIScreen.main.bounds.width / 2
		navigationController?.navigationBar.barTintColor = Style.secionHeaderNavigationBarColor
		var image = UIImage(named: "hamburgerLightBlue")?.withRenderingMode(.alwaysOriginal)
		
		if themeName == "Light"{
			image = UIImage(named: "hamburgerLightBlue")?.withRenderingMode(.alwaysOriginal)
			//image = resizeImage(image: image!, newWidth: 32)
		}
		if themeName == "Dark"{image = UIImage(named: "hamburgerLight")?.withRenderingMode(.alwaysOriginal)}
		
		//image = UIImage(cgImage: cgImage, scale: (image?.size.width)! / 22, orientation: (image?.imageOrientation)!)
		let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(revealMenu))
		
		self.navigationItem.leftBarButtonItem = button
		
	}
	
	func embedView(_ newView: UIViewController){
		print("Setting title")
		self.navigationItem.title = selectedView
		if selectedView == "Diary"{
			let date = NSDate()
			_ = DateFormatter.Style.long
			
			let calender = NSCalendar.current
			let month = calender.component(.month, from: date as Date)
			let day = calender.component(.day, from: date as Date)
			var sounds = ["1": "1st", "2": "2nd", "3": "3rd", "4": "4th", "5": "5th", "6": "6th", "7": "7th", "8": "8th", "9": "9th", "10": "10th", "11": "11th", "12": "12th", "14": "14th", "15": "15th", "16": "16th", "17": "17th", "18": "18th", "19": "19th", "20": "20th", "21": "21st", "22": "22nd", "23": "23rd", "24": "24th", "25": "25th", "26": "26th", "27": "27th", "28": "28th", "29": "29th", "30": "30th", "31": "31st"]
			var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
			let sub = "\(sounds[String(describing: day)]!) of \(months[month - 1])"
			
			self.navigationItem.titleView = setTitle(title: "Diary", subtitle: sub)
			
		} else{
			self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Style.sectionHeaderTitleColor]
		}
		print("Loading View \(selectedView)")
		
		print(newView.view)
		print("Adjustings frame")
		print(newView.view.frame)
		
		newView.view.frame = CGRect(x:0, y:0, width:375, height:667)
		print("Adding view")
		
		
		print(embeddedView)
		self.embeddedView.addSubview((newView.view)!) //This line has caused be 7 hours of grief so far
		
		print("Adding view to child")
		addChildViewController(newView)
		print("Moving view")
		newView.didMove(toParentViewController: self)
		print("Initial Load")

		
		UserDefaults.standard.set("Diary", forKey: "selectedView")
	}
	func setTitle(title:String, subtitle:String) -> UIView {
		
		let titleLabel = UILabel(frame: CGRect(x:10, y:-2, width:0, height:0))
		
		titleLabel.backgroundColor = UIColor.clear
		titleLabel.textColor = UIColor.black
		titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
		titleLabel.attributedText = NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: Style.sectionHeaderTitleColor])
		
		titleLabel.sizeToFit()
		
		let subtitleLabel = UILabel(frame: CGRect(x:0, y:18, width:0, height:0))
		subtitleLabel.backgroundColor = UIColor.clear
		subtitleLabel.textColor = UIColor.black
		subtitleLabel.font = UIFont.systemFont(ofSize: 12)
		subtitleLabel.attributedText = NSAttributedString(string: subtitle, attributes: [NSForegroundColorAttributeName: Style.sectionHeaderTitleColor])
		subtitleLabel.sizeToFit()
		
		let titleView = UIView(frame: CGRect(x:0, y:0, width:max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height:30))
		titleView.addSubview(titleLabel)
		titleView.addSubview(subtitleLabel)
		
		let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
		
		if widthDiff < 0 {
			let newX = widthDiff / 2
			subtitleLabel.frame.origin.x = abs(newX)
		} else {
			let newX = widthDiff / 2
			titleLabel.frame.origin.x = newX
		}
		
		return titleView
	}
	
	func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage{
		let scale = newWidth / image.size.width
		let newHeight = image.size.height * scale
		UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
		image.draw(in: CGRect(x: 0, y:0, width: newWidth, height: newHeight))
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return newImage!
		
	}
	func revealMenu(){
		let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sidemenuController")
		
		
		present(vc, animated: true, completion: nil)
		
	}
    override func viewDidLoad() {
		
		
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
