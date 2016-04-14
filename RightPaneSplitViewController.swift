import Cocoa

/**
	`NSSplitViewController` subclass for the splitter between top and bottom of
	right pane of the program.
*/
class RightPaneSplitViewController: NSSplitViewController {

	// For some reason, setting this in the Storyboard doesn't work, have to
	// do it in code.
	override func awakeFromNib() {
		super.awakeFromNib()
		splitView.autosaveName = "RightPaneSplitAutoSave"
	}
    
}
