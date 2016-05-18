import Foundation

public enum ProfileError: ErrorType {
	case NSError(Foundation.NSError)
}

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
	
	func errorWithCode(code: Int, localizedDescription: String) -> NSError {
		WOPIAuthLogError(localizedDescription)
		return NSError(domain: "Profile fetch", code: code, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
	}
	
	func fetchProfileUsingCompletionHandler(completionHandler: FetchProfileResult -> Void) {
		guard let url = NSURL(string: profileUrlString) else {
			let error = errorWithCode(1, localizedDescription: "Malformed profile endpoint URL: \"\(profileUrlString)\"")
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
				let info = try self.handleProfileResponse(data, response: response, error: error)
				result = FetchProfileResult { info }
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
	
	func handleProfileResponse(data: NSData?, response: NSURLResponse?, error: NSError?) throws -> ProfileResult {
		guard let data = data else {
			WOPIAuthLogError("Unable to make call to profile endpoint")
			throw ProfileError.NSError(error!)
		}
		
		guard let response = response as? NSHTTPURLResponse else {
			let error = self.errorWithCode(1, localizedDescription: "App Issue: Unexpected response object")
			throw ProfileError.NSError(error)
		}
		
		guard response.statusCode == 200 else {
			let error = self.errorWithCode(1, localizedDescription: "Profile endpoint responsed with \(response.statusCode)")
			throw ProfileError.NSError(error)
			
		}
		
		let info = ProfileResult()
		guard info.populateFromResponseData(data) == true else {
			let error = self.errorWithCode(1, localizedDescription: "Unable to parse profile response body")
			throw ProfileError.NSError(error)
		}
		
		return info
	}
}
