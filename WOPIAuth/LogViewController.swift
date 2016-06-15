//
//  LogViewController.swift
//  WOPIAuth
//
//  Copyright 2016 Gary Ritchie
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Cocoa

/// ViewController for the logging view
class LogViewController: NSViewController {

	// MARK: Properties
	
	dynamic var log: NSAttributedString = NSAttributedString(string: "")
	
	private static var RFC3339DateFormatter: NSDateFormatter?
	private var logObserver: NSObjectProtocol?

	// MARK: Outlets
	
	@IBOutlet var textView: NSTextView!
	
	// MARK: Actions
	
	@IBAction func clearLog(sender: AnyObject) {
		log = NSAttributedString()
	}
	
	// MARK: Life Cycle
	
	override func viewDidLoad() {
        super.viewDidLoad()

		let notificationCenter = NSNotificationCenter.defaultCenter()
		self.logObserver = notificationCenter.addObserverForName(LogLineNotification, object: nil, queue: nil) { note in
			self.performSelectorOnMainThread(#selector(self.didReceiveLogLineNotification(_:)), withObject: note, waitUntilDone: true)
		}
    }

	deinit {
		if let observer = self.logObserver {
			let notificationCenter = NSNotificationCenter.defaultCenter()
			notificationCenter.removeObserver(observer)
		}
	}
	
	// MARK: Notifications
	
	/**
		Append a message, including current date and time, to `log` property.
		If the error attribute was set, make the text red.
	*/
	func didReceiveLogLineNotification(note: NSNotification) {

		// Extract string and optional error flag from the notification and build
		// our formatted logging string
		let userInfo = note.userInfo! as! [String: String]
		let message = userInfo[LogLineNotificationMessageKey]!

		var messageFormat: String
		var isError = false
		var isWarning = false
		if userInfo[LogLineNotificationIsErrorKey] != nil {
			messageFormat = NSLocalizedString("%1@: ERROR: %2$@", comment: "Date: error message")
			isError = true
		} else if userInfo[LogLineNotificationIsWarningKey] != nil {
			messageFormat = NSLocalizedString("%1@: WARNING: %2$@", comment: "Date: warning message")
			isWarning = true
		} else {
			messageFormat = NSLocalizedString("%1$@: %2$@", comment: "Date: message")
		}

		let logLine = NSMutableAttributedString(string: String(format: messageFormat, LogViewController.getCurrentTime(),
			message))
		if isError {
			logLine.addAttribute(NSForegroundColorAttributeName,
			                     value: NSColor.redColor(),
			                     range: NSRange(0..<logLine.length))
		} else if isWarning {
			logLine.addAttribute(NSForegroundColorAttributeName,
			                     value: NSColor.brownColor(),
			                     range: NSRange(0..<logLine.length))
		}

		// Add the string and scroll the textview to show it
		let mutableLog = log.mutableCopy() as! NSMutableAttributedString
		if log.length > 0 {
			mutableLog.appendAttributedString(NSAttributedString(string: "\n"))
		}
		mutableLog.appendAttributedString(logLine)
		log = mutableLog.copy() as! NSAttributedString
		
		textView.scrollRangeToVisible(NSRange(location: log.length, length: 0))
	}
	
	// MARK: Helpers
	
	/// Return current time as an RFC3339 formatted string
	private static func getCurrentTime() -> String {
		if RFC3339DateFormatter == nil {
			RFC3339DateFormatter = NSDateFormatter()
			RFC3339DateFormatter!.locale = NSLocale(localeIdentifier: "en_US_POSIX")
			RFC3339DateFormatter!.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
			RFC3339DateFormatter!.timeZone = NSTimeZone(forSecondsFromGMT: 0)
		}
		return RFC3339DateFormatter!.stringFromDate(NSDate())
	}
}

//