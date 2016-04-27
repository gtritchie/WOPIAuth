import Cocoa
import WebKit

/**
	Controller to manage WOPI client authentication flow test. Each stage of the WOPI client auth flow
	is exercised, and details are logged.
*/
class SignInViewController: NSViewController {

	@IBOutlet weak var webView: WebView!
	

	override func viewDidAppear() {
		let request = NSURLRequest(URL: NSURL(string: "http://www.box.com")!)
		webView.mainFrame.loadRequest(request)
	}
	
}
