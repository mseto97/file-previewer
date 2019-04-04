//
//  MainWindowController.swift
//  MediaManagerApp
//
//  Created by Daniela Lemow on 21/09/18.
//  Copyright © 2018 Daniela Lemow. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    convenience init() {
        self.init(windowNibName: NSNib.Name(rawValue: "MainWindowController"))
    }
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
}
