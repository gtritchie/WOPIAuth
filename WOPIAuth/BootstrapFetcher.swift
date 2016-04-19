import Foundation

/**
	Perform an unauthenticated call to the bootstrapper URL, and 
	obtain the required properties from the response.
*/
public class BootstrapFetcher {
	
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
	
	let session: NSURLSession
	
	public init() {
		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
		session = NSURLSession(configuration: config)
	}
	
	func errorWithCode(code: Int, localizedDescription: String) -> NSError {
		return NSError(domain: "ScheduleFetcher", code: code, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
	}
	
	
	func fetchBootstrapInfoUsingCompletionHandler(completionHandler: FetchBootstrapResult -> Void) {
		let urlString = "https://app.box.com/api/wopibootstrapper"
		let url = NSURL(string: urlString)!
		let request = NSURLRequest(URL: url)
		print("Calling \(urlString)")
		let task = session.dataTaskWithRequest(request) { data, response, error in
			let result: FetchBootstrapResult
			if let data = data {
				if let response = response as? NSHTTPURLResponse {
					print("\(data.length) bytes, HTTP \(response.statusCode).")
					if response.statusCode == 200 {
						result = FetchBootstrapResult { BootstrapInfo() }
					} else {
						let error = self.errorWithCode(1, localizedDescription: "Bad status code \(response.statusCode)")
						result = .Failure(error)
					}
				} else {
					let error = self.errorWithCode(1, localizedDescription: "Unexpected response object")
					result = .Failure(error)
				}
			} else {
				result = .Failure(error!)
			}
			NSOperationQueue.mainQueue().addOperationWithBlock {
				completionHandler(result)
			}
		}
		task.resume()
		print("End of fetch call")
	}
}