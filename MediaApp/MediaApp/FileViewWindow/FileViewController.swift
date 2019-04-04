//
//  FileViewController.swift
//  MediaApp
//
//  Created by Daniela Lemow and Megan Seto on 29/09/18.
//  Copyright © 2018 Megan. All rights reserved.
//

import Cocoa
/*
 * The FileViewController allows us to keep track of the currently selected file through an array (viewFile)
 * Used in FileViewer to allow us to go to the next/previous imported file.
 */
class FileViewController : NSWindowController {
   
    //Array of the files that can be viewed
    var viewFiles : [File?] = []
    
    //keeps the current index
    var currFileIndex : Int = -1
    
    //Content view window
    var contentView : ContentView!
    
    convenience init() {
        self.init(windowNibName: "FileViewController")
        
    }
    
    /// Sets the content view window
    //
    /// - Parameters:
    /// - view: The Content View
    func setContentView(to view: ContentView) {
        self.contentView = view
    }
    
    /// Sets the files in viewFIles
    //
    /// - Parameters:
    /// - index: The current files index
    func setFiles(files: inout [File?]) {
        self.viewFiles = files
    }
    
    /// Sets the currFileIndex
    //
    /// - Parameters:
    /// - index: The current files index
    func setCurrFile(to index: Int) {
        self.currFileIndex = index
    }
    
    //loading files
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.title = "File Preview"
         let splitVC = NSSplitViewController()
        
        let fileView = FileViewer(nibName: nil, bundle: nil, viewFiles: &viewFiles, currIndex: currFileIndex, contentView: contentView)
        
        splitVC.addSplitViewItem(NSSplitViewItem(contentListWithViewController: fileView))

        window?.contentViewController = splitVC
       
    }
    
}
