//
//  accountLoginController.swift
//  Osmond
//
//  Created by Will Bishop on 28/4/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import UIKit
import KeychainSwift
import Alamofire

class accountLoginController: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var stirlingUsername: UITextField!
	@IBOutlet weak var stirlingPassword: UITextField!
	var alreadyMoved = false
	
	@IBOutlet weak var errorMessage: UILabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		errorMessage.isHidden = true
		
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(signupOneController.dismissKeyboard))
		
		view.addGestureRecognizer(tap)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		stirlingUsername.attributedPlaceholder = NSAttributedString(string: "Stirling Username", attributes: [NSForegroundColorAttributeName: UIColor.white])
		stirlingUsername.borderStyle = UITextBorderStyle.roundedRect
		stirlingUsername.layer.borderColor = UIColor.white.cgColor
		stirlingUsername.layer.borderWidth = CGFloat(1.0)
		stirlingUsername.tag = 0
		stirlingUsername.delegate = self
		
		stirlingPassword.attributedPlaceholder = NSAttributedString(string: "Stirling Password", attributes: [NSForegroundColorAttributeName: UIColor.white])
		stirlingPassword.borderStyle = UITextBorderStyle.roundedRect
		stirlingPassword.layer.borderColor = UIColor.white.cgColor
		stirlingPassword.layer.borderWidth = CGFloat(1.0)
		stirlingPassword.tag = 1
		stirlingPassword.delegate = self
		
		navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
		navigationController?.navigationBar.shadowImage = UIImage()
		navigationController?.navigationBar.isTranslucent = true
		navigationController?.view.backgroundColor = UIColor.clear
		navigationController?.navigationBar.tintColor = UIColor.white

		navigationItem.title = "Login"
		self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
		navigationController?.isNavigationBarHidden = false



        // Do any additional setup after loading the view.
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
	
	private func textFieldShouldReturn(_ textField: UITextField){
		if (textField.returnKeyType==UIReturnKeyType.go){
			submitCreds()
		}
		if let nextField = stirlingUsername.superview?.viewWithTag(textField.tag + 1) as? UITextField {
			nextField.becomeFirstResponder()
		} else {
			stirlingUsername.resignFirstResponder()
		}
		
	
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
		}
	func submitCreds(){
		print("were going")
		
		Alamofire.request("https://da.gihs.sa.edu.au/stirling/student/classes/get/daily?username=\(stirlingUsername.text!)&password=\(stirlingPassword.text!)&date=12/04/2017", method: .get)
			.responseString { response in
				if response.response?.statusCode != 200{
					self.errorMessage.text = "Invalid Username/Password"
					print("Fail")
				} else{
					print("Great success")
					let keychain = KeychainSwift()
					keychain.set(self.stirlingUsername.text!, forKey: "stirlingUsername")
					keychain.set(self.stirlingPassword.text!, forKey: "stirlingPassword")
					UserDefaults.standard.set("yes", forKey: "isloggedIn")
					print("And we're off!")
					let storyboard = UIStoryboard(name: "Main", bundle: nil)
					let mainController = storyboard.instantiateViewController(withIdentifier: "initialView") as UIViewController
					let appDelegate =  UIApplication.shared.delegate as! AppDelegate
					appDelegate.window?.rootViewController = mainController
					print("gone")
				}
		}
		
	}
	@IBAction func loginpressed(_ sender: Any) {
		submitCreds()
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

