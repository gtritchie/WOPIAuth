import Foundation

public enum TokenExchangeError: ErrorType {
	case NSError(Foundation.NSError)
}

/**
	Perform a POST to the token exchange endpoint, following oauth2 standards.
*/
public class TokenFetcher {
	
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

	func errorWithCode(code: Int, localizedDescription: String) -> NSError {
		WOPIAuthLogError(localizedDescription)
		return NSError(domain: "Token Exchange", code: code, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
	}
	
	func fetchTokensUsingCompletionHandler(completionHandler: FetchTokenResult -> Void) {
		guard let url = NSURL(string: tokenUrlString) else {
			let error = errorWithCode(1, localizedDescription: "Malformed token endpoint URL: \"\(tokenUrlString)\"")
			let result: FetchTokenResult = .Failure(error)
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
			let error = errorWithCode(1, localizedDescription: "Unable to encode Token POST body")
			let result: FetchTokenResult = .Failure(error)
			completionHandler(result)
			return
		}
		
		request.HTTPBody = encoded

		let task = session.dataTaskWithRequest(request) { data, response, error in
			let result: FetchTokenResult
			
			do {
				let info = try self.handleTokenResponse(data, response: response, error: error)
				result = FetchTokenResult { info }
			}
			catch TokenExchangeError.NSError(let error) {
				result = .Failure(error)
			}
			catch {
				WOPIAuthLogError("Expected exception from token parser")
				let error = self.errorWithCode(1, localizedDescription: "Unable to parse response body")
				result = .Failure(error)
			}
			NSOperationQueue.mainQueue().addOperationWithBlock {
				completionHandler(result)
			}
		}
		task.resume()
	}
	
	func handleTokenResponse(data: NSData?, response: NSURLResponse?, error: NSError?) throws -> TokenResult {
		guard let data = data else {
			WOPIAuthLogError("Unable to make call to token endpoint")
			throw TokenExchangeError.NSError(error!)
		}

		guard let response = response as? NSHTTPURLResponse else {
			logErrorBody(data)
			let error = self.errorWithCode(1, localizedDescription: "App Issue: Unexpected response object")
			throw TokenExchangeError.NSError(error)
		}

		guard response.statusCode == 200 else {
			logErrorBody(data)
			let error = self.errorWithCode(1, localizedDescription: "Token endpoint responsed with \(response.statusCode)")
			throw TokenExchangeError.NSError(error)
		}

		let info = TokenResult()
		guard info.populateFromResponseData(data) == true else {
			logErrorBody(data)
			let error = self.errorWithCode(1, localizedDescription: "Unable to parse response body")
			throw TokenExchangeError.NSError(error)
		}
		
		return info
	}
	
	func logErrorBody(data: NSData) {
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
