//
//  Fetcher.swift
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

/// Base class for async HTTP calls
class Fetcher {
	
	var url: NSURL
	let session: NSURLSession
	var task: NSURLSessionDataTask?
	var errorDomain: String
	
	init(url: NSURL, errorDomain: String) {
		self.url = url
		self.errorDomain = errorDomain
		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
		session = NSURLSession(configuration: config)
	}
	
	/// Cancel an in-progress request. The completion handler may still be invoked,
	/// check for error code of `NSURLErrorCancelled`.
	func cancel() {
		if task != nil {
			task!.cancel()
			task = nil
		}
	}
	
	func errorWithMessage(localizedDescription: String) -> NSError {
		return NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
	}

}
