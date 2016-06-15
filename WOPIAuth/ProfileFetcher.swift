//
//  ProfileFetcher.swift
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
	Perform an authenticated GET to the profile endpoint.
*/
class ProfileFetcher : Fetcher {
	
	// MARK: Properties
	
	private var accessToken: String
	private var sessionContext: String
	
	/// Used to return results from async call
	enum FetchProfileResult {
		case Success(ProfileResult)
		case Failure(NSError)
		
		init(throwingClosure: () throws -> ProfileResult) {
			do {
				let profileInfo = try throwingClosure()
				self = .Success(profileInfo)
			}
			catch {
				self = .Failure(error as NSError)
			}
		}
	}
	
	// MARK: Life Cycle
	
	init(profileUrl: NSURL, accessToken: String, sessionContext: String) {
		self.accessToken = accessToken
		self.sessionContext = sessionContext
		super.init(url: profileUrl, errorDomain: "Profile")
	}
	
	func fetchProfileUsingCompletionHandler(completionHandler: FetchProfileResult -> Void) {
		
		let request = NSMutableURLRequest(URL: url)
		
		request.HTTPMethod = "GET"
		
		// Set headers
		// TODO: request.setValue(correlationId, forHTTPHeaderField: "X-CorrelationId")
		request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
		if !sessionContext.isEmpty {
			request.setValue(sessionContext, forHTTPHeaderField: "X-WOPI-SessionContext")
		}
		request.setValue("Microsoft Office Identity Service", forHTTPHeaderField: "user-agent")
		
		let authValue = "Bearer \(accessToken)"
		request.setValue(authValue, forHTTPHeaderField: "Authorization")
		request.HTTPShouldHandleCookies = false
		
		WOPIAuthLogInfo("Invoking profile endpoint via GET: \"\(url.absoluteString)\"")

		task = session.dataTaskWithRequest(request) { data, response, error in
			let result: FetchProfileResult
			
			do {
				let info = try ProfileResult.createFromResponse(data, response: response, error: error)
				result = FetchProfileResult { info }
			}
			catch let error as NSError {
				if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
					// user canceled, don't invoke completion handler
					return
				}
				result = .Failure(error)
			}
			catch {
				WOPIAuthLogError("Unexpected exception from token parser")
				result = .Failure(self.errorWithMessage("Unable to parse response body"))
			}
			NSOperationQueue.mainQueue().addOperationWithBlock {
				completionHandler(result)
			}
		}
		task!.resume()
	}
}
