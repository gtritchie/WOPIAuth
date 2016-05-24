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
			let error = errorWithCode(1, localizedDescription: String(format: NSLocalizedString("Malformed bootstrapper URL: %@", comment: ""), urlString))
			let result: FetchBootstrapResult = .Failure(error)
			completionHandler(result)
			return
		}
		
		let request = NSMutableURLRequest(URL: url)
		// TODO make this a preferences setting
		request.setValue("Word/1.22.16051600 CFNetwork/758.2.8 Darwin/15.4.0", forHTTPHeaderField: "User-Agent")
		request.HTTPShouldHandleCookies = false

		WOPIAuthLogInfo(String(format: NSLocalizedString("Invoking bootstrapper: %@", comment: ""), urlString))
		let task = session.dataTaskWithRequest(request) { data, response, error in
			let result: FetchBootstrapResult
			if data != nil {
				if let response = response as? NSHTTPURLResponse {
					if response.statusCode == 401 {
						
						if let authHeader = response.allHeaderFields["WWW-Authenticate"] as? String {
							let info = BootstrapInfo()
							if info.populateFromAuthenticateHeader(authHeader) == true {
								result = FetchBootstrapResult { info }
							} else {
								let error = self.errorWithCode(1, localizedDescription:
									String(format: NSLocalizedString("Unable to parse WWW-Authenticate header: \"%@\"", comment: ""), authHeader))
								result = .Failure(error)
							}
						} else {
							let error = self.errorWithCode(1, localizedDescription: NSLocalizedString("No WWW-Authenticate header on response", comment: ""))
							result = .Failure(error)
						}
					} else {
						let error = self.errorWithCode(1, localizedDescription: String(format: NSLocalizedString("Non-401 status code: %d", comment: ""),
							response.statusCode))
						result = .Failure(error)
					}
				} else {
					let error = self.errorWithCode(1, localizedDescription: NSLocalizedString("App Issue: Unexpected response object", comment: ""))
					result = .Failure(error)
				}
			} else {
				WOPIAuthLogError(NSLocalizedString("Unable to make call to bootstrapper", comment: ""))
				result = .Failure(error!)
			}
			NSOperationQueue.mainQueue().addOperationWithBlock {
				completionHandler(result)
			}
		}
		task.resume()
	}
}