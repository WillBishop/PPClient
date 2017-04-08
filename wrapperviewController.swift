//
//  wrapperviewController.swift
//  PP
//
//  Created by Will Bishop on 5/4/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import UIKit
import SideMenu



class wrapperviewController: UIViewController {

	var selectedView = ""
	/* In the future, the selectedView may be stored in UserDefaults, that way when the user closes the app, when the launch it again it will open to where they left off. This kind of behaviour is promoted in the Apple Guideline */
	
	
	@IBOutlet weak var embeddedView: UIView!
	
	override func viewWillAppear(_ animated: Bool) {
		if selectedView != ""{
			print("Selected \(selectedView)")
			
			self.navigationItem.title = selectedView //Changed top title to reflect seleted view
			let newView = self.storyboard?.instantiateViewController(withIdentifier: selectedView) //Find the view controller
			newView?.view.frame = embeddedView.bounds //Change the view controllers frame to fit the embedded frame
			embeddedView.addSubview((newView?.view)!) //Add the new view to the UIView
			addChildViewController(newView!)
			newView?.didMove(toParentViewController: self) //Brings it to the front
			
			

		}else{ //If the app has just been launched
			let newView = self.storyboard?.instantiateViewController(withIdentifier: "Dayplan")
			newView?.view.frame = embeddedView.bounds
			embeddedView.addSubview((newView?.view)!)
			addChildViewController(newView!)
			newView?.didMove(toParentViewController: self)
			print("Initial Load")
		}
		
		let themeName = Style.loadTheme()
		SideMenuManager.menuFadeStatusBar = false
		SideMenuManager.menuWidth = UIScreen.main.bounds.width / 2
		navigationController?.navigationBar.barTintColor = Style.secionHeaderNavigationBarColor
		var image = UIImage(named: "hamburger")?.withRenderingMode(.alwaysOriginal)
		
		if themeName == "Light"{image = UIImage(named: "hamburger")?.withRenderingMode(.alwaysOriginal)}
		if themeName == "Dark"{image = UIImage(named: "hamburgerLight")?.withRenderingMode(.alwaysOriginal)}
		
		//image = UIImage(cgImage: cgImage, scale: (image?.size.width)! / 22, orientation: (image?.imageOrientation)!)
		let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(revealMenu))
		
		self.navigationItem.leftBarButtonItem = button
		
	}
	func revealMenu(){
		let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sidemenuController")
		
		
		present(vc, animated: true, completion: nil)
		
	}
    override func viewDidLoad() {
		
		
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
