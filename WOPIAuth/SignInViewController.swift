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
	var completionHandler: ((FetchAuthResult) -> Void)?
	
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
	
	// MARK: Life Cycle
	
	override func viewDidAppear() {
		webView.frameLoadDelegate = self
		webView.resourceLoadDelegate = self
		let request = NSURLRequest(URL: NSURL(string: "http://www.box.com")!)
		webView.mainFrame.loadRequest(request)
	}
	
	// MARK: WebFrameLoadDelegate
	
	func webView(sender: WebView!, didStartProvisionalLoadForFrame frame: WebFrame!) {
		print("Did Start Provisional Load for Frame")
	}
	
	// MARK: WebResourceLoadDelegate
	func webView(sender: WebView!,
	             resource: AnyObject!,
	             willSendRequest: NSURLRequest!,
	             redirectResponse: NSURLResponse!,
	             fromDataSource: WebDataSource!) -> NSURLRequest! {
		
		print(willSendRequest.URL!.absoluteString)

		return willSendRequest
	}
}
