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
	
	@IBOutlet weak var cannotfindSchool: UILabel! //cannotfindschoolAccount seemed too long
	@IBOutlet weak var daymapUsername: UITextField!
	
	@IBOutlet weak var daymapPassword: UITextField!

	
	@IBOutlet weak var loginProcess: UIActivityIndicatorView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		

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
		print("Checking")
		Alamofire.request("https://daymap.gihs.sa.edu.au/daymap/student/dayplan.aspx", method: .get)
			.authenticate(user: daymapUsername.text!, password: daymapPassword.text!) //Alamofire does auto NTLM
			.responseString { response in
				print("Got response code \(String(describing: response.response?.statusCode))")
					 
				//TODO: Update to support reponse codes in the 200 range, as opposed to just 200.
				if response.response?.statusCode == 200{
					self.credentialsCorrect()
					self.loginProcess.stopAnimating()
				}
				else if response.response?.statusCode == 401{
					self.cannotfindSchool.text = "Incorrect Username or Password"
					self.loginProcess.stopAnimating()
				}
				else if response.response?.statusCode != 200 && response.response?.statusCode != 401{
					self.cannotfindSchool.text = "Error, please try again later."
					self.loginProcess.stopAnimating()
				}
				
		}}

	func loggedIn() {//Switches user to logged in state.
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		//let mainController = storyboard.instantiateViewController(withIdentifier: "tabcontrollerforMain") as UIViewController
		let mainController = storyboard.instantiateViewController(withIdentifier: "tabcontrollerforMain") as UIViewController
		
		let appDelegate =  UIApplication.shared.delegate as! AppDelegate
		appDelegate.window?.rootViewController = mainController
	}
	
	func credentialsCorrect(){//In future I will add login validation, this is the groundwork.
		let keychain = KeychainSwift()

		keychain.set(daymapUsername.text!, forKey: "username")
		keychain.set(daymapPassword.text!, forKey: "password")
		UserDefaults.standard.set("yes", forKey: "isloggedIn")
		loggedIn()}
	
	@IBAction func submitCreds(_ sender: Any) {
		print("Initiating Login")
		loginProcess.startAnimating()
		checkCredentials()
	}
	

}
