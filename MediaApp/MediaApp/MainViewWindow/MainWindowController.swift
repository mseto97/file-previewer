//
//  MainWindowController.swift
//  MediaApp
//  
//  Created by Daniela Lemow and Megan Seto on 23/09/18.
//  Copyright © 2018 Megan. All rights reserved.
//

import Cocoa
/*
 * The main window for the application responsible for importing/exporting files
 * Viewing files, displaying imported files and adding selected files to bookmarks
 */
class MainWindowController: NSWindowController {
    
    var contentView : ContentView! //A reference to the content view
    
    convenience init() {
        self.init(windowNibName: "MainWindowController")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        //hides the titlebar on window
        window?.titlebarAppearsTransparent = true
        window?.titleVisibility = .hidden

        
        let splitVC = NSSplitViewController()   //creates SplitViewController to add the different views to
        let leftSplit = BookmarkView()          //Creates BookmarkView
        let rightSplit = ImagePreview()         //Creates ImagePreview
        contentView = ContentView(nibName: nil, bundle: nil, bookmarks: leftSplit, preview : rightSplit, mainWindow: self)
        let middleSplit = contentView     //Creates ContentView
        
        //lets the bookmark view know about the content view
        leftSplit.setContentView(to: middleSplit!)
        
        //adds splits to the split view controller
        splitVC.addSplitViewItem(NSSplitViewItem(contentListWithViewController: leftSplit))
        splitVC.addSplitViewItem(NSSplitViewItem(contentListWithViewController: middleSplit!))
        splitVC.addSplitViewItem(NSSplitViewItem(contentListWithViewController: rightSplit))
    
        
        window?.contentViewController = splitVC
        contentView.tableView.reloadData()

    }
    
    //Opens the "File Previewer" (View that opens when user clicks the "Show File Info..." button)
    //Called from the Content View.
    func openFileView(with files: inout [File?], from index: Int) {
        
        let fileView = FileViewController()
        fileView.setFiles(files: &files)
        fileView.setCurrFile(to: index)
        fileView.setContentView(to: contentView)
  
        fileView.showWindow(self)
        
    }
    
    //Opens the "Projector View" (View that opens when user double clicks on imported file or clicks "View File.." button).
    //Projector View is called from the Content View.
    func openProjectorView(with path: String, and type: String) {
        
        let projectorView = ProjecterViewController()
        projectorView.setFilePath(to: path)
        projectorView.setType(to: type)
        projectorView.showWindow(self)
        
    }
    
}
