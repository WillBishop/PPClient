//
//  signupOneController.swift
//  Osmond
//
//  Created by Will Bishop on 27/4/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import UIKit
import KeychainSwift

class signupOneController: UIViewController, UITextFieldDelegate  {

	
	@IBOutlet weak var backgroundImage: UIImageView!
	
	@IBOutlet weak var errorMessage: UILabel!
	@IBOutlet weak var continueButton: UIButton!
	@IBOutlet weak var stirlingUsername: UITextField!
	@IBOutlet weak var accountEmail: UITextField!
	@IBOutlet weak var stirlingPassword: UITextField!
	@IBOutlet weak var stirlingConfirm: UITextField!
	var alreadyMoved = false
	
    override func viewDidLoad() {
		
        super.viewDidLoad()
		errorMessage.isHidden = true
		errorMessage.numberOfLines = 0
		errorMessage.lineBreakMode = .byWordWrapping
		errorMessage.frame.size.width = 300
		//errorMessage.sizeToFit()
		
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(signupOneController.dismissKeyboard))
		
		view.addGestureRecognizer(tap)
		
		stirlingUsername.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName: UIColor.white])
		stirlingUsername.borderStyle = UITextBorderStyle.roundedRect
		stirlingUsername.layer.borderColor = UIColor.white.cgColor
		stirlingUsername.layer.borderWidth = CGFloat(1.0)
		stirlingUsername.tag = 0
		stirlingUsername.delegate = self
		
		accountEmail.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.white])
		accountEmail.borderStyle = UITextBorderStyle.roundedRect
		accountEmail.layer.borderColor = UIColor.white.cgColor
		accountEmail.layer.borderWidth = CGFloat(1.0)
		accountEmail.tag = 1
		accountEmail.delegate = self


		stirlingPassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.white])
		stirlingPassword.borderStyle = UITextBorderStyle.roundedRect
		stirlingPassword.layer.borderColor = UIColor.white.cgColor
		stirlingPassword.layer.borderWidth = CGFloat(1.0)
		stirlingPassword.tag = 2
		stirlingPassword.delegate = self

		stirlingConfirm.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSForegroundColorAttributeName: UIColor.white])
		stirlingConfirm.borderStyle = UITextBorderStyle.roundedRect
		stirlingConfirm.layer.borderColor = UIColor.white.cgColor
		stirlingConfirm.layer.borderWidth = CGFloat(1.0)
		stirlingConfirm.tag = 3
		stirlingConfirm.delegate = self
		
		navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
		navigationController?.navigationBar.shadowImage = UIImage()
		navigationController?.navigationBar.isTranslucent = true
		navigationController?.view.backgroundColor = UIColor.clear
		navigationController?.navigationBar.tintColor = UIColor.white
		
		navigationItem.title = "Stirling"
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
		if (textField.returnKeyType==UIReturnKeyType.go){
			checkInput()
		}
		if let nextField = stirlingUsername.superview?.viewWithTag(textField.tag + 1) as? UITextField {
			nextField.becomeFirstResponder()
		} else {
			stirlingUsername.resignFirstResponder()
		}
		
		
		return true
 }
	func validateEmail(enteredEmail:String) -> Bool {
		
		let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
		return emailPredicate.evaluate(with: enteredEmail)
		
	}
	func checkInput(){
		var response = true
		var alreadyEvaluated = false
		if (stirlingUsername.text?.characters.count == 0 && accountEmail.text?.characters.count == 0) {
			response = false
			self.errorMessage.text = "Could you atleast try to fill it out?"
			self.errorMessage.isHidden = false
		} else{
			if (stirlingPassword.text != stirlingConfirm.text && alreadyEvaluated == false){
				alreadyEvaluated = true
				response = false
				errorMessage.text = "Passwords do not match"
				errorMessage.isHidden = false
			}
			if validateEmail(enteredEmail: accountEmail.text!) == false{
				alreadyEvaluated = true
				response = false
				errorMessage.text = "Invalid Email"
				errorMessage.isHidden = false
			}
			
			if ((stirlingPassword.text?.characters.count)! < 6 && alreadyEvaluated == false){
				alreadyEvaluated = true
				response = false
				errorMessage.text = "Passwords must be greater than 6 characters"
				errorMessage.isHidden = false
			}
		
		}
		if response == true{
			var defaults = UserDefaults()
			defaults.set(stirlingUsername.text!, forKey: "stirlingUsername")
			defaults.set(accountEmail.text!, forKey: "stirlingEmail")
			defaults.set(stirlingPassword.text!, forKey: "stirlingPassword")
			
			var keychaindefaults = KeychainSwift()
			keychaindefaults.set(stirlingUsername.text!, forKey: "stirlingUsername")
			keychaindefaults.set(accountEmail.text!, forKey: "stirlingEmail")
			keychaindefaults.set(stirlingPassword.text!, forKey: "stirlingPassword")

			let storyboard = UIStoryboard(name: "Login", bundle: nil)
			let mainController = storyboard.instantiateViewController(withIdentifier: "signuppageTwo") as UIViewController
			
			navigationController?.pushViewController(mainController, animated: true)

		}
	}
	@IBAction func signupTwo(_ sender: Any) {
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
