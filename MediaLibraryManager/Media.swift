//
//  Media.swift
//  MediaLibraryManager
//
//  Created by Daniela Lemow on 30/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

//The list of exceptions that can be thrown by methods in the Media class
enum MetadataError: Error {
    
    //Thrown if a piece of metadata with the key "creator" tries to be removed
    //from a file where it is a compulsory value
    case cannotRemoveCreator
    
    //Thrown if a piece of metadata with the key "runtime" tries to be removed
    //from a file where it is a compulsory value
    case cannotRemoveRuntime
    
    //Thrown if a piece of metadata with the key "resolution" tries to be removed
    //from a file where it is a compulsory value
    case cannotRemoveResolution
    
}

/**
 * Represents a Multimedia file.
 */

class Media : MMFile, Equatable {
    
    typealias MMMetadata = Metadata
    
    // STORED PROPERTIES
    var filename: String //The name of the file
    var path: String //The path to the file
    var type: String //The type of the file
    var metadata: [MMMetadata] //Metadata associated with the file
    
    //COMPUTED PROPERTIES
    
    /**
     Converts object to a string description.
     - returns: String String representation of a Media file
     */
    var description: String {
        return "\(filename)"
    }
    
    /**
     Gets the file's creator.
     - returns: String String representation of the Media file's creator
     */
    var creator : String? {
        
        for data in metadata where data.keyword == "creator" {
                return data.value
        }
        
        return nil
    }
    
    /**
     Gets the images's resolution.
     - returns: String String representation of the Image file's resolution
     */
    var resolution : String? {
        
        for data in metadata where data.keyword == "resolution"  {
                return data.value
        }
        
        return nil
    }
    
    /**
     Gets the video's runtime.
     - returns: String String representation of the Video file's runtime
     */
    var runtime : String? {
        
        for data in metadata where data.keyword == "runtime" {
                return data.value
        }
        
        return nil
    }
    
    /**
     Returns all the keys from the metadata.
     - returns: [String] An array of the keys in the metadata
     */
    var keys: [String] {
        
        var keys : [String] = []
        
        for data in metadata {
            keys.append(data.keyword)
        }
        
        return keys
    }
    
    /**
     Returns all the values from the metadata.
     - returns: [String] An array of the values in the metadata
     */
    var values : [String] {
        
        var values : [String] = []
        
        for data in metadata {
            values.append(data.value)
        }
        
        return values
    }
    
    //INITIALISERS
    
    /**
     Designated initialiser
     
     Filename, path to file, file type, and file's metadata are passed
     in the arguments of the initialiser.
     
     - parameter filename: The name of the file
     - parameter path: The full path to the file
     - parameter type: The file's type
     - parameter metadata: The file's metadata
     */
    init(filename: String, path: String, type: String, metadata : [Metadata]) {
        self.filename = filename
        self.path = path
        self.type = type
        self.metadata = metadata;
        self.metadata.sort(by: { $0.keyword < $1.keyword})
    }
    
    ///
    /// Adds a piece of metadata to the file's metadata collection.
    ///
    /// - Parameters:
    /// - data: The piece of metadata to add to the file.
    func addMetadata(data: MMMetadata) -> Void {
        metadata.append(data)
        metadata.sort(by: { $0.keyword < $1.keyword})
    }
    
    ///
    /// Checks if the file contains metadata with the specified keyword
    ///
    /// - Parameters:
    /// - key: A string to check if it is in the metadata.
    /// - Returns:
    /// True if the file has metadata matching the keyword, false if it doesn't.
    func hasMetadata(key: String) -> Bool {
        
        for data in metadata {
            if data.keyword.lowercased().contains(key.lowercased()) {
                return true
            }
        }
        
        return false
    }
    
    ///
    /// Checks if the file contains the given metadata.
    ///
    /// - Parameters:
    /// - data: The piece of metadata to check if the file contains.
    /// - Returns:
    /// True if the file has the metadata, false if it doesn't.
    func hasMetadata(data: MMMetadata) -> Bool {
        
        if metadata.contains(data) {
            return true
        }
        
        return false
    }
    
    ///
    /// Removes a piece of metadata from the file's metadata collection.
    /// - Parameters:
    /// - data: The piece of metadata to remove from the file's metadata collection.
    func removeMetadata(data: MMMetadata) -> Void {
        
        var index = 0
        
        for d in metadata {
            if d == data {
                metadata.remove(at: index)
                break
            }
            index += 1
        }
        
    }
    
    
    ///
    /// Removes a piece of metadata from the file's metadata collection.
    ///
    /// - Parameters:
    /// - data: The piece of metadata to remove from the file.
    func removeMetadata(key: String) throws -> Void {
        
        //If the file is of type video or audio, ensure the key is not the runtime
        guard !((self.type == "video" || self.type == "audio") && key.lowercased() == "runtime") else {
            throw MetadataError.cannotRemoveRuntime
        }
        
        //If the file is of type video or image, ensure the key is not the resolution
        guard !((self.type == "video" || self.type == "image") && key.lowercased() == "resolution") else {
            throw MetadataError.cannotRemoveResolution
        }
        
        //Ensure the key is not the creator
        guard !(key.lowercased() == "creator") else {
            throw MetadataError.cannotRemoveCreator
        }
        
        var index = 0
        
        for d in metadata {
            if d.keyword.lowercased() == key.lowercased() {
                metadata.remove(at: index)
                break
            }
            index += 1
        }
        
    }
    
    //
    /// Returns the file's metadata as a dictionary that matches the media
    /// struct's metadata. Useful for file exporting.
    ///
    /// - Returns: The file's metadata in a dictionary format.
    func getMetadata() -> [String : String] {
        
        var data = [String : String]()
        
        for m in metadata {
            if !["-a", "-v", "-i", "-d"].contains(m.keyword){
                data[m.keyword] = m.value
            }
        }
        
        return data
    }

    ///
    /// Implements the boolean equals operator for two media files.
    ///
    /// - Returns:
    /// True if the Media files are the same, false if they are not.
    static func == (lhs: Media, rhs: Media) -> Bool {
        
        return lhs.filename == rhs.filename && lhs.path == rhs.path && lhs.type == rhs.type && lhs.metadata == rhs.metadata
        
    }
    
}
