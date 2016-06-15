//
//  LoggingSenderTests.swift
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

import XCTest
@testable import WOPIAuth

class LoggingReceiver: NSObject {

	var message = ""
	var gotNotified = false
	var gotError = false
	var gotWarning = false
	
	override init() {
		super.init()

		let notificationCenter = NSNotificationCenter.defaultCenter()
		notificationCenter.addObserver(self, selector: #selector(self.didReceiveLogLineNotification(_:)), name: LogLineNotification, object: nil)
	}
	
	func didReceiveLogLineNotification(note: NSNotification) {

		guard let userInfo = note.userInfo as! [String: String]? else {
			return
		}
		
		guard let msg = userInfo[LogLineNotificationMessageKey] else {
			return
		}
		message = msg
		
		if userInfo[LogLineNotificationIsErrorKey] != nil {
			gotError = true
		} else if userInfo[LogLineNotificationIsWarningKey] != nil {
			gotWarning = true
		}
	}
}

class LoggingSenderTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testLogInfo() {
		let message = "hello world"
		let receiver = LoggingReceiver()
		
		WOPIAuthLogInfo(message)
		
		XCTAssert(receiver.message == message)
		XCTAssert(receiver.gotError == false)
		XCTAssert(receiver.gotWarning == false)
	}
	
	func testLogError() {
		let message = "goodbye cruel world"
		let receiver = LoggingReceiver()
		
		WOPIAuthLogError(message)
		
		XCTAssert(receiver.message == message)
		XCTAssert(receiver.gotError == true)
		XCTAssert(receiver.gotWarning == false)
	}
	
	func testLogWarning() {
		let message = "I guess it's not so bad."
		let receiver = LoggingReceiver()
		
		WOPIAuthLogWarning(message)
		
		XCTAssert(receiver.message == message)
		XCTAssert(receiver.gotError == false)
		XCTAssert(receiver.gotWarning == true)
	}
	
	func testLogNSError() {
		let message = "Doom and more doom!"
		let receiver = LoggingReceiver()

		let error = NSError(domain: "gloom", code: 2, userInfo: [NSLocalizedDescriptionKey: message])
		WOPIAuthLogNSError(error)
		
		XCTAssert(receiver.message == message)
		XCTAssert(receiver.gotError == true)
		XCTAssert(receiver.gotWarning == false)
	}

}
