//
//  CommandController.swift
//  MediaApp
//
//  Created by Daniela Lemow and Megan Seto on 26/09/18.
//  Copyright © 2018 Megan. All rights reserved.
//

import Foundation

class CommandController {
    
    typealias MMFile = Media
    static var last : [File] = []
    
    static func load(from path: String) -> [File] {
        
        let importHandler = IEManager()
        var viewFiles : [MMFile] = []
        
        if (FileManager.default.fileExists(atPath: path)) {
            do {
                try viewFiles.append(contentsOf: importHandler.read(filename: path))
            } catch {
                //this might happen if the file doesn't exist
                print("Something bad happened!")
            }
        }
        
        return convertToFile(from: viewFiles)
    }
    
    //Asks the backend to import the files
    static func load(from urls: [URL]) throws -> [File] {
        
        //If no file to load is specified, throw invalidParameters
        guard !urls.isEmpty else {
            throw MMCliError.invalidParameters
        }
        
        let importHandler = IEManager()
        var viewFiles : [MMFile] = []
        
        
        //For each file specified, load the contents into the media library, and add the loaded files to a list
        for filepath in urls {
            let filePathString = filepath.absoluteString.replacingOccurrences(of: "file://", with: "")
            do {
                try viewFiles.append(contentsOf: importHandler.read(filename: filePathString))
            } catch ImportExportError.invalidFilepath {
                print("File path: \"\(importHandler.getFilePath(from: filePathString))\" does not exist -- please try again with a valid path. ")
            }
        }
        
        return convertToFile(from: viewFiles)
        
    }
    
    /// Exports the files to specified url
    ///
    /// - Parameters:
    /// - url: The url where the files will be exported to
    static func export(to url: URL) -> Void {
        
        let exporter = IEManager()
        
        guard !last.isEmpty else {
            return
        }
        do {
            try exporter.write(filename: String(url.absoluteString.dropFirst(7)), items: convertToMMFile(from: last))
        } catch {
            
        }
        
    }
    
    //export the files with string path
    static func exportLibrary(to path: String) -> Void {
        
        let exporter = IEManager()
        do {
            try exporter.write(filename: path, items: convertToMMFile(from: (BookmarkView.bookmarks[0]?.files)!))
        } catch {
            print("This isn't working lol")
        }
        
    }
    
    //Filters the content based on file type (audio, video, document, image)
    static func filter(by category: String) -> [File] {
        
        let library = Library()
        
        if ["-a", "-v", "-d", "-i"].contains(category) {
            return convertToFile(from: library.filterBy(by: [category]))
        }
       
        return convertToFile(from: library.all())
        
    }
    
    
    /// Returns all of the Files in an array
    ///
    /// - Returns:
    /// - [File]: An array of Files
    static func allFiles() -> [File] {
        
        let library = Library()
        return convertToFile(from: library.all())
    }
    
    /// Searches the files in the current view for input keywords
    /// and returns an array of files that contain search word
    /// Used for search bar function in MainViewWindow
    ///
    /// - Parameters:
    /// - string: keyword to search on
    /// - files: Array of [File] that needs to be searched for the keyword
    ///
    /// - Returns:
    /// - [Files]: An array that contains File with the keyword
    static func search(for string: String, in files: [File]) -> [File] {
        
        let library = Library()
        
        if files.count > 0 {
            last = files
        }
        
        // User may be searching on more than one word
        // Therefore add all keys to the searchTerms
        var searchTerms = string.split(separator: " ")
        searchTerms.append(Substring(string))
        
        let mediaFiles = convertToMMFile(from: last)
        print()
        var resultFiles : [MMFile] = []
        
        //searches for each keyword in the search term
        for term in searchTerms {
            let search = library.search(term: String(term))
            for file in search where mediaFiles.contains(file) {
                    resultFiles.append(file)
            }
        }
        
        //returns the files that contain the search word
        print(resultFiles)
        return convertToFile(from: resultFiles)
        
    }
    
    
    /// Converts MMfiles to File that can be displayed in window
    /// Takes MMfile and changes the format and metadata so that can be used
    ///
    /// - Parameters:
    /// - MMFiles: MMFiles that are going to be converted to File
    ///
    /// - Returns:
    /// - [File]: An array of correctly formated files that can be used in the app
    static func convertToFile(from MMfiles: [MMFile]) -> [File] {
        
        //holds the newly formatted files
        var resultFiles : [File] = []
        
        //goes through each of the MMFiles and sets metadata
        for file in MMfiles {
            
            //sets the file resolution and run time to --- for all
            var resolution = "---"
            var runtime = "---"
            
            //sets runtime of the file if the mmfile is of correct type
            // runtime only needs to be set it file is audio or video
            if file is Audio || file is Video {
                runtime = file.runtime!
            }
            
            //sets resolution of the file if the mm file is of correct type
            //resolution only needs to be set if file is video or image
            if file is Video || file is Image {
                resolution = file.resolution!
            }
            
            //creates a new, correctly formatted file of type File
            let newFile = File(fileURL: file.path, name: file.filename, type: file.type, creator: file.creator!, resolution: resolution, runtime: runtime, metadata: file.metadata)
            
            //adds the new file to the resultsFiles
            resultFiles.append(newFile)
        }
        
        //returns all of the new files
        return resultFiles
        
    }
    
    /// Converts a list of type File to a list of type MMFile
    /// Mainly used for exporting files
    ///
    /// - Parameters:
    /// - files: An array of Files that need to be converted to a MMFile
    ///
    /// - Returns:
    /// - [MMFile]: Array of converted MMFiles
    static func convertToMMFile(from files: [File]) -> [MMFile] {
        
        var resultFiles : [MMFile] = []
        
        for file in files {
            
            //creates a new MMFile depending on the "type"
            switch (file.type) {
                case "document":
                    let newFile = Document(filename: file.name, path: file.url, type: file.type, metadata: file.toMMMetadata())
                    resultFiles.append(newFile)
                    break
                case "image":
                    let newFile = Image(filename: file.name, path: file.url, type: file.type, metadata: file.toMMMetadata())
                    resultFiles.append(newFile)
                    break
                case "audio":
                    let newFile = Audio(filename: file.name, path: file.url, type: file.type, metadata: file.toMMMetadata())
                    resultFiles.append(newFile)
                    break
                case "video":
                    let newFile = Video(filename: file.name, path: file.url, type: file.type, metadata: file.toMMMetadata())
                    resultFiles.append(newFile)
                    break
                default:
                    break
            }
        }
        
        //returns the list of converted files
        return resultFiles
    }
    
    //Updates the selected files
    static func updateSelectedFiles(add files: [File]) {
        last = files
    }
    
}
