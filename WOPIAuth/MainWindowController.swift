import Cocoa

class MainWindowController: NSWindowController {

	/// Ensure defaults are registered
	let preferences = Preferences()
	
    override func windowDidLoad() {
        super.windowDidLoad()
		
		// This is needed to prevent drawing issues with the sidebar when it
		// is collapsed.
		self.contentViewController!.view.wantsLayer = true
    }
	
	// For some reason, setting this in the Storyboard doesn't work, have to 
	// do it in code.
	override func awakeFromNib() {
		super.awakeFromNib()
		window?.setFrameAutosaveName("MainWindowAutoSave")
	}

}
