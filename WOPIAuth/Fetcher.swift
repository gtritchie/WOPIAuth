import Foundation

/// Base class for async HTTP calls
class Fetcher {
	
	var url: NSURL
	let session: NSURLSession
	var task: NSURLSessionDataTask?
	var errorDomain: String
	
	init(url: NSURL, errorDomain: String) {
		self.url = url
		self.errorDomain = errorDomain
		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
		session = NSURLSession(configuration: config)
	}
	
	/// Cancel an in-progress request. The completion handler may still be invoked,
	/// check for error code of `NSURLErrorCancelled`.
	func cancel() {
		if task != nil {
			task!.cancel()
			task = nil
		}
	}
	
	func errorWithMessage(localizedDescription: String) -> NSError {
		return NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
	}

}
