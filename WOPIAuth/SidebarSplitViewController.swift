import Cocoa

/**
	`NSSplitViewController` subclass for the splitter between sidebar and right-side
	of the program.
*/
class SidebarSplitViewController: NSSplitViewController {

	// For some reason, setting this in the Storyboard doesn't work, have to
	// do it in code.
	override func awakeFromNib() {
		super.awakeFromNib()
		splitView.autosaveName = "SidebarSplitAutoSave"
	}
}
