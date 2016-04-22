
import Cocoa

/// Notification used to log a line of text
let LogLineNotification = "com.microsoft.office.WOPIAuth.LogLineNotification"
let LogLineNotificationMessageKey = "com.microsoft.office.WOPIAuth.LogLineNotificationMsgKey"

/**
	Log one line of text.
*/
func WOPIAuthLog(lineOfText: String) {
	let notificationCenter = NSNotificationCenter.defaultCenter()
	let userInfo = [LogLineNotificationMessageKey : lineOfText]
	notificationCenter.postNotificationName(LogLineNotification, object: nil, userInfo: userInfo)
}
