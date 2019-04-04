//
//  Files.swift
//  MediaApp
//
//  File contains struct for creating files
//  and a struct for creating an array of files.
//
//  Created by Daniela Lemow and Megan Seto on 26/09/18.
//  Copyright © 2018 Megan Seto. All rights reserved.
//

import AppKit


/// Struct creates Files
/// Files are used to populate the tables/lists and hold imported data
public struct File: CustomDebugStringConvertible {
    
    typealias MMMetadata = Metadata
    
    let name: String
    let type: String
    let creator: String
    let resolution: String
    let runtime: String
    let url: String
    var metadata : [MMMetadata]
    var notes : String
    
    //file initialiser to create new file
    init(fileURL: String, name: String, type: String, creator: String, resolution: String, runtime: String, metadata: [MMMetadata]) {
        self.name = name
        self.type = type
        self.creator = creator
        self.resolution = resolution
        self.runtime = runtime
        self.url = fileURL
        self.notes = ""
        
        var copyData = metadata //copy the data so it can be modified
        
        //find the index that the piece of metadata with the key 'notes' exists at
        var removeIndex : Int = -1
        for i in 0..<copyData.count where copyData[i].keyword == "notes" {
            removeIndex = i
        }
        
        //copy the value for the piece of metadata with the key notes
        //to the notes field, then remove the piece of metadata with the key 'notes'
        if removeIndex > -1 {
            self.notes = copyData[removeIndex].value
            copyData.remove(at: removeIndex)
        }
        
        
        //Find the filter category specific to the file and remove it from the metadata
        if (type == "document") {
            var removeIndex : Int = -1
            for i in 0..<copyData.count where copyData[i].keyword == "-d" && copyData[i].value == "document"{
                removeIndex = i
            }
            if removeIndex > -1 {
                copyData.remove(at: removeIndex)
            }
        } else if (type == "audio") {
            var removeIndex : Int = -1
            for i in 0..<copyData.count where copyData[i].keyword == "-a" && copyData[i].value == "audio"{
                removeIndex = i
            }
            if removeIndex > -1 {
                copyData.remove(at: removeIndex)
            }
        } else if (type == "image") {
            var removeIndex : Int = -1
            for i in 0..<copyData.count where copyData[i].keyword == "-i" && copyData[i].value == "image"{
                removeIndex = i
            }
            if removeIndex > -1 {
                copyData.remove(at: removeIndex)
            }
        } else if (type == "video") {
            var removeIndex : Int = -1
            for i in 0..<copyData.count where copyData[i].keyword == "-v" && copyData[i].value == "video"{
                removeIndex = i
            }
            if removeIndex > -1 {
                copyData.remove(at: removeIndex)
            }
        }
        
        //set the files metadata to the modified metadata
        self.metadata = copyData
    }
    
    //String used for debugging.
    public var debugDescription: String {
        return name + " resolution: \(resolution) runtime: \(runtime) Type: \(type) Creator: \(creator)"
    }
    
    //Returns a files MMMetadata and stores the notes field as a piece of metadata
    func toMMMetadata() -> [MMMetadata] {
        var copyData = metadata
        copyData.append(MMMetadata(keyword: "notes", value: self.notes))
        return copyData
    }
}

/// Struct for creating an array of files
/// Files struct holds all of the successfully imported Files
public struct Files {
     var bookmarkTitle = ""
     var files: [File] = []
    
    //Files initialiser
    init(files: [File], name: String) {
        self.bookmarkTitle = name
        self.files = files
    }
}
