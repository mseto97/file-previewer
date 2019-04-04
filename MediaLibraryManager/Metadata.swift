//
//  Metadata.swift
//  MediaLibraryManager
//
//  Created by Daniela Lemow on 30/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

/**
 * A struct that represents metadata for a media file.
 */

struct Metadata : MMMetadata {
    
    // STORED PROPERTIES
    
    var keyword: String // Metadata keyword
    var value: String // Metadata value
    
    //COMPUTED PROPERTIES
    
    /**
     Converts object to a string description.
     - returns: String String representation of a Metadata pair
     */
    var description: String {
        return "{\(keyword) : \(value)}"
    }
    
    // INITIALISERS
    
    /**
     Designated initialiser
     
     Keyword and value are passed in the arguments of the initialiser.
     
     - parameter keyword: The keyword for the metadata
     - parameter value: The value for the metadata
     */
    init(keyword: String, value: String) {
        self.keyword = keyword
        self.value = value
    }
    
}
