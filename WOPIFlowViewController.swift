import Cocoa

/**
	Controller to manage WOPI client authentication flow test.
*/
class WOPIFlowViewController: NSViewController, ConnectionCreating {
	
	// MARK: ConnectionCreating
	
	/// The `ProviderInfo` used to begin the identity flow
	var provider: ProviderInfo?
	
	/// The array of `ConnectionInfo`s we will add to or update
	var connections: [ConnectionInfo]?

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

	weak var currentImage: NSImageView?
	weak var currentTextLabel: NSTextField?
	
	// MARK: Life Cycle
	
	/// Set initial state before we show the view
	override func viewWillAppear() {
		bootstrapImage.image = nil
		signinImage.image = nil
		tokenImage.image = nil
		profileImage.image = nil
		
		currentImage = bootstrapImage
		currentTextLabel = bootstrapText
	}
	
	// View is visible so start the flow
	override func viewDidAppear() {
		super.viewWillAppear()
		
		assert(provider != nil, "Must supply a provider to WOPIFlowViewController")
		assert(connections != nil, "Must supply array of connections to WOPIFlowViewController ")
	
		WOPIAuthLogInfo("Starting WOPI client authentication flow")
		
		guard provider!.validate() == true else {
			failCurrentStep()
			return
		}
		
	}

	func failCurrentStep() {
		currentImage!.image = NSImage(named: "ErrorXCircle")
		currentTextLabel!.textColor = NSColor.redColor()
		WOPIAuthLogInfo("Stopping WOPI client authentication flow")
	}
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