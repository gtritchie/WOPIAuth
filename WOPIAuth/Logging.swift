//
//  Logging.swift
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

import Foundation

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

/**
	Log an NSError as an error message
*/
func WOPIAuthLogNSError(error: NSError) {
	WOPIAuthLogError(error.localizedDescription)
}