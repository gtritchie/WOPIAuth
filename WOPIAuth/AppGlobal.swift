
import Cocoa

/// Notification used to log a line of text
let LogLineNotification = "com.microsoft.office.WOPIAuth.LogLineNotification"
let LogLineNotificationMessageKey = "com.microsoft.office.WOPIAuth.LogLineNotificationMsgKey"
let LogLineNotificationIsErrorKey = "com.microsoft.office.WOPIAuth.LogLineNotificationErrorKey"
let LogLineNotificationIsWarningKey = "com.microsoft.office.WOPIAuth.LogLineNotificationWarningKey"

/**
	Log one line of text.
*/
func WOPIAuthLogInfo(lineOfText: String) {
	let notificationCenter = NSNotificationCenter.defaultCenter()
	let userInfo = [LogLineNotificationMessageKey : lineOfText]
	notificationCenter.postNotificationName(LogLineNotification, object: nil, userInfo: userInfo)
}

/**
	Log one line of text as an error
*/
func WOPIAuthLogError(lineOfText: String) {
	let notificationCenter = NSNotificationCenter.defaultCenter()
	let userInfo = [LogLineNotificationMessageKey : lineOfText, LogLineNotificationIsErrorKey : "ErrorFlag"]
	notificationCenter.postNotificationName(LogLineNotification, object: nil, userInfo: userInfo)
}

/**
	Log one line of text as a warning
*/
func WOPIAuthLogWarning(lineOfText: String) {
	let notificationCenter = NSNotificationCenter.defaultCenter()
	let userInfo = [LogLineNotificationMessageKey : lineOfText, LogLineNotificationIsWarningKey : "WarningFlag"]
	notificationCenter.postNotificationName(LogLineNotification, object: nil, userInfo: userInfo)
}
