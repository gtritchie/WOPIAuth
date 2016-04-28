//import Foundation
//
///**
//	Prompt and return auth_code and optional post-auth token endpoint and/or session context.
//*/
//
//public class SignInFetcher: NSObject {
//	
//	// MARK: Properties
//	
//	private var signInUrlString: String
//	private var redirUrlString: String
//	private var redirUrl: NSURL?
//	private var clientInfo: ClientInfo
//	private let session: NSURLSession
//
//	/// Used to return results from async call
//	enum FetchAuthResult {
//		case Success(AuthResult)
//		case Failure(NSError)
//		
//		init(throwingClosure: () throws -> AuthResult) {
//			do {
//				let authResult = try throwingClosure()
//				self = .Success(authResult)
//			}
//			catch {
//				self = .Failure(error as NSError)
//			}
//		}
//	}
//	
//	
//	// MARK: Life Cycle
//	
//	init(signInUrl: String, redirUrl: String, client: ClientInfo) {
//		signInUrlString = signInUrl
//		redirUrlString = redirUrl
//		clientInfo = client
//		
//		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
//		session = NSURLSession(configuration: config)
//	}
//	
//	func errorWithCode(code: Int, localizedDescription: String) -> NSError {
//		WOPIAuthLogError(localizedDescription)
//		return NSError(domain: "SignIn", code: code, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
//	}
//	
//	func fetchAuthResultUsingCompletionHandler(completionHandler: FetchAuthResult -> Void) {
//		guard let url = NSURL(string: signInUrlString) else {
//			let error = errorWithCode(1, localizedDescription: "Malformed signIn URL: \"\(signInUrlString)\"")
//			let result: FetchAuthResult = .Failure(error)
//			completionHandler(result)
//			return
//		}
//		
//		guard let redirUrl = NSURL(string: redirUrlString) else {
//			let error = errorWithCode(1, localizedDescription: "Malformed redir URL: \"\(redirUrlString)\"")
//			let result: FetchAuthResult = .Failure(error)
//			completionHandler(result)
//			return
//		}
//		
//		let request = NSURLRequest(URL: url)
//		WOPIAuthLogInfo("Invoking signin page: \"\(signInUrlString)\"")
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
//		print("End of fetch call")
//	}
//}