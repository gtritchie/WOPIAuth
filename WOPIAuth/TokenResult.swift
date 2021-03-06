//
//  TokenResult.swift
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
	`TokenResult` contains results from successful token exchange.
*/
class TokenResult {
	var accessToken: String = ""
	var tokenExpiration: Int32 = 0
	var refreshToken: String = ""
	
	/**
		Create a TokenResult by parsing response, or throw an error.
	*/
	static func createFromResponse(data: NSData?, response: NSURLResponse?, error: NSError?) throws -> TokenResult {
		if let error = error {
			throw error;
		}
		guard let data = data else {
			throw errorWithMessage("Unable to get data from token response")
		}
		
		guard let response = response as? NSHTTPURLResponse else {
			logErrorBody(data)
			throw errorWithMessage("App Issue: Unexpected response object")
		}
		
		guard response.statusCode == 200 else {
			logErrorBody(data)
			throw self.errorWithMessage("Token endpoint responded with \(response.statusCode)")
		}
		
		let info = TokenResult()
		try info.populateFromResponseData(data)
		return info
	}
	

	///	Parse JSON response from token endpoint
	func populateFromResponseData(data: NSData) throws {
		let topLevelDict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
		guard let token = topLevelDict["access_token"] as? String else {
			throw TokenResult.errorWithMessage("Unable to extract access_token")
		}
		guard !token.isEmpty else {
			throw TokenResult.errorWithMessage("Empty access_token")
		}
		
		guard let tokenType = topLevelDict["token_type"] as? String else {
			throw TokenResult.errorWithMessage("No token_type")
		}
		WOPIAuthLogInfo("Token type = \"\(tokenType)\"")
		
		let expiration = topLevelDict["expires_in"] as? NSNumber
		let refresh = topLevelDict["refresh_token"] as? String
		
		accessToken = token
		WOPIAuthLogInfo("Access token received")
		if expiration != nil {
			WOPIAuthLogInfo("Expiration time received")
			tokenExpiration = expiration!.intValue
		}
		if refresh != nil {
			WOPIAuthLogInfo("Refresh token received")
			refreshToken = refresh!
		}
	}
	
	/// Return an `NSError` object with message
	static func errorWithMessage(localizedDescription: String) -> NSError {
		return NSError(domain: "Token Result", code: 1, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
	}

	static func logErrorBody(data: NSData) {
		WOPIAuthLogError("Token call unsuccessful. Body of response follows.")
		if data.length == 0 {
			WOPIAuthLogError("<no response body>")
			return
		}
		
		if let body = NSString(data: data, encoding: NSUTF8StringEncoding) {
			WOPIAuthLogError(body as String)
		}
	}

}
