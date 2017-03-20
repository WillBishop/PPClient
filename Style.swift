//
//  Style.swift
//  PP
//
//  Created by Will Bishop on 19/3/17.
//  Copyright © 2017 Will Bishop. All rights reserved.
//
import Foundation
import UIKit

struct Style{
	// MARK: ToDo Table Section Headers
	static var sectionHeaderTitleFont = UIFont(name: "Helvetica-Bold", size: 20)
	static var sectionHeaderTitleColor = UIColor.white
	static var sectionHeaderBackgroundColor = UIColor.black
	static var sectionHeaderBackgroundColorHighlighted = UIColor.gray
	static var secionHeaderNavigationBarColor = UIColor.darkGray
	static var sectionHeaderAlpha: Float = 1.0
	
	static func diarythemeLight(){
		UserDefaults.standard.set("Light Theme", forKey: "theme")
		sectionHeaderTitleFont = UIFont(name: "Helvetica", size: 18)
		sectionHeaderTitleColor = UIColor.black
		sectionHeaderBackgroundColor = UIColor.white
		secionHeaderNavigationBarColor = UIColor.white
		sectionHeaderBackgroundColorHighlighted = UIColor.lightText
		sectionHeaderAlpha = 0.8
	}
	static func diarythemeNight(){
		UserDefaults.standard.set("Dark Theme", forKey: "theme")
		sectionHeaderTitleFont = UIFont(name: "Helvetica", size: 18)
		sectionHeaderTitleColor = UIColor.white
		sectionHeaderBackgroundColor = UIColor.darkGray
		secionHeaderNavigationBarColor = UIColor.darkGray
		sectionHeaderBackgroundColorHighlighted = UIColor.gray
		sectionHeaderAlpha = 0.8
	}
	static let availableThemes = ["Light Theme", "Dark Theme"]
	static func loadTheme(){
		let defaults = UserDefaults.standard
		if let name = defaults.string(forKey: "theme"){
			// Select the Theme
			if name == "Light Theme"	{ diarythemeLight()	}
			if name == "Dark Theme" 	{ diarythemeNight()	}
		}else{
			defaults.set("Light Theme", forKey: "theme")
			diarythemeLight()
		}
	}
}
