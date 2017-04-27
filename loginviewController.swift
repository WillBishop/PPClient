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
	

	override func viewWillAppear(_ animated: Bool) {
		if ((UserDefaults.standard.object(forKey: "isloggedIn") as? String) != nil){ //Returns True if userDefaults contains a key called isloggedIn
			loggedIn()  // Calls loggedIn() function, which switces user to logged in page.
			//Should move this to viewWillAppear(), button seems to work OK.
		}
		
		navigationController?.isNavigationBarHidden = true
	}
    override func viewDidLoad() {
	
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func loggedIn() {//Switches user to logged in state.
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		//let mainController = storyboard.instantiateViewController(withIdentifier: "tabcontrollerforMain") as UIViewController
		let mainController = storyboard.instantiateViewController(withIdentifier: "initialView") as UIViewController
		
		let appDelegate =  UIApplication.shared.delegate as! AppDelegate
		appDelegate.window?.rootViewController = mainController
	}
	@IBAction func startSignup(_ sender: Any) {
		let storyboard = UIStoryboard(name: "Login", bundle: nil)
		let mainController = storyboard.instantiateViewController(withIdentifier: "signuppageOne") as UIViewController
		
		navigationController?.pushViewController(mainController, animated: true)
	}
	
	
	

}
