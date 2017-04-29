//
//  signupOneController.swift
//  Osmond
//
//  Created by Will Bishop on 27/4/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import UIKit
import Alamofire
import KeychainSwift

class signupThreeController: UIViewController, UITextFieldDelegate  {
	
	
	@IBOutlet weak var backgroundImage: UIImageView!
	
	@IBOutlet weak var continueButton: UIButton!
	@IBOutlet weak var moodleUsername: UITextField!
	@IBOutlet weak var moodlePassword: UITextField!
	@IBOutlet weak var moodleConfirm: UITextField!
	var alreadyMoved = false
	
	@IBOutlet weak var errorMessage: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		errorMessage.isHidden = true
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
		
		view.addGestureRecognizer(tap)
		
		moodleUsername.attributedPlaceholder = NSAttributedString(string: "moodle Username", attributes: [NSForegroundColorAttributeName: UIColor.white])
		moodleUsername.borderStyle = UITextBorderStyle.roundedRect
		moodleUsername.layer.borderColor = UIColor.white.cgColor
		moodleUsername.layer.borderWidth = CGFloat(1.0)
		moodleUsername.tag = 0
		moodleUsername.delegate = self
		
		
		
		moodlePassword.attributedPlaceholder = NSAttributedString(string: "moodle Password", attributes: [NSForegroundColorAttributeName: UIColor.white])
		moodlePassword.borderStyle = UITextBorderStyle.roundedRect
		moodlePassword.layer.borderColor = UIColor.white.cgColor
		moodlePassword.layer.borderWidth = CGFloat(1.0)
		moodlePassword.tag = 1
		moodlePassword.delegate = self
		
