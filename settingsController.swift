//
//  settingsController.swift
//  Osmond
//
//  Created by Will Bishop on 7/5/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import UIKit
import KeychainSwift
import Crashlytics

class settingsController: UITableViewController {

	@IBOutlet var settingsTable: UITableView!
	let headers = ["Account Settings", "Appearance"]
	let sections = ["Account Settings": ["Stirling Settings", "Daymap Settings", "Moodle Settings"], "Appearance": ["Change Theme"]]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return headers.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		return (sections[headers[section]]?.count)!
	}
	override func viewWillAppear(_ animated: Bool) {
		settingsTable.tableFooterView = UIView()
		settingsTable.backgroundColor = Style.sectionHeaderBackgroundColor
	}
	
	func refreshView(){
		for window in UIApplication.shared.windows {
			for view in window.subviews {
				view.removeFromSuperview()
				window.addSubview(view)
			}
			// update the status bar if you change the appearance of it.
			window.rootViewController?.setNeedsStatusBarAppearanceUpdate()
		}
		
	}
	
	func lightTheme() {
		UserDefaults.standard.set("Light Theme", forKey: "theme")
		refreshView()
	}

	func nightTheme() {
		UserDefaults.standard.set("Dark Theme", forKey: "theme")
		refreshView()
	}

	

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.backgroundColor = Style.tablecellColor
		
		let selectedHeader = indexPath[0]
		let selectedRow = indexPath[1]
		print("setting")
		let cellrowText = sections[headers[selectedHeader]]![selectedRow]
		cell.accessoryType = .disclosureIndicator
		print(cellrowText)
		
		let cellText = NSAttributedString(string: cellrowText, attributes: [NSForegroundColorAttributeName: Style.sectionHeaderTitleColor])
		
		print("Here1")
		cell.textLabel?.attributedText = cellText
	}
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
		returnedView.backgroundColor = Style.tableheaderColor
		
		let label = UILabel(frame: CGRect(x: 10, y: 2, width: view.frame.size.width, height: 25))
		label.text = self.tableView(tableView, titleForHeaderInSection: section)
		label.textColor = Style.sectionHeaderTitleColor
		returnedView.addSubview(label)
		return returnedView
	}
	func changeTheme(){
		let alertController = UIAlertController(title: "Select Theme", message: "", preferredStyle: UIAlertControllerStyle.alert)
		
		let cancelAction = UIAlertAction(title: "Dark", style: UIAlertActionStyle.default) {
			UIAlertAction in
			self.nightTheme()
		}
		
		let settingsAction = UIAlertAction(title: "Light", style: UIAlertActionStyle.default) {
			UIAlertAction in
			self.lightTheme()
		}
		alertController.addAction(cancelAction)
		alertController.addAction(settingsAction)
		self.present(alertController, animated: true, completion: nil)

	}
	func logOut(){
		Answers.logCustomEvent(withName: "Logged Out", customAttributes: [:])
		let keychain = KeychainSwift()
		keychain.clear() //Deletes all stored usernames and passwords
		UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!) //Removes all cached class info
		UserDefaults.standard.synchronize()
		UIApplication.shared.cancelAllLocalNotifications() //These comments are a bit dedundant
		
		
		let storyboard = UIStoryboard(name: "Login", bundle: nil) //Code is the same used in the storyboard changing function in other view controllers.
		let mainController = storyboard.instantiateViewController(withIdentifier: "loginNavView") as UIViewController
		let appDelegate =  UIApplication.shared.delegate as! AppDelegate
		appDelegate.window?.rootViewController = mainController
	}
	
	func stirlingSettings(){
		let alertController = UIAlertController(title: "Stirling Settings", message: "Sad to see you go!", preferredStyle: UIAlertControllerStyle.alert)
		
		let cancelAction = UIAlertAction(title: "Logout", style: UIAlertActionStyle.destructive) {
			UIAlertAction in
			self.logOut()
		}
		
		let settingsAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default) {
			UIAlertAction in
			return
		}
		alertController.addAction(cancelAction)
		alertController.addAction(settingsAction)
		self.present(alertController, animated: true, completion: nil)
		
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 1{
			changeTheme()
		} else if (indexPath.section == 0 && indexPath.row == 0){
			stirlingSettings()
		}
	}
	

}
