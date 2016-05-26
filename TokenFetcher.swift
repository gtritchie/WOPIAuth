import Foundation

/**
	Perform a POST to the token exchange endpoint, following oauth2 standards.
*/
class TokenFetcher {
	
	// MARK: Properties
	
	private var tokenUrlString: String
	private var clientId: String
	private var clientSecret: String
	private var authCode: String
	private var redirectUri: String
	private var sessionContext: String
	
	private let session: NSURLSession
	
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
	
	init(tokenUrl: String, clientId: String, clientSecret: String, authCode: String, redirectUri: String, sessionContext: String) {
		tokenUrlString = tokenUrl
		self.clientId = clientId
		self.clientSecret = clientSecret
		self.authCode = authCode
		self.redirectUri = redirectUri
		self.sessionContext = sessionContext
		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
		session = NSURLSession(configuration: config)
	}

	func errorWithMessage(localizedDescription: String) -> NSError {
		WOPIAuthLogError(localizedDescription)
		return NSError(domain: "Token Exchange", code: 1, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
	}
	
	func fetchTokensUsingCompletionHandler(completionHandler: FetchTokenResult -> Void) {
		guard let url = NSURL(string: tokenUrlString) else {
			let result: FetchTokenResult = .Failure(errorWithMessage("Malformed token endpoint URL: \"\(tokenUrlString)\""))
			completionHandler(result)
			return
		}
		
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

		// Set POST body
		var postParams = [String : String]()
		postParams["client_id"] = clientId
		postParams["client_secret"] = clientSecret
		postParams["code"] = authCode
		postParams["grant_type"] = "authorization_code"
		postParams["redirect_uri"] = redirectUri

		let postString = formEncodedQueryStringFor(postParams)

		WOPIAuthLogInfo("Invoking token endpoint via POST: \"\(tokenUrlString)\"")
		WOPIAuthLogInfo("POST body=\(postString)")

		guard let encoded = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) else {
			WOPIAuthLogError("Unable to encode Token POST body")
			let result: FetchTokenResult = .Failure(errorWithMessage("Unable to encode Token POST body"))
			completionHandler(result)
			return
		}
		
		request.HTTPBody = encoded

		let task = session.dataTaskWithRequest(request) { data, response, error in
			let result: FetchTokenResult
			
			do {
				let info = try TokenResult.createFromResponse(data, response: response, error: error)
				result = FetchTokenResult { info }
			}
			catch let error as NSError {
				result = .Failure(error)
			}
			catch {
				result = .Failure(self.errorWithMessage("Unexpected exception from token parser"))
			}
			NSOperationQueue.mainQueue().addOperationWithBlock {
				completionHandler(result)
			}
		}
		task.resume()
	}

}