		moodleConfirm.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSForegroundColorAttributeName: UIColor.white])
		moodleConfirm.borderStyle = UITextBorderStyle.roundedRect
		moodleConfirm.layer.borderColor = UIColor.white.cgColor
		moodleConfirm.layer.borderWidth = CGFloat(1.0)
		moodleConfirm.tag = 2
		moodleConfirm.delegate = self
		
		navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
		navigationController?.navigationBar.shadowImage = UIImage()
		navigationController?.navigationBar.isTranslucent = true
		navigationController?.view.backgroundColor = UIColor.clear
		navigationController?.navigationBar.tintColor = UIColor.white
		
		navigationItem.title = "moodle"
		self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
		navigationController?.isNavigationBarHidden = false
		
		continueButton.backgroundColor = UIColor(red: 0.29, green: 0.56, blue: 0.88, alpha: 1)
		continueButton.layer.cornerRadius = 5
		continueButton.layer.borderWidth = 1
		continueButton.layer.borderColor = UIColor.white.cgColor
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	func keyboardWillShow(notification: NSNotification) {
		
		if alreadyMoved != true{
			if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
				alreadyMoved = true
				self.view.frame.origin.y -= 20
			}
		}
	}
	
	func dismissKeyboard() {
		view.endEditing(true)
	}
	
	func keyboardWillHide(notification: NSNotification) {
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			self.view.frame.origin.y += 20
			alreadyMoved = false
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		print("LETS A GO")
		if (textField.returnKeyType==UIReturnKeyType.go)
		{
			dismissKeyboard()
			checkInput()
			
		}
		
		if let nextField = moodleUsername.superview?.viewWithTag(textField.tag + 1) as? UITextField {
			nextField.becomeFirstResponder()
		} else {
			// Not found, so remove keyboard.
			moodleUsername.resignFirstResponder()
		}
		
		
		return true
 }
	func createAccount(){
		let defaults = UserDefaults()
		let stirlingUsername = defaults.object(forKey: "stirlingUsername")
		let stirlingPassword = defaults.object(forKey: "stirlingPassword")
		let stirlingEmail = defaults.object(forKey: "stirlingEmail")
		let daymapUsername = defaults.object(forKey: "daymapUsername")
		let daymapPassword = defaults.object(forKey: "daymapPassword")
		let moodleUsername = defaults.object(forKey: "moodleUsername")
		let moodlePassword = defaults.object(forKey: "moodlePassword")
		
		let stirlingParameters = [
			"username": stirlingUsername!,
			"password": stirlingPassword!,
			"email": stirlingEmail!
		]
		let daymapUserParameters = [
			"username": stirlingUsername!,
			"password": stirlingPassword!,
			"daymapUsername": daymapUsername!
		]
		print(daymapUserParameters)

		let daymapPassParameters = [
			"username": stirlingUsername!,
			"password": stirlingPassword!,
			"daymapPassword": daymapPassword!
		]
		print(daymapPassParameters)
		let moodleUserParameters = [
			"username": stirlingUsername!,
			"password": stirlingPassword!,
			"moodleUsername": moodleUsername!
		]
		let moodlePassParameters = [
			"username": stirlingUsername!,
			"password": stirlingPassword!,
			"moodlePassword": moodlePassword!
		]
		
		_ = Alamofire.request("https://da.gihs.sa.edu.au/stirling/accounts/add", method: .post, parameters: stirlingParameters)
			.responseString { response in
				print("/accounts/add " + String(describing: response.response?.statusCode))
				_ = Alamofire.request("https://da.gihs.sa.edu.au/stirling/accounts/update/daymapUsername", method: .post, parameters: daymapUserParameters)
					.responseString { response in
						print("/update/daymapUsername " + String(describing: response.response?.statusCode))
						_ = Alamofire.request("https://da.gihs.sa.edu.au/stirling/accounts/update/daymapPassword", method: .post, parameters: daymapPassParameters)
							.responseString { response in
								print("/update/daymapPassword " + String(describing: response.response?.statusCode))
								_ = Alamofire.request("https://da.gihs.sa.edu.au/stirling/accounts/update/moodleUsername", method: .post, parameters: moodleUserParameters)
									.responseString { response in
										print("/update/moodleUsername " + String(describing: response.response?.statusCode))
										_ = Alamofire.request("https://da.gihs.sa.edu.au/stirling/accounts/update/moodlePassword", method: .post, parameters: moodlePassParameters)
											.responseString { response in
												print("/update/moodlePassword " + String(describing: response.response?.statusCode))
												self.loggedIn()
										}
								}
						}
				}
		}
		
		


		
		
		
		
		
		
		
		
		

		
		
	}
	
	func loggedIn() {//Switches user to logged in state.
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let mainController = storyboard.instantiateViewController(withIdentifier: "initialView") as UIViewController
		let appDelegate =  UIApplication.shared.delegate as! AppDelegate
		appDelegate.window?.rootViewController = mainController
	}
	
	func credentialsCorrect(){//In future I will add login validation, this is the groundwork.
		let defaults = UserDefaults()
		let stirlingUsername = defaults.object(forKey: "stirlingUsername")
		let stirlingPassword = defaults.object(forKey: "stirlingPassword")
		let keychain = KeychainSwift()
		keychain.set(stirlingUsername as! String, forKey: "username")
		keychain.set(stirlingPassword as! String, forKey: "password")
		UserDefaults.standard.set("yes", forKey: "isloggedIn")
		loggedIn()}
	
	func checkInput(){
		var response = true
		//var alreadyEvaluated = false
		
		if moodlePassword.text != moodleConfirm.text{
			response = false
			errorMessage.text = "Passwords do not match"
			errorMessage.isHidden = false
		}
		if response == true{
			let defaults = UserDefaults()
			defaults.set(self.moodleUsername.text!, forKey: "moodleUsername")
			defaults.set(self.moodlePassword.text!, forKey: "moodlePassword")
			credentialsCorrect()
			createAccount()
			

		}
		
	}
	
	
	@IBAction func signupDone(_ sender: Any) {
		dismissKeyboard()
		checkInput()
	}
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
}
