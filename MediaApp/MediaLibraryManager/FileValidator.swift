//
//  FileValidator.swift
//  MediaLibraryManager
//
//  Created by Daniela Lemow on 30/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

/**
 * A class with functions that allow us to check if files are valid,
 * and if they are invalid why they are invalid.
 */
class FileValidator {
    
    typealias MMMetadata = Metadata
    typealias MMFile = Media
    
    //Array list storing legal types of files
    let LEGAL_TYPES : [String] = [
        "audio",
        "image",
        "video",
        "document"
    ]
    
    //Dictionary constant that corresponds to a valid video file
    let VALID_VIDEO : [String : Bool] = [
        "creator" : true,
        "resolution" : true,
        "runtime" : true
    ]
    
    //Dictionary constant that correspsonds to a valid image file
    let VALID_IMAGE : [String : Bool] = [
        "creator" : true,
        "resolution" : true,
        "runtime" : false
    ]
    
    //Dictionary constant that correspsonds to a valid audio file
    let VALID_AUDIO : [String : Bool] = [
        "creator" : true,
        "resolution" : false,
        "runtime" : true
    ]
    
    //Dictionary constant that correspsonds to a valid document file
    let VALID_DOCUMENT : [String : Bool] = [
        "creator" : true,
        "resolution" : false,
        "runtime" : false
    ]
    
    ///
    /// Checks if a file has a filepath and a type.
    ///
    /// - Parameters:
    /// - fullpath: the fullpath of the file
    /// - type: the type of the file
    /// - Returns:
    /// A boolean indicating if the file has a valid path and type.
    /// True for valid, false for invalid.
    func validateData(fullpath: String, type: String) -> Bool {
        
        if !fullpath.isEmpty && !type.isEmpty && LEGAL_TYPES.contains(type.lowercased()) {
            return true
        }
        return false
        
    }
    
    ///
    /// Checks if a file has the needed metadata.
    ///
    /// - Parameters:
    /// - type: The type of file we are checking i.e. document, audio, image, video.
    /// - checks: A dictionary indicating if key metadata exists.
    /// - Returns:
    /// A boolean indicating if the file is valid. True for valid, false for invalid.
    func validateMetadata(type: String, checks: [String : Bool]) -> Bool {
        
        switch(type) {
        case "document":
            if checks == VALID_DOCUMENT {
                return true
            }
            break
        case "audio":
            if checks == VALID_AUDIO {
                return true
            }
            break
        case "image":
            if checks == VALID_IMAGE {
                return true
            }
            break
        case "video":
            if checks == VALID_VIDEO {
                return true
            }
            break
        default:
            return false
        }
        
        return false
    }
    
    ///
    /// This function should only be called if a file is invalid. It checks why
    /// the file is invalid (which could be because of multiple missing data) and
    /// adds the corresponding error message to an array containing error messages.
    ///
    /// - Parameters:
    /// - fullpath: The fullpath of the file we are checking
    /// - type: The type of file we are checking i.e. document, audio, image, video.
    /// - checks: A dictionary indicating if key metadata exists.
    /// - Returns:
    /// An array of Strings containing the appropriate error messages for the invalid
    /// file.
    func getErrorMessages(fullpath: String, type: String, checks: [String : Bool])  -> [String] {
        
        //An empty array to store the appropriate error messages
        var errorMessages : [String] = []
        
        //Check if the file has a fullpath
        if fullpath.isEmpty {
            errorMessages.append("does not contain a fullpath")
        }
        
        //Check is the file has a type or valid type
        if type.isEmpty {
            errorMessages.append("does not contain a type - may be missing metadata")
        } else if !LEGAL_TYPES.contains(type.lowercased()) {
            errorMessages.append("\"\(type)\" is not a valid file type")
        }
        
        //Check if the file has a creator
        if !checks["creator"]! {
            errorMessages.append("does not contain a creator")
        }
        
        //If we know what the type of file is, then check the metadata
        if !type.isEmpty && LEGAL_TYPES.contains(type.lowercased()) {
            
            //If the file is an image or a video, check if it has a resolution
            if (type == "image" || type == "video") && !checks["resolution"]! {
                errorMessages.append("does not contain a resolution")
                
            }
            
            //If the file is a video or an audio file, check if it has a runtime
            if (type == "audio" || type == "video") && !checks["runtime"]! {
                errorMessages.append("does not contain a runtime")
                
            }
        }
        
        //return the corresponding error messages
        return errorMessages
        
    }
    
    ///
    /// This function takes a file and checks its metadata to see if it contains
    /// a creator, resolution, and runtime
    ///
    /// - Parameters:
    /// - file: The file to be checked
    /// - Returns:
    /// A dictionary with boolean values indicating if the creator, resolution and
    /// runtime exist.
    func getChecks(from file: MMFile) -> [String : Bool] {
        
        var checks : [String : Bool] = [
            "creator" : false,
            "resolution" : false,
            "runtime" : false
        ]
        
        for data in file.metadata {
            if data.keyword.lowercased() == "creator" && !data.value.isEmpty {
                checks["creator"] = true
            }
            if data.keyword.lowercased() == "resolution" && !data.value.isEmpty {
                checks["resolution"] = true
            }
            if data.keyword.lowercased() == "runtime" && !data.value.isEmpty {
                checks["runtime"] = true
            }
        }
        
        return checks
    }

}
