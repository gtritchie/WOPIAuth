import Foundation

/**
	Perform an unauthenticated call to the bootstrapper URL, and 
	obtain the required properties from the response. A successful call will
	respond with 401, and a WWW-Authenticate header of this form:

	WWW-Authenticate: Bearer authorization_uri="https://contoso.com/api/oauth2/authorize",tokenIssuance_uri="https://contoso.com/api/oauth2/token"
*/
public class BootstrapFetcher {
	
	// MARK: Properties
	
	/// Url of the bootstrapper
	private var urlString: String
	
	private let session: NSURLSession

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
	
	init(url: String) {
		urlString = url
		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
		session = NSURLSession(configuration: config)
	}
	
	func errorWithCode(code: Int, localizedDescription: String) -> NSError {
		WOPIAuthLogError(localizedDescription)
		return NSError(domain: "Bootstrapper", code: code, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
	}
	
	func fetchBootstrapInfoUsingCompletionHandler(completionHandler: FetchBootstrapResult -> Void) {
		guard let url = NSURL(string: urlString) else {
			let error = errorWithCode(1, localizedDescription: "Malformed bootstrapper URL: \"\(urlString)\"")
			let result: FetchBootstrapResult = .Failure(error)
			completionHandler(result)
			return
		}
		
		let request = NSMutableURLRequest(URL: url)
		// TODO make this a preferences setting
		request.setValue("Word/1.22.16051600 CFNetwork/758.2.8 Darwin/15.4.0", forHTTPHeaderField: "User-Agent")
		request.HTTPShouldHandleCookies = false

		WOPIAuthLogInfo("Invoking bootstrapper: \"\(urlString)\"")
		let task = session.dataTaskWithRequest(request) { data, response, error in
			let result: FetchBootstrapResult
			if let data = data {
				WOPIAuthLogInfo("Received \(data.length) bytes")
				if let response = response as? NSHTTPURLResponse {
					if response.statusCode == 401 {
						
						if let authHeader = response.allHeaderFields["WWW-Authenticate"] as? String {
							let info = BootstrapInfo()
							if info.populateFromAuthenticateHeader(authHeader) == true {
								result = FetchBootstrapResult { info }
							} else {
								let error = self.errorWithCode(1, localizedDescription: "Unable to parse WWW-Authenticate header: \"\(authHeader)\"")
								result = .Failure(error)
							}
						} else {
							let error = self.errorWithCode(1, localizedDescription: "No WWW-Authenticate header on response")
							result = .Failure(error)
						}
					} else {
						let error = self.errorWithCode(1, localizedDescription: "Non-401 status code: \(response.statusCode)")
						result = .Failure(error)
					}
				} else {
					let error = self.errorWithCode(1, localizedDescription: "App Issue: Unexpected response object")
					result = .Failure(error)
				}
			} else {
				WOPIAuthLogError("Unable to make call to bootstrapper")
				result = .Failure(error!)
			}
			NSOperationQueue.mainQueue().addOperationWithBlock {
				completionHandler(result)
			}
		}
		task.resume()
	}
}