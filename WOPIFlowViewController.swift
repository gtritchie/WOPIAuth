import Cocoa

/**
	Controller to manage WOPI client authentication flow test.
*/
class WOPIFlowViewController: NSViewController {
	
	// MARK: Actions
	
	@IBAction func closeSheet(sender: NSButton) {
		dismissController(sender)
	}
	
	// MARK: Outlets
	
	@IBOutlet weak var bootstrapImage: NSImageView!
	@IBOutlet weak var bootstrapText: NSTextField!
	@IBOutlet weak var signinImage: NSImageView!
	@IBOutlet weak var signinText: NSTextField!
	@IBOutlet weak var tokenImage: NSImageView!
	@IBOutlet weak var tokenText: NSTextField!
	@IBOutlet weak var profileImage: NSImageView!
	@IBOutlet weak var profileText: NSTextField!
	
}


//progressIndicator.startAnimation(sender)
//let fetcher = BootstrapFetcher()
//
//fetcher.fetchBootstrapInfoUsingCompletionHandler { (result) in
//	switch result {
//	case .Success:
//		print("Got 200 response, NOT EXPECTED")
//	case .Failure:
//		print("Got expected 401 response")
//	}
//	
//	self.progressIndicator.stopAnimation(nil)
//	self.window!.sheetParent!.endSheet(self.window!, returnCode: NSModalResponseOK)
//}