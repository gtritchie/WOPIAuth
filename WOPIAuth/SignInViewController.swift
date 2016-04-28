import Cocoa
import WebKit

/**
	Controller to manage sign-in UI in a webview for WOPI auth flow.
*/
class SignInViewController: NSViewController, WebFrameLoadDelegate, WebResourceLoadDelegate {

	// MARK: Outlets
	
	@IBOutlet weak var webView: WebView!
	
	// MARK: Properties
	
	var connection: ConnectionInfo?
	var clientInfo: ClientInfo?
	var providerInfo: ProviderInfo?
	var completionHandler: ((FetchAuthResult) -> Void)?
	
	var stopUrl: NSURL?
	var authResult: AuthResult?
	
	// MARK: Embedded Types
	
	/// Used to return results from webview call
	enum FetchAuthResult {
		case Success(AuthResult)
		case Failure(NSError)
		
		init(throwingClosure: () throws -> AuthResult) {
			do {
				let authResult = try throwingClosure()
				self = .Success(authResult)
			}
			catch {
				self = .Failure(error as NSError)
			}
		}
	}
	
	func errorWithCode(code: Int, localizedDescription: String) -> NSError {
		WOPIAuthLogError(localizedDescription)
		return NSError(domain: "SignIn", code: code, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
	}

	// MARK: Life Cycle
	
	override func viewDidAppear() {
		
		assert(stopUrl == nil)
		assert(authResult == nil)
		
		let authPageUrl = "\(connection!.bootstrapInfo.authorizationURL)?client_id=\(providerInfo!.clientId)&redirect_uri=\(providerInfo!.redirectUrl)&response_type=code&scope=&rs=\(clientInfo!.culture)&build=\(clientInfo!.clientBuild)&platform=\(clientInfo!.clientPlatform)"
		
		guard let signInPageUrl = NSURL(string: authPageUrl) else {
			let error = errorWithCode(1, localizedDescription: "Malformed signIn URL: \"\(connection!.bootstrapInfo.authorizationURL)\"")
			let result: FetchAuthResult = .Failure(error)
			completionHandler!(result)
			return
		}

		guard let redirectUrl = NSURL(string: providerInfo!.redirectUrl) else {
			let error = errorWithCode(1, localizedDescription: "Malformed redirect URL: \"\(providerInfo!.redirectUrl)\"")
			let result: FetchAuthResult = .Failure(error)
			completionHandler!(result)
			return
		}
		stopUrl = redirectUrl

		webView.frameLoadDelegate = self
		webView.resourceLoadDelegate = self
		let request = NSURLRequest(URL: signInPageUrl)
		WOPIAuthLogInfo("Loading page: \(authPageUrl)")
		webView.mainFrame.loadRequest(request)
	}
	
	override func viewWillDisappear() {
		super.viewWillDisappear()
		
		webView.stopLoading(self)
		
		WOPIAuthLogInfo("Closing sign-in window")

		if let authInfo = authResult {
			let result = FetchAuthResult { authInfo }
			completionHandler!(result)
		} else {
			let error = errorWithCode(1, localizedDescription: "Failed to obtain required auth information from sign-in")
			let result: FetchAuthResult = .Failure(error)
			completionHandler!(result)
		}
	}
	
	// MARK: WebFrameLoadDelegate
	
	func webView(sender: WebView!, didStartProvisionalLoadForFrame frame: WebFrame!) {
		//print("Did Start Provisional Load for Frame")
	}
	
	// MARK: WebResourceLoadDelegate
	func webView(sender: WebView!,
	             resource: AnyObject!,
	             willSendRequest: NSURLRequest!,
	             redirectResponse: NSURLResponse!,
	             fromDataSource: WebDataSource!) -> NSURLRequest! {
		
		//print(willSendRequest.URL!.absoluteString)

		return willSendRequest
	}
}
