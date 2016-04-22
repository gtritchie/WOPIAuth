//
//  LogViewController.swift
//  WOPIAuth
//
//  Created by Gary Ritchie on 4/22/16.
//  Copyright © 2016 Gary Ritchie. All rights reserved.
//

import Cocoa

class LogViewController: NSViewController {

	// MARK: Properties
	
	dynamic var log: NSAttributedString = NSAttributedString(string: "")
	
	// MARK: Outlets
	
	@IBOutlet var textView: NSTextView!
	
	
	// MARK: Life Cycle
	
	override func viewDidLoad() {
        super.viewDidLoad()

		let notificationCenter = NSNotificationCenter.defaultCenter()
		notificationCenter.addObserver(self, selector: #selector(self.didReceiveLogLineNotification(_:)), name: LogLineNotification, object: nil)
    }
	
	// MARK: Notifications
	
	func didReceiveLogLineNotification(note: NSNotification) {
		let mutableLog = log.mutableCopy() as! NSMutableAttributedString
		if log.length > 0 {
			mutableLog.appendAttributedString(NSAttributedString(string: "\n"))
		}
		
		let userInfo = note.userInfo! as! [String: String]
		let message = userInfo[LogLineNotificationMessageKey]!
		let logLine = NSAttributedString(string: message)
		mutableLog.appendAttributedString(logLine)
		
		log = mutableLog.copy() as! NSAttributedString
		
		textView.scrollRangeToVisible(NSRange(location: log.length, length: 0))
	}
}
