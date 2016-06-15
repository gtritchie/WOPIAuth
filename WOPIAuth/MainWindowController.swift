//
//  MainWindowController.swift
//  WOPIAuth
//
//  Copyright 2016 Gary Ritchie
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Cocoa

/// `NSWindowController` for the application's single main window.
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
