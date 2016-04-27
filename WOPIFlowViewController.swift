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
	@IBOutlet weak var bootstrapProgress: NSProgressIndicator!
	@IBOutlet weak var signinImage: NSImageView!
	@IBOutlet weak var signinText: NSTextField!
	@IBOutlet weak var signinProgress: NSProgressIndicator!
	@IBOutlet weak var tokenImage: NSImageView!
	@IBOutlet weak var tokenText: NSTextField!
	@IBOutlet weak var tokenProgress: NSProgressIndicator!
	@IBOutlet weak var profileImage: NSImageView!
	@IBOutlet weak var profileText: NSTextField!
	@IBOutlet weak var profileProgress: NSProgressIndicator!

	// MARK: Track current step
	
	var currentStep: String?
	weak var currentImage: NSImageView?
	weak var currentTextLabel: NSTextField?
	weak var currentProgress: NSProgressIndicator?
	
	// MARK: Life Cycle
	
	override func viewWillAppear() {
		bootstrapImage.image = nil
		signinImage.image = nil
		tokenImage.image = nil
		profileImage.image = nil
	}
	
	override func viewDidAppear() {
		super.viewWillAppear()
		
		assert(provider != nil, "Must supply a provider to WOPIFlowViewController")
		assert(connections != nil, "Must supply array of connections to WOPIFlowViewController ")
	
		performAuthFlow()
	}

	func failCurrentStep() {
		currentImage!.image = NSImage(named: "ErrorXCircle")
		currentTextLabel!.textColor = NSColor.redColor()
		currentProgress!.stopAnimation(nil)
		WOPIAuthLogError("FAILURE: WOPI client authentication flow during \(currentStep!) phase.")
		WOPIAuthLogError("======================================================================")
	}
	
	func completeCurrentStep() {
		if let previousStep = currentStep {
			WOPIAuthLogInfo("Completed step \(previousStep)")
		}
		if let previousImage = currentImage {
			previousImage.image = NSImage(named: "SuccessCheckCircle")
		}
		if let previousProgress = currentProgress {
			previousProgress.stopAnimation(nil)
		}
	}
	
	func startNewStep(step: String, image: NSImageView, text: NSTextField, progress: NSProgressIndicator) {
		completeCurrentStep()
		
		currentStep = step
		WOPIAuthLogInfo("Starting \(currentStep!)")
		
		currentImage = image
		currentTextLabel = text
		
		currentProgress = progress
		currentProgress!.startAnimation(nil)
	}
	
	func performAuthFlow() {
		
		WOPIAuthLogInfo("START WOPI client authentication flow")
		WOPIAuthLogInfo("=====================================")
		
		guard initialBootstrapperCall() else {
			return
		}
		guard signIn() else {
			return
		}
		guard getTokens() else {
			return
		}
		guard getProfile() else {
			return
		}
		
		completeCurrentStep()
		
		WOPIAuthLogInfo("SUCCESS WOPI client authentication flow")
		WOPIAuthLogInfo("=======================================")
	}
	
	/// Step One: Unauthenticated Bootstrapper call
	func initialBootstrapperCall() -> Bool {
		startNewStep("bootstrapper", image: bootstrapImage, text: bootstrapText, progress: bootstrapProgress)

		// Sanity check on ProviderInfo
		guard provider!.validate() == true else {
			failCurrentStep()
			return false
		}
		
		WOPIAuthLogInfo("Provider=\(String(provider!))")
		
		return true
	}
	
	/// Step Two: Interactive Sign-In UI
	func signIn() -> Bool {
		startNewStep("signin", image: signinImage, text: signinText, progress: signinProgress)

		return true
	}
	
	/// Step Three: Obtain tokens
	func getTokens() -> Bool {
		startNewStep("tokens", image: tokenImage, text: tokenText, progress: tokenProgress)

		return true
	}
	
	// Step Four: Authenticated call to bootstrapper for user profile info
	func getProfile() -> Bool {
		startNewStep("profile", image: profileImage, text: profileText, progress: profileProgress)

		return true
	}
	
}


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