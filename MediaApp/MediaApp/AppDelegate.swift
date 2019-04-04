//
//  AppDelegate.swift
//
//  Created by Hamza on 12/09/18.
//  AppDelegate.swift
//  MediaApp
//
//  Created by Megan on 23/09/18.
//  Copyright © 2018 Megan. All rights reserved.
//

import Cocoa
import AVFoundation;
import AVKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let mainWindowController = MainWindowController()
    var bookmarkView : BookmarkView!
    
    //The resource files contained in the Bundle to be written to the application user's directory
    // ~/Library/Application Support/MediaApp
    let testFiles = [
        "assignment-report" : ".pdf",
        "jellyfish" : ".mov",
        "majestic-cloud-pic": ".png",
        "service-bell_daniel_simion" : ".m4a",
        "lorem-ipsum" : ".txt"
    ]
    
    func setBookmarkView(to bookmarkView: BookmarkView) {
        self.bookmarkView = bookmarkView
    }

    /// Sent by the default notification center after the application has been
    /// launched and initialized but before it has received its first event.
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        //gets the users home directory
        let homeDirectory = (FileManager.default.homeDirectoryForCurrentUser.absoluteString).replacingOccurrences(of: "file://", with: "")
        
        //Add the location where the applications files should be stored
        let libraryDirectory = homeDirectory + "Library/Application Support/MediaApp"
        
        //If the folder for the MediaApp does not exist, create it
        if (!directoryExistsAtPath(libraryDirectory)) {
            do {
                try FileManager.default.createDirectory(atPath: libraryDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("This didn't work")
            }
        }
        
        //For each file to be used during testing
        for file in testFiles {
            
            //Get the path to the file stored in the Bundle
            let bundlePath = Bundle.main.path(forResource: file.key, ofType: file.value)
            let fileNameWithExtension = file.key + file.value  //Get the full filename
            let exportDirectory = libraryDirectory + "/" + fileNameWithExtension //Get the full directory to copy the file to
            
            //If the file does not already exist at the location, copy if from the Bundle to the user's computer
            if (!FileManager.default.fileExists(atPath: exportDirectory)) {
                do {
                    try FileManager.default.copyItem(atPath: bundlePath!, toPath: exportDirectory)
                } catch {
                    print("Item could not be copied.")
                }
            }
        }
        
        //Make the main window visible
        mainWindowController.showWindow(self)
    }
    
    ///Sent by the default notification center immediately before the application terminates.
    func applicationWillTerminate(_ aNotification: Notification) {
     
        //get the users home directory
        let homeDirectory = (FileManager.default.homeDirectoryForCurrentUser.absoluteString).replacingOccurrences(of: "file://", with: "")
        
        //Add the location where the applications files should be stored
        let libraryDirectory = homeDirectory + "Library/Application Support/MediaApp"
        
        //If the folder for the MediaApp does not exist, create it
        if (!directoryExistsAtPath(libraryDirectory)) {
            do {
            try FileManager.default.createDirectory(atPath: libraryDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("The directory to store application files in could not be made.")
            }
        }
        
        //append the filename to the path, and export the entire library to it
        let exportDirectory = libraryDirectory + "/library.json"
        CommandController.exportLibrary(to: exportDirectory)
    }
    
    //Referenced in report, checks if a directory exists at a specific path
    //https://gist.github.com/brennanMKE/a0a2ee6aa5a2e2e66297c580c4df0d66
    fileprivate func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    

}

