//
//  ModelInfo.swift
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
	`ModelInfo` is abstract base class for model classes.
*/
class ModelInfo: NSObject {

	// MARK: Properties
	
	/// Domain for thrown validation errors
	let validationDomain = "UserInputValidationErrorDomain"
	
	/// Error code for thrown validation errors
	let validationCode = 0
	
	// MARK: Validation

	/**
		Return a non-empty `String`.
		- Parameter str: Optional `String` to examine and return.
		- Parameter errorMessage: Localized message included in thrown `NSError`.
		- Throws: `NSError` if `str` parameter is nil or empty.
		- Returns: A non-empty `String`
	*/
	func getNonEmptyString(str: String?, errorMessage: String) throws -> String {
		if var str = str {
			str = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
			if !str.isEmpty {
				return str
			}
		}
		
		let userInfo = [NSLocalizedDescriptionKey : errorMessage]
		throw NSError(domain: validationDomain, code: validationCode, userInfo: userInfo)
	}
	
	/**
		Create an `NSURLComponents` object.
		- Parameter urlStr: `String` potentially containing a URL.
		- Parameter errorMessage: Localized message included in thrown `NSError`.
		- Throws: `NSError` if `urlStr` parameter is not a valid URL.
		- Returns: A new `NSURLComponents` object.
	*/
	func getValidURLComponents(urlStr: String, errorMessage: String) throws -> NSURLComponents {
		guard let url = NSURLComponents(string: urlStr) else {
			let userInfo = [NSLocalizedDescriptionKey : errorMessage]
			throw NSError(domain: validationDomain, code: validationCode, userInfo: userInfo)
		}
		return url
	}
	
	/**
		Verify that an `NSURLComponents` object has the https scheme.
		- Parameter url: The URL to examine.
		- Parameter errorMessage: Localized message to include in thrown `NSError`.
		- Throws: `NSError` with supplied error message if object does not have https scheme.
	*/
	func verifyUrlSchemeHttps(url: NSURLComponents, errorMessage: String) throws {
		guard url.scheme == "https" else {
			let userInfo = [NSLocalizedDescriptionKey : errorMessage]
			throw NSError(domain: validationDomain, code: validationCode, userInfo: userInfo)
		}
	}
	
	/**
		Validate contents of `ModelInfo` object.
		- Throws: NSError for first problem found.
		- Note: Must be overriden by child class to perform actual validation.
	*/
	func validate() throws {
	}
	
	/**
		Non-throwing convenience method for automation.
		- Returns: `True` if object is valid, `False` if invalid.
	*/
	func nonThrowValidate() -> Bool {
		do {
			try validate()
		} catch {
			return false
		}
		return true
	}
}
