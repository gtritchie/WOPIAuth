import Cocoa

/**
	Controller to manage WOPI client authentication flow test. Each stage of the WOPI client auth flow
	is exercised, and details are logged.

	1. Bootstrapper call
	2. Sign-In UI
	3. Fetch tokens
	4. Fetch profile information from bootstrapper
*/
class WOPIFlowViewController: NSViewController, ConnectionCreating {
	
	// MARK: Properties
	
	/// OAuth2 auth_code
	var authCode: String?

	// MARK: ConnectionCreating
	
	/// The `ProviderInfo` used to begin the identity flow
	var provider: ProviderInfo?
	
	/// Who to notify when we have a new connection
	var container: ConnectionContaining?

	private var connection: ConnectionInfo?
	
	// MARK: Actions
	
	@IBAction func closeSheet(sender: NSButton) {
		if currentStep != nil {
			failCurrentStep()
			WOPIAuthLogError("FAILURE: Window closed before current step completed")
			WOPIAuthLogError("====================================================")
		}
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
		assert(container != nil, "Must supply container ")
	
		WOPIAuthLogInfo("START WOPI client authentication flow")
		WOPIAuthLogInfo("=====================================")

		connection = ConnectionInfo()
		connection!.providerName = provider!.providerName
		initialBootstrapperCall()
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
			WOPIAuthLogInfo("Completed \(previousStep)")
		}
		if let previousImage = currentImage {
			previousImage.image = NSImage(named: "SuccessCheckCircle")
		}
		if let previousProgress = currentProgress {
			previousProgress.stopAnimation(nil)
		}
		
		currentStep = nil
		currentImage = nil
		currentTextLabel = nil
		currentProgress = nil
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
	
	// MARK: Identity Flow Stages
	
	/// Step One: Unauthenticated Bootstrapper call
	func initialBootstrapperCall() {
		startNewStep("1: Bootstrapper", image: bootstrapImage, text: bootstrapText, progress: bootstrapProgress)

		// Sanity check on ProviderInfo
		guard provider!.validate() == true else {
			failCurrentStep()
			return
		}
		
		WOPIAuthLogInfo("Provider=\(String(provider!))")
		let fetcher = BootstrapFetcher(url: provider!.bootstrapper)
		fetcher.fetchBootstrapInfoUsingCompletionHandler { (result) in
			switch result {
			case .Success(let bootstrapper):
				WOPIAuthLogInfo("Bootstrapper got expected 401 response with header")
				WOPIAuthLogInfo("bootstrapper=\(bootstrapper)")
				self.connection!.bootstrapInfo = bootstrapper
				self.signIn()
			case .Failure:
				self.failCurrentStep()
			}
		}
	}
	
	/// Step Two: Interactive Sign-In UI
	func signIn() {
		startNewStep("2: Signin", image: signinImage, text: signinText, progress: signinProgress)
		performSegueWithIdentifier("ShowSignIn", sender: nil)
	}
	
	/// Step Two+: Completion Handler for Sign-In UI
	func signInResult(signInResult: SignInViewController.FetchAuthResult) {
		switch signInResult {
		case .Success(let authResult):
			self.authCode = authResult.authCode
			self.connection!.postAuthTokenIssuanceURL = authResult.postAuthTokenIssuanceURL
			self.connection!.sessionContext = authResult.sessionContext
			getTokens()
		case .Failure:
			self.failCurrentStep()
		}
	}
	
	/// Step Three: Obtain tokens
	func getTokens()  {
		startNewStep("3: Tokens", image: tokenImage, text: tokenText, progress: tokenProgress)
		
		var tokenEndpointUrl = connection!.bootstrapInfo.tokenIssuanceURL
		if !connection!.postAuthTokenIssuanceURL.isEmpty {
			tokenEndpointUrl = connection!.postAuthTokenIssuanceURL
			WOPIAuthLogInfo("Using post-auth token exchange URL: \(tokenEndpointUrl)")
		} else {
			WOPIAuthLogInfo("Using standard token exchange URL: \(tokenEndpointUrl)")
		}
		let tokenFetcher = TokenFetcher(tokenUrl: tokenEndpointUrl, clientId: provider!.clientId,
		                                clientSecret: provider!.clientSecret, authCode: authCode!,
		                                redirectUri: provider!.redirectUrl,
		                                sessionContext: connection!.sessionContext)
		tokenFetcher.fetchTokensUsingCompletionHandler { (result) in
			switch result {
			case .Success(let tokenResult):
				WOPIAuthLogInfo("Token endpoint returned info")
				self.connection!.accessToken = tokenResult.accessToken
				self.connection!.tokenExpiration = tokenResult.tokenExpiration
				self.connection!.refreshToken = tokenResult.refreshToken
				self.getProfile()
			case .Failure(let error):
				WOPIAuthLogError(error.localizedDescription)
				self.failCurrentStep()
			}
		}
	}
	
	// Step Four: Authenticated call to bootstrapper for user profile info
	func getProfile() {
		startNewStep("4: Profile", image: profileImage, text: profileText, progress: profileProgress)
		
		connection!.userName = "Sample User Name"
		connection!.userId = "userId23423"
		connection!.friendlyName = "Friendy Name"
		
		finishFlow()
	}
	
	// Step Five: Success
	func finishFlow() {
		completeCurrentStep()
		
		container!.addNew(connection!)
		
		WOPIAuthLogInfo("SUCCESS WOPI client authentication flow")
		WOPIAuthLogInfo("=======================================")
	}
	
	// MARK: Segue
	
	override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
		switch segue.identifier! {
			
		case "ShowSignIn":
			let signInController  = segue.destinationController as! SignInViewController
			signInController.connection = connection
			signInController.clientInfo = ClientInfo() // TODO: set via preferences
			signInController.completionHandler = self.signInResult
			signInController.providerInfo = provider
		default:
			print("Unknown segue: \(segue.identifier)")
		}
	}
	
}
