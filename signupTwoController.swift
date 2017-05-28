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
class signupTwoController: UIViewController, UITextFieldDelegate  {
	
	
	@IBOutlet weak var backgroundImage: UIImageView!
	
	@IBOutlet weak var continueButton: UIButton!
	@IBOutlet weak var daymapUsername: UITextField!
	@IBOutlet weak var daymapPassword: UITextField!
	@IBOutlet weak var daymapConfirm: UITextField!
	var alreadyMoved = false
	
	@IBOutlet weak var errorMessage: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		errorMessage.isHidden = true
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(signupTwoController.dismissKeyboard))
		
		view.addGestureRecognizer(tap)
		
		daymapUsername.attributedPlaceholder = NSAttributedString(string: "Daymap Username (i.e john.smith)", attributes: [NSForegroundColorAttributeName: UIColor.white])
		daymapUsername.borderStyle = UITextBorderStyle.roundedRect
		daymapUsername.layer.borderColor = UIColor.white.cgColor
		daymapUsername.layer.borderWidth = CGFloat(1.0)
		daymapUsername.tag = 0
		daymapUsername.delegate = self
		
		
		
		daymapPassword.attributedPlaceholder = NSAttributedString(string: "Daymap Password", attributes: [NSForegroundColorAttributeName: UIColor.white])
		daymapPassword.borderStyle = UITextBorderStyle.roundedRect
		daymapPassword.layer.borderColor = UIColor.white.cgColor
		daymapPassword.layer.borderWidth = CGFloat(1.0)
		daymapPassword.tag = 1
		daymapPassword.delegate = self
		
		daymapConfirm.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSForegroundColorAttributeName: UIColor.white])
		daymapConfirm.borderStyle = UITextBorderStyle.roundedRect
		daymapConfirm.layer.borderColor = UIColor.white.cgColor
		daymapConfirm.layer.borderWidth = CGFloat(1.0)
		daymapConfirm.tag = 2
		daymapConfirm.delegate = self
		
		navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
		navigationController?.navigationBar.shadowImage = UIImage()
		navigationController?.navigationBar.isTranslucent = true
		navigationController?.view.backgroundColor = UIColor.clear
		navigationController?.navigationBar.tintColor = UIColor.white
		
		navigationItem.title = "Daymap"
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
		
		if let nextField = daymapUsername.superview?.viewWithTag(textField.tag + 1) as? UITextField {
			nextField.becomeFirstResponder()
		} else {
			// Not found, so remove keyboard.
			daymapUsername.resignFirstResponder()
		}
		
		
		return true
 }
	func checkInput(){
		var response = true
		//var alreadyEvaluated = false
		
		if daymapPassword.text != daymapConfirm.text{
			response = false
			errorMessage.text = "Passwords do not match"
			errorMessage.isHidden = false
		}
		
		if response == true{
			Alamofire.request("https://daymap.gihs.sa.edu.au/daymap/student/dayplan.aspx", method: .get)
				.authenticate(user: daymapUsername.text!, password: daymapPassword.text!)
				.responseString { response in
					if response.response?.statusCode == 200{
						let defaults = KeychainSwift()
						defaults.set(self.daymapUsername.text!, forKey: "daymapUsername")
						defaults.set(self.daymapPassword.text!, forKey: "daymapPassword")
						
						let storyboard = UIStoryboard(name: "Login", bundle: nil)
						let mainController = storyboard.instantiateViewController(withIdentifier: "signuppageThree") as UIViewController
						self.navigationController?.pushViewController(mainController, animated: true)

					} else {
						self.errorMessage.text = "Invalid Username/Password"
						self.errorMessage.isHidden = false
					}
			}
		}
	}

	
	@IBAction func signupThree(_ sender: Any) {
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
