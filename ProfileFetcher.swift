import Foundation

/**
	Perform an authenticated GET to the profile endpoint.
*/
public class ProfileFetcher {
	
	// MARK: Properties
	
	private var profileUrlString: String
	private var accessToken: String
	private var sessionContext: String
	
	private let session: NSURLSession
	
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
	
	init(profileUrl: String, accessToken: String, sessionContext: String) {
		self.profileUrlString = profileUrl
		self.accessToken = accessToken
		self.sessionContext = sessionContext
		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
		session = NSURLSession(configuration: config)
	}
	
	func errorWithMessage(localizedDescription: String) -> NSError {
		WOPIAuthLogError(localizedDescription)
		return NSError(domain: "Profile fetch", code: 1, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
	}
	
	func fetchProfileUsingCompletionHandler(completionHandler: FetchProfileResult -> Void) {
		guard let url = NSURL(string: profileUrlString) else {
			let error = errorWithMessage("Malformed profile endpoint URL: \"\(profileUrlString)\"")
			let result: FetchProfileResult = .Failure(error)
			completionHandler(result)
			return
		}
		
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
		
		WOPIAuthLogInfo("Invoking profile endpoint via GET: \"\(profileUrlString)\"")

		let task = session.dataTaskWithRequest(request) { data, response, error in
			let result: FetchProfileResult
			
			do {
				let info = try ProfileResult.createFromResponse(data, response: response, error: error)
				result = FetchProfileResult { info }
			}
			catch let error as NSError {
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
		task.resume()
	}
}
