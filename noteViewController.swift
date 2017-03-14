//
//  noteViewController.swift
//  PP
//
//  Created by Will Bishop on 4/3/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//

import UIKit

class noteViewController: UIViewController {

	
	@IBOutlet weak var className: UILabel!
	@IBOutlet weak var classNote: UITextView!
	
	override func viewWillAppear(_ animated: Bool) {
		className.text = UserDefaults.standard.object(forKey: "selectedClass") as! String?
		classNote.text = UserDefaults.standard.object(forKey: "selectedclassNote") as! String?
		
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
