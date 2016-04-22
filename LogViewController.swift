import Cocoa

/// ViewController for the logging view
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
	
	/**
		Append a message, including current date and time, to `log` property.
		If the error attribute was set, make the text red.
	*/
	func didReceiveLogLineNotification(note: NSNotification) {
		let mutableLog = log.mutableCopy() as! NSMutableAttributedString
		if log.length > 0 {
			mutableLog.appendAttributedString(NSAttributedString(string: "\n"))
		}

		let userInfo = note.userInfo! as! [String: String]
		let message = userInfo[LogLineNotificationMessageKey]!

		var messageFormat: String
		var isError = false
		if userInfo[LogLineNotificationIsErrorKey] != nil {
			messageFormat = NSLocalizedString("%1@: ERROR: %2$@", comment: "Date: error message")
			isError = true
		} else {
			messageFormat = NSLocalizedString("%1$@: %2$@", comment: "Date: message")
		}

		let now = NSDate()
		let RFC3339DateFormatter = NSDateFormatter()
		RFC3339DateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
		RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
		RFC3339DateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
		let logTime = RFC3339DateFormatter.stringFromDate(now)
		
		let fullPlainLine = String(format: messageFormat, logTime, message)

		let logLine = NSMutableAttributedString(string: fullPlainLine)
		if isError {
			logLine.addAttribute(NSForegroundColorAttributeName,
			                     value: NSColor.redColor(),
			                     range: NSRange(0..<logLine.length))
		}

		mutableLog.appendAttributedString(logLine)
		log = mutableLog.copy() as! NSAttributedString
		
		textView.scrollRangeToVisible(NSRange(location: log.length, length: 0))
	}
}

//