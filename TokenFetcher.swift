import Foundation

/**
	Perform a POST to the token exchange endpoint, following oauth2 standards.
*/
public class TokenFetcher {
	
	// MARK: Properties
	
	private var tokenUrlString: String
	private var clientId: String
	private var clientSecret: String
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
	
	init(tokenUrl: String, clientId: String, clientSecret: String, sessionContext: String) {
		tokenUrlString = tokenUrl
		self.clientId = clientId
		self.clientSecret = clientSecret
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
		
		let request = NSURLRequest(URL: url)
		WOPIAuthLogInfo("Invoking token endpoint: \"\(tokenUrlString)\"")
		
		let tokenInfo = TokenResult()
		tokenInfo.accessToken = "accessToken"
		tokenInfo.tokenExpiration = 60
		tokenInfo.refreshToken = "refreshToken"
		let result: FetchTokenResult = .Success(tokenInfo)

//		let error = self.errorWithCode(1, localizedDescription: "App Issue: token call NYI")
//		let result: FetchTokenResult = .Failure(error)
		completionHandler(result)
		
//		let task = session.dataTaskWithRequest(request) { data, response, error in
//			let result: FetchBootstrapResult
//			if let data = data {
//				WOPIAuthLogInfo("Received \(data.length) bytes")
//				if let response = response as? NSHTTPURLResponse {
//					if response.statusCode == 401 {
//						
//						if let authHeader = response.allHeaderFields["WWW-Authenticate"] as? String {
//							let info = BootstrapInfo()
//							if info.populateFromAuthenticateHeader(authHeader) == true {
//								result = FetchBootstrapResult { info }
//							} else {
//								let error = self.errorWithCode(1, localizedDescription: "Unable to parse WWW-Authenticate header: \"\(authHeader)\"")
//								result = .Failure(error)
//							}
//						} else {
//							let error = self.errorWithCode(1, localizedDescription: "No WWW-Authenticate header on response")
//							result = .Failure(error)
//						}
//					} else {
//						let error = self.errorWithCode(1, localizedDescription: "Non-401 status code: \(response.statusCode)")
//						result = .Failure(error)
//					}
//				} else {
//					let error = self.errorWithCode(1, localizedDescription: "App Issue: Unexpected response object")
//					result = .Failure(error)
//				}
//			} else {
//				WOPIAuthLogError("Unable to make call to bootstrapper")
//				result = .Failure(error!)
//			}
//			NSOperationQueue.mainQueue().addOperationWithBlock {
//				completionHandler(result)
//			}
//		}
//		task.resume()
	}
}
