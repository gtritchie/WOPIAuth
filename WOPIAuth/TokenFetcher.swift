//
//  TokenFetcher.swift
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
	Perform a POST to the token exchange endpoint, following oauth2 standards.
*/
class TokenFetcher: Fetcher {
	
	// MARK: Properties
	
	private var clientId: String
	private var clientSecret: String
	private var authCode: String
	private var sessionContext: String
	private var redirectUri: String
	
	/// Used to return results from async call
	enum FetchTokenResult {
		case Success(TokenResult)
		case Failure(NSError)
		
		init(throwingClosure: () throws -> TokenResult) {
			do {
				let tokenInfo = try throwingClosure()
				self = .Success(tokenInfo)
			}
			catch {
				self = .Failure(error as NSError)
			}
		}
	}
	
	// MARK: Life Cycle
	
	init(tokenURL: NSURL, clientId: String, clientSecret: String, authCode: String, sessionContext: String, redirectUri: String) {
		self.clientId = clientId
		self.clientSecret = clientSecret
		self.authCode = authCode
		self.sessionContext = sessionContext
		self.redirectUri = redirectUri
		super.init(url: tokenURL, errorDomain: "Token Exchange")
	}

	func fetchTokensUsingCompletionHandler(forRefresh refresh: Bool, completionHandler: FetchTokenResult -> Void) {
		let request = NSMutableURLRequest(URL: url)
		
		request.HTTPMethod = "POST"

		// Set headers
		// TODO: request.setValue(correlationId, forHTTPHeaderField: "X-CorrelationId")
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
		if !sessionContext.isEmpty {
			request.setValue(sessionContext, forHTTPHeaderField: "X-WOPI-SessionContext")
		}
		request.setValue("Microsoft Office Identity Service", forHTTPHeaderField: "user-agent")
		request.HTTPShouldHandleCookies = false

		// Set LOGGING POST body (remove sensitive information)
		var loggingPostParams = [String : String]()
		loggingPostParams["client_id"] = clientId
		loggingPostParams["client_secret"] = "***"
		if refresh {
			loggingPostParams["refresh_token"] = authCode
		} else {
			loggingPostParams["code"] = authCode
		}
		if refresh {
			loggingPostParams["grant_type"] = "refresh_token"
		} else {
			loggingPostParams["grant_type"] = "authorization_code"
			loggingPostParams["redirect_uri"] = redirectUri
		}
		let loggingPostString = formEncodedQueryStringFor(loggingPostParams)
		
		// Set POST body
		var postParams = [String : String]()
		postParams["client_id"] = clientId
		postParams["client_secret"] = clientSecret
		if refresh {
			postParams["refresh_token"] = authCode
		} else {
			postParams["code"] = authCode
		}
		if refresh {
			postParams["grant_type"] = "refresh_token"
		} else {
			postParams["grant_type"] = "authorization_code"
			postParams["redirect_uri"] = redirectUri
		}
		let postString = formEncodedQueryStringFor(postParams)

		WOPIAuthLogInfo("Invoking token endpoint via POST: \"\(url.absoluteString)\"")
		WOPIAuthLogInfo("POST body=\(loggingPostString)")

		guard let encoded = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) else {
			WOPIAuthLogError("Unable to encode Token POST body")
			let result: FetchTokenResult = .Failure(errorWithMessage("Unable to encode Token POST body"))
			completionHandler(result)
			return
		}
		
		request.HTTPBody = encoded

		task = session.dataTaskWithRequest(request) { data, response, error in
			let result: FetchTokenResult
			
			do {
				let info = try TokenResult.createFromResponse(data, response: response, error: error)
				result = FetchTokenResult { info }
			}
			catch let error as NSError {
				if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
					// user canceled, don't invoke completion handler
					return
				}
				result = .Failure(error)
			}
			catch {
				result = .Failure(self.errorWithMessage("Unexpected exception from token parser"))
			}
			NSOperationQueue.mainQueue().addOperationWithBlock {
				completionHandler(result)
			}
		}
		task!.resume()
	}

}
