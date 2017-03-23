//
//  loginviewController.swift
//  PP
//
//  Created by Will Bishop on 3/3/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import UIKit
import Alamofire
import KeychainSwift

class loginviewController: UIViewController {

	var mainStoryboard = UIViewController()
	
	@IBOutlet weak var cannotfindSchool: UILabel!
	@IBOutlet weak var daymapUsername: UITextField!
	
	@IBOutlet weak var daymapPassword: UITextField!

	
//	@IBOutlet weak var loginProcess: UIActivityIndicatorView!
	
	@IBOutlet weak var loginButton: UIButton!
	
	//@IBOutlet weak var signupButton: UIButton!
    override func viewDidLoad() {
		daymapUsername.attributedPlaceholder = NSAttributedString(string: "Stirling Username", attributes: [NSForegroundColorAttributeName: UIColor.white])
		daymapPassword.attributedPlaceholder = NSAttributedString(string: "Stirling Password", attributes: [NSForegroundColorAttributeName: UIColor.white])
        super.viewDidLoad()
		loginButton.backgroundColor = UIColor(red: 0.20, green: 0.59, blue: 0.86, alpha: 1)
		daymapUsername.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
		daymapPassword.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
		//signupButton.backgroundColor = UIColor(red: 0.15, green: 0.77, blue: 0.38, alpha: 1)
		if ((UserDefaults.standard.object(forKey: "isloggedIn") as? String) != nil){ //Returns True if userDefaults contains a key called isloggedIn
			loggedIn()  // Calls loggedIn() function, which switces user to logged in page.
			//Should move this to viewWillAppear(), button seems to work OK.
		}
		

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func checkCredentials(){
		let username = daymapUsername.text!.lowercased().replacingOccurrences(of: "curric\\", with: "")
		print(username)
		let password = daymapPassword.text!
		
		print("Checking")
		Alamofire.request("https://daymap.gihs.sa.edu.au/daymap/student/dayplan.aspx", method: .get)
			.authenticate(user: username, password: password) //Alamofire does auto NTLM
			.responseString { response in
				print("Got response code \(String(describing: response.response?.statusCode))")
				if response.response?.statusCode == 200{
					self.credentialsCorrect()
					//self.loginProcess.stopAnimating()
				}
				else if response.response?.statusCode == 401{
					self.cannotfindSchool.text = "Incorrect Username or Password"
					//self.loginProcess.stopAnimating()
				}
				else if response.response?.statusCode != 200 && response.response?.statusCode != 401{
					self.cannotfindSchool.text = "Error, please try again later."
					//self.loginProcess.stopAnimating()
				}
				
		}}

	func loggedIn() {//Switches user to logged in state.
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		//let mainController = storyboard.instantiateViewController(withIdentifier: "tabcontrollerforMain") as UIViewController
		let mainController = storyboard.instantiateViewController(withIdentifier: "initialView") as UIViewController
		
		let appDelegate =  UIApplication.shared.delegate as! AppDelegate
		appDelegate.window?.rootViewController = mainController
	}
	
	func credentialsCorrect(){//In future I will add login validation, this is the groundwork.
		let keychain = KeychainSwift()

		keychain.set(daymapUsername.text!.lowercased().replacingOccurrences(of: "curric\\", with: ""), forKey: "username")
		keychain.set(daymapPassword.text!, forKey: "password")
		UserDefaults.standard.set("yes", forKey: "isloggedIn")
		loggedIn()}
	
	@IBAction func submitCreds(_ sender: Any) {
		checkCredentials()
	}
	
	

}
