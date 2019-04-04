//
//  ProjecterViewController.swift
//  MediaApp
//
// ProjectorViewController 
//
//  Created by Daniela Lemow on 5/10/18.
//  Copyright © 2018 Megan. All rights reserved.
//

import Cocoa
/*
 * The projector window for the application.
 */
class ProjecterViewController: NSWindowController {
    
    var filePath : String = "" //Stores the path to the file being viewed
    var type : String = "" //Stores the type for the file being viewed
    
    convenience init() {
        self.init(windowNibName: "ProjecterViewController")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let split = filePath.split(separator: "/")
        self.window?.title = String(split[split.count-1])
        let splitVC = NSSplitViewController()
        
        let projectorView = ProjectorView(nibName: nil, bundle: nil, filePath: filePath, type: type)
        
        splitVC.addSplitViewItem(NSSplitViewItem(contentListWithViewController: projectorView))
        window?.contentViewController = splitVC

    }
    
    
    /// Sets the file path
    ///
    /// - Parameters:
    /// - sender: String representing the files path
    ///
    func setFilePath(to path: String) {
        self.filePath = path
    }
    
    /// Sets the type of the file
    ///
    /// - Parameters:
    /// - type: String representing the type of file
    ///
    func setType(to type: String) {
        self.type = type
    }
    
}
