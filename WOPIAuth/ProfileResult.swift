//
//  ProfileResult.swift
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

/**
	`ProfileResult` contains results from successful profile call. The
	profile is obtained with an authenticated call to the bootstrapper.
*/
class ProfileResult {
	var userId: String = ""
	var signInName: String = ""
	var friendlyName: String = ""
	
	/**
		Create a `ProfileResult` by parsing response, or throw an error.
	*/
	static func createFromResponse(data: NSData?, response: NSURLResponse?, error: NSError?) throws -> ProfileResult {
		if let error = error {
			throw error
		}
		guard let data = data else {
			throw errorWithMessage("Unable to get data from profile response")
		}
		
		guard let response = response as? NSHTTPURLResponse else {
			logErrorBody(data)
			throw errorWithMessage("App Issue: Unexpected response object")
		}
		
		guard response.statusCode == 200 else {
			logErrorBody(data)
			throw self.errorWithMessage("Bootstrapper profile endpoint responded with \(response.statusCode)")
		}
		
		let info = ProfileResult()
		try info.populateFromResponseData(data)
		return info
	}
	
	
	/**
		Parse JSON response from profile endpoint
	*/
	func populateFromResponseData(data: NSData) throws {
		let topLevelDict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
		guard let id = topLevelDict["UserId"] as? String else {
			throw ProfileResult.errorWithMessage("Unable to extract userId")
		}
		guard !id.isEmpty else {
			throw TokenResult.errorWithMessage("Empty UserId")
		}
		
		let name = topLevelDict["SignInName"] as? String
		let friendly = topLevelDict["UserFriendlyName"] as? String
		
		userId = id
		if name != nil {
			signInName = name!
		}
		if friendly != nil {
			friendlyName = friendly!
		}
	}
	
	/// Return an `NSError` object with message
	static func errorWithMessage(localizedDescription: String) -> NSError {
		return NSError(domain: "Profile Result", code: 1, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
	}

	static func logErrorBody(data: NSData) {
		WOPIAuthLogError("Profile call unsuccessful. Body of response follows.")
		if data.length == 0 {
			WOPIAuthLogError("<no response body>")
			return
		}
		
		if let body = NSString(data: data, encoding: NSUTF8StringEncoding) {
			WOPIAuthLogError(body as String)
		}
	}

}
