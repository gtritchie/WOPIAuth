//
//  MainWindowController.swift
//  WOPIAuth
//
//  Created by Gary Ritchie on 4/11/16.
//  Copyright © 2016 Gary Ritchie. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
		
		// This is needed to prevent drawing issues with the sidebar when it
		// is collapsed.
		self.contentViewController!.view.wantsLayer = true
    }

}
