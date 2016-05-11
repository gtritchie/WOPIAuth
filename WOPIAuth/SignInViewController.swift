import Cocoa
import WebKit

/**
	Controller to manage sign-in UI in a webview for WOPI auth flow.
*/
class SignInViewController: NSViewController, WKNavigationDelegate {

	// MARK: Properties
	
	/// Our web view; implicitly unwrapped so do not attempt to use it unless isViewLoaded() returns true.
	var webView: WKWebView!

	var connection: ConnectionInfo?
	var clientInfo: ClientInfo?
	var providerInfo: ProviderInfo?
	
	/// Called to indicate success or failure of the sign-in flow
	var completionHandler: ((FetchAuthResult) -> Void)?
	
	var stopUrl: NSURLComponents?
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

	// MARK: - View Handling
	
	internal static let WebViewWindowWidth = CGFloat(600.0)
	internal static let WebViewWindowHeight = CGFloat(500.0)
	
	override func loadView() {
		view = NSView(frame: NSMakeRect(0, 0, SignInViewController.WebViewWindowWidth, SignInViewController.WebViewWindowHeight))
		view.translatesAutoresizingMaskIntoConstraints = false
		
		webView = WKWebView(frame: view.bounds, configuration: WKWebViewConfiguration())
		webView.translatesAutoresizingMaskIntoConstraints = false
		webView.navigationDelegate = self
		webView.alphaValue = 0.0
		
		view.addSubview(webView)
		view.addConstraint(NSLayoutConstraint(item: webView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0))
		view.addConstraint(NSLayoutConstraint(item: webView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
		view.addConstraint(NSLayoutConstraint(item: webView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0.0))
		view.addConstraint(NSLayoutConstraint(item: webView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0.0))
	}

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
		stopUrl = NSURLComponents(URL: redirectUrl, resolvingAgainstBaseURL: true)

		//webView.frameLoadDelegate = self
		//webView.resourceLoadDelegate = self
		webView.navigationDelegate = self

		let request = NSURLRequest(URL: signInPageUrl)
		WOPIAuthLogInfo("Loading page: \(authPageUrl)")
		webView.loadRequest(request)
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
	
	func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
		let request = navigationAction.request
		
		if let url = request.URL where url.scheme == stopUrl?.scheme && url.host == stopUrl?.host {
			let haveComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)
			if let hp = haveComponents?.path, ip = stopUrl?.path where hp == ip || ("/" == hp + ip) {
				if let query = haveComponents?.query {
					WOPIAuthLogInfo("The redirect URI was invoked with \(query)")
					var code = ""
					var tk = ""
					var sc = ""
					if let queryArray = haveComponents?.queryItems {
						for queryParam in queryArray {
							switch queryParam.name {
							case "code":
								if let codeStr = queryParam.value {
									code = codeStr
								}
							case "tk",
							     "TK":
								if let tkValue = queryParam.value {
									tk = tkValue
								}
							case "sc",
							     "SC":
								if let scValue = queryParam.value {
									sc = scValue
								}
							default:
								WOPIAuthLogError("Unrecognized redir parameter: \(queryParam.name)")
							}
						}
					}
					if !code.isEmpty {
						WOPIAuthLogInfo("Extracted auth_code from redir: \(code)")
						if !tk.isEmpty {
							WOPIAuthLogInfo("Extracted postauthTokenUrl from redir: \(tk)")
						}
						if !sc.isEmpty {
							WOPIAuthLogInfo("Extracted sessionContext from redir: \(sc)")
						}
						
						authResult = AuthResult()
						authResult!.authCode = code
						authResult!.postAuthTokenIssuanceURL = tk
						authResult!.sessionContext = sc
						
						decisionHandler(.Cancel)
						dismissController(self)
					}
					else {
						WOPIAuthLogError("Did not find valid auth_code on redir")
					}
				}
			}
		}
		decisionHandler(.Allow)
	}

	func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
		if NSURLErrorDomain == error.domain && NSURLErrorCancelled == error.code {
			return
		}
	}
}
