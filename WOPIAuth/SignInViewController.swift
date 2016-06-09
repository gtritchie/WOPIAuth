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
		
		guard let pageUrl = NSURLComponents(string: connection!.bootstrapInfo.authorizationURL) else {
			let error = errorWithCode(1, localizedDescription: "Malformed signIn URL: \"\(connection!.bootstrapInfo.authorizationURL)\"")
			let result: FetchAuthResult = .Failure(error)
			completionHandler!(result)
			return
		}
		
		let scopeStr = unwrapStringReplaceNilWithEmpty(providerInfo!.scope)
		
		let queryItems: [NSURLQueryItem] = [
			NSURLQueryItem(name: "client_id", value: providerInfo!.clientId),
			NSURLQueryItem(name: "redirect_uri", value: providerInfo!.redirectUrl),
			NSURLQueryItem(name: "response_type", value: "code"),
			NSURLQueryItem(name: "rs", value: clientInfo!.culture),
			NSURLQueryItem(name: "build", value: clientInfo!.clientBuild),
			NSURLQueryItem(name: "platform", value: clientInfo!.clientPlatform),
			NSURLQueryItem(name: "scope", value: scopeStr)
		]
		pageUrl.queryItems = queryItems

		guard let signInPageUrl = pageUrl.URL else {
			let error = errorWithCode(1, localizedDescription: "Unable to construct full signIn URL")
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

		webView.navigationDelegate = self

		let request = NSURLRequest(URL: signInPageUrl)
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
	
	// MARK: WKNavigationDelegate
	
	func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
		let request = navigationAction.request
		let url = request.URL
		if let url = url where url.scheme == stopUrl?.scheme && url.host == stopUrl?.host {
			let haveComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)
			if let hp = haveComponents?.path, ip = stopUrl?.path where hp == ip || ("/" == hp + ip) {
				if let query = haveComponents?.query {
					WOPIAuthLogInfo("The redirect URI was invoked with \(query)")
					var code = ""
					var tk = ""
					var sc = ""
					var error = ""
					var errorDescription = ""
					var errorURI = ""
					if let queryArray = haveComponents?.queryItems {
						for queryParam in queryArray {
							let paramLower = queryParam.name.lowercaseString
							switch paramLower {
							case "code":
								warnMixedCaseParam("code", matchedStr: queryParam.name)
								if let codeStr = queryParam.value {
									code = codeStr
								}
							case "tk":
								warnMixedCaseParam("tk", matchedStr: queryParam.name)
								if let tkValue = queryParam.value {
									tk = tkValue
								}
							case "sc":
								warnMixedCaseParam("sc", matchedStr: queryParam.name)
								if let scValue = queryParam.value {
									sc = scValue
								}
							case "error":
								warnMixedCaseParam("error", matchedStr: queryParam.name)
								if let errorValue = queryParam.value {
									error = errorValue
								}
							case "error_description":
								warnMixedCaseParam("error_description", matchedStr: queryParam.name)
								if let errorDescriptionValue = queryParam.value {
									errorDescription = errorDescriptionValue
								}
							case "error_uri":
								warnMixedCaseParam("error_uri", matchedStr: queryParam.name)
								if let errorURIValue = queryParam.value {
									errorURI = errorURIValue
								}
							default:
								WOPIAuthLogWarning("Unrecognized redir parameter: \(queryParam.name)")
							}
						}
					}
					if !error.isEmpty {
						WOPIAuthLogError("Error from redir: \(error)")
						if !errorDescription.isEmpty {
							WOPIAuthLogError("Error Description: \(errorDescription)")
						}
						if !errorURI.isEmpty {
							WOPIAuthLogError("Error URI: \(errorURI)")
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
						authResult!.error = error
						authResult!.errorDescription = errorDescription
						authResult!.errorURI = errorURI
						
					}
					else {
						WOPIAuthLogError("Did not find valid auth_code on redir")
					}
					decisionHandler(.Cancel)
					dismissController(self)
				}
			}
		}
		if let url = url {
			WOPIAuthLogInfo("Opening \(url.absoluteString)")
		}
		decisionHandler(.Allow)
	}

	func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
		let response = navigationResponse.response
		let url = response.URL!.absoluteString
		WOPIAuthLogInfo("Redirect to \(url)")
		
		let urlParts = NSURLComponents(URL: response.URL!, resolvingAgainstBaseURL: true)!

		if urlParts.scheme != "https" {
			WOPIAuthLogWarning("Redirect to insecure endpoint (non-https)")
		}
		decisionHandler(.Allow)
	}

	func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
		if NSURLErrorDomain == error.domain && NSURLErrorCancelled == error.code {
			return
		}
	}
	
	// MARK: Utility
	
	/// Log a warning if the matched parameter and expected parameter differed only by case
	func warnMixedCaseParam(expectedStr: String, matchedStr: String) {
		if expectedStr != matchedStr {
			WOPIAuthLogWarning("Redirect params must be lowercase: matched \(expectedStr) as \(matchedStr)")
		}
	}
}
