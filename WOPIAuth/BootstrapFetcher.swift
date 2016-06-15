//
//  BootstrapFetcher.swift
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
	Perform an unauthenticated call to the bootstrapper URL, and 
	obtain the required properties from the response. A successful call will
	respond with 401, and a WWW-Authenticate header of this form:

	WWW-Authenticate: Bearer authorization_uri="https://contoso.com/api/oauth2/authorize",tokenIssuance_uri="https://contoso.com/api/oauth2/token"
*/
class BootstrapFetcher: Fetcher {
	
	// MARK: Properties
	
	/// Used to return results from async call
	enum FetchBootstrapResult {
		case Success(BootstrapInfo)
		case Failure(NSError)
		
		init(throwingClosure: () throws -> BootstrapInfo) {
			do {
				let bootstrapInfo = try throwingClosure()
				self = .Success(bootstrapInfo)
			}
			catch {
				self = .Failure(error as NSError)
			}
		}
	}
	
	// MARK: Life Cycle
	
	required init(url: NSURL) {
		super.init(url: url, errorDomain: "Bootstrapper")
	}
	
	func fetchBootstrapInfoUsingCompletionHandler(completionHandler: FetchBootstrapResult -> Void) {

		let request = NSMutableURLRequest(URL: url)
		// TODO make this a preferences setting
		request.setValue("Word/1.22.16051600 CFNetwork/758.2.8 Darwin/15.4.0", forHTTPHeaderField: "User-Agent")
		request.HTTPShouldHandleCookies = false

		WOPIAuthLogInfo(String(format: NSLocalizedString("Invoking bootstrapper: %@", comment: ""), url.absoluteString))
		task = session.dataTaskWithRequest(request) { data, response, error in
			let result: FetchBootstrapResult
			if data != nil {
				if let response = response as? NSHTTPURLResponse {
					if response.statusCode == 401 {
						
						if let authHeader = response.allHeaderFields["WWW-Authenticate"] as? String {
							let info = BootstrapInfo()
							if info.populateFromAuthenticateHeader(authHeader) == true {
								result = FetchBootstrapResult { info }
							} else {
								let error = self.errorWithMessage(
									String(format: NSLocalizedString("Unable to parse WWW-Authenticate header: \"%@\"", comment: ""), authHeader))
								result = .Failure(error)
							}
						} else {
							let error = self.errorWithMessage(NSLocalizedString("No WWW-Authenticate header on response", comment: ""))
							result = .Failure(error)
						}
					} else {
						let error = self.errorWithMessage(String(format: NSLocalizedString("Non-401 status code: %d", comment: ""),
							response.statusCode))
						result = .Failure(error)
					}
				} else {
					let error = self.errorWithMessage(NSLocalizedString("App Issue: Unexpected response object", comment: ""))
					result = .Failure(error)
				}
			} else if let error = error {
				if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
					// canceled: don't call the completion handler
					return
				}
				result = .Failure(error)
			} else {
				WOPIAuthLogError(NSLocalizedString("Unable to make call to bootstrapper", comment: ""))
				result = .Failure(error!)
			}
			NSOperationQueue.mainQueue().addOperationWithBlock {
				completionHandler(result)
			}
		}
		task!.resume()
	}
}