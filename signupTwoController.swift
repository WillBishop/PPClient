//
//  signupOneController.swift
//  Osmond
//
//  Created by Will Bishop on 27/4/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import UIKit

class signupTwoController: UIViewController, UITextFieldDelegate  {
	
	
	@IBOutlet weak var backgroundImage: UIImageView!
	
	@IBOutlet weak var continueButton: UIButton!
	@IBOutlet weak var daymapUsername: UITextField!
	@IBOutlet weak var daymapPassword: UITextField!
	@IBOutlet weak var daymapConfirm: UITextField!
	var alreadyMoved = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
		
		view.addGestureRecognizer(tap)
		
		daymapUsername.attributedPlaceholder = NSAttributedString(string: "Daymap Username", attributes: [NSForegroundColorAttributeName: UIColor.white])
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
			let storyboard = UIStoryboard(name: "Login", bundle: nil)
			let mainController = storyboard.instantiateViewController(withIdentifier: "signuppageOne") as UIViewController
			
			navigationController?.pushViewController(mainController, animated: true)
			
		}
		
		if let nextField = daymapUsername.superview?.viewWithTag(textField.tag + 1) as? UITextField {
			nextField.becomeFirstResponder()
		} else {
			// Not found, so remove keyboard.
			daymapUsername.resignFirstResponder()
		}
		
		
		return true
 }
	@IBAction func signupTwo(_ sender: Any) {
		dismissKeyboard()
		let storyboard = UIStoryboard(name: "Login", bundle: nil)
		let mainController = storyboard.instantiateViewController(withIdentifier: "signuppageTwo") as UIViewController
		
		navigationController?.pushViewController(mainController, animated: true)
		
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
