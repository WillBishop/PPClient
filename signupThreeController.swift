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
import Crashlytics

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
		
		
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(signupThreeController.dismissKeyboard))
		
		view.addGestureRecognizer(tap)
		
		moodleUsername.attributedPlaceholder = NSAttributedString(string: "Moodle Username (i.e john.smith)", attributes: [NSForegroundColorAttributeName: UIColor.white])
		moodleUsername.borderStyle = UITextBorderStyle.roundedRect
		moodleUsername.layer.borderColor = UIColor.white.cgColor
		moodleUsername.layer.borderWidth = CGFloat(1.0)
		moodleUsername.tag = 0
		moodleUsername.delegate = self
		
		
		
		moodlePassword.attributedPlaceholder = NSAttributedString(string: "Moodle Password", attributes: [NSForegroundColorAttributeName: UIColor.white])
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
			if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
				alreadyMoved = true
				self.view.frame.origin.y -= 20
			}
		}
	}
	
	func dismissKeyboard() {
		view.endEditing(true)
	}
	
	func keyboardWillHide(notification: NSNotification) {
		if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
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
		let defaults = KeychainSwift()
		
		
		let stirlingUsername = defaults.get( "stirlingUsername")!
		print("1")
		let stirlingPassword = defaults.get( "stirlingPassword")!
		print("2")
		let stirlingEmail = defaults.get( "stirlingEmail")!
		print("3")
		let daymapUsername = defaults.get( "daymapUsername")!
		print("4")
		let daymapPassword = defaults.get( "daymapPassword")!
		print("5")
		let moodleUsername = defaults.get( "moodleUsername")!
		print("6")
		let moodlePassword = defaults.get( "moodlePassword")!
		print("7")
		
		let stirlingParameters: [String: String] = [
			"username": stirlingUsername.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
			"password": stirlingPassword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
			"email": stirlingEmail.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
		]
		let daymapUserParameters: [String: String] = [
			"username": stirlingUsername.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
			"password": stirlingPassword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
			"daymapUsername": daymapUsername.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
		]
		print(daymapUserParameters)

		let daymapPassParameters: [String: String] = [
			"username": stirlingUsername.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
			"password": stirlingPassword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
			"daymapPassword": daymapPassword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
		]
		print(daymapPassParameters)
		let moodleUserParameters: [String: String] = [
			"username": stirlingUsername.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
			"password": stirlingPassword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
			"moodleUsername": moodleUsername.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
		]
		let moodlePassParameters: [String: String] = [
			"username": stirlingUsername.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
			"password": stirlingPassword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
			"moodlePassword": moodlePassword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
		]
		
		/* The reasoning behind this horrendous nesting is that Alamofire is Asynchronous. Each of these requests
		takes less than 200ms. If I lined them all up, there is the possibility that it would try to add the Moodle 
		username to an account that did not yet exist. The nesting waits for each request to finish.
		*/
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
											.responseString { moodle in
												print("/update/moodlePassword " + String(describing: moodle.response?.statusCode))
												Answers.logSignUp(withMethod: "Built-In", success: 1, customAttributes: [:])
												if moodle.response?.statusCode == 200{
													self.loggedIn()
												}
												
										}
								}
						}
				}
		}
		
	}
	
	func loggedIn() {//Switches user to logged in state.
		let defaults = KeychainSwift()
		let stirlingUsername = defaults.get( "stirlingUsername")
		let stirlingPassword = defaults.get( "stirlingPassword")
		let keychain = KeychainSwift()
		keychain.set(stirlingUsername!, forKey: "username")
		keychain.set(stirlingPassword!, forKey: "password")
		UserDefaults.standard.set("yes", forKey: "isloggedIn")
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let mainController = storyboard.instantiateViewController(withIdentifier: "initialView") as UIViewController
		let appDelegate =  UIApplication.shared.delegate as! AppDelegate
		appDelegate.window?.rootViewController = mainController
	}
	
	func credentialsCorrect(){//In future I will add login validation, this is the groundwork.
		
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
			let defaults = KeychainSwift()
			defaults.set(self.moodleUsername.text!, forKey: "moodleUsername")
			defaults.set(self.moodlePassword.text!, forKey: "moodlePassword")
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
