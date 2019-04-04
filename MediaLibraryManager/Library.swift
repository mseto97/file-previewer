//
//  Library.swift
//  MediaLibraryManager
//
//  Created by Daniela Lemow on 30/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

/**
 * A class that stores and manipulates Media files.
 */

class Library : MMCollection {
    
    typealias MMMetadata = Metadata
    typealias MMFile = Media
    
    //STORED PROPERTIES
    static var files : [MMFile] = [] // A list of all the files in the library
    static var keyLibrary = [String : [MMFile]]() // A dictionary where each key has a list of files associated with it
    static var valueLibrary = [String : [MMFile]]() // A dictionary where each value has a list of files associated with it
    
    //COMPUTED PROPERTIES
    
    /**
     Converts object to a string description.
     - returns: String String description of how many files are in the library
     */
    var description: String {
        return "A collection of media containing \(Library.files.count) files."
    }
    
    ///
    /// Returns a list of all the files in the library
    ///
    /// - Parameters:
    /// - Returns:
    /// A list of all the files in the index, possibly an empty list.
    func all() -> [MMFile] {
        Library.files.sort(by: { $0.filename < $1.filename})
        return Library.files
    }
    
    ///
    /// Adds a file to the media library, and to its corresponding list.
    ///
    /// - Parameters:
    /// - file: The file to add to the collection.
    func add(file: MMFile) {
        
        // If the file already exists in the library - return and don't add it
        // We wanted to throw an error here but the add function isn't marked with
        // throw in the protocol and we didn't want to add it in case it messed
        // your tests up.
        guard !Library.files.contains(file) else {
            return
        }
        
        //Appends the file to the appropriate array(s) in the dictionary, creating the array/value if needed
        for key in file.keys {
            Library.keyLibrary.append(element: file, toValueOfKey: key)
        }
        
        //Appends the file to the appropriate array(s) in the dictionary, creating the array/value if needed
        for value in file.values {
            Library.valueLibrary.append(element: file, toValueOfKey: value)
        }
        
        //Add the file to the library and sort it by filename
        (Library.files).append(file)
        Library.files.sort(by: { $0.filename < $1.filename})
    }
    
    ///
    /// Adds a specific instance of a metadata to the collection
    ///
    /// - Parameters:
    /// - metadata: The item to add to the collection
    /// - file: The file to add the piece of metadata to
    func add(metadata: MMMetadata, file: MMFile) {
        
        //Add the metadata to the file
         file.addMetadata(data: metadata)
        
        //Add the file to the key in the inverted index
        Library.keyLibrary.append(element: file, toValueOfKey: metadata.keyword)
        Library.valueLibrary.append(element: file, toValueOfKey: metadata.value)
    }
    
    ///
    /// Removes a specific instance of a metadata from the collection
    ///
    /// - Parameters:
    /// - metadata: The item to remove from the collection
    func remove(metadata: MMMetadata) {
        
        //Get the files that match the metadata keyword from the inverted index
        if let files = Library.keyLibrary[metadata.keyword] {
            
            for f in files {
                //If any of these files have the specified metadata (which they should) remove it
                if f.hasMetadata(data: metadata) {
                    f.removeMetadata(data: metadata)
                }
            }
            
        }
        
        //Remove the key from the inverted index
        Library.keyLibrary.removeValue(forKey: metadata.keyword)
        
    }
    
    ///
    /// Finds all the files associated with the keyword
    ///
    /// - Parameters:
    /// - term: The term to search for
    /// - Returns:
    /// A list of all the files associated with the keyword, possibly an empty list.
    func search(term: String) -> [MMFile] {
        
        var results : [MMFile] = []
        
        if let filesByKey = Library.keyLibrary[term] {
            results.append(contentsOf: filesByKey)
        }
        
        if let filesByValue = Library.valueLibrary[term] {
            
            for file in filesByValue {
                if !results.contains(file) {
                    results.append(file)
                }
            }
        }
        
        return results
    }
    
    ///
    /// Returns a list the files in the library that contain the specified piece of metadata.
    /// - Parameters:
    /// - item: the piece of metadata to search for.
    /// - Returns:
    /// A list of the files containing the piece of metadata, possibly an empty list.
    func search(item: MMMetadata) -> [MMFile] {
        
        let searchByKeyword = search(term: item.keyword) //Get all the files with they key in the metadata
        let searchByValue = search(term: item.value) //Get all the files with the value in the metadata
        return searchByValue.filter( {!searchByKeyword.contains($0)}) //Remove the duplicate files and return the result
        
    }
    
    ///
    /// Returns a list of all the files of the specified category which contain
    /// the given search terms as a key in their metadata.
    ///
    /// - Parameters:
    /// - terms: An array of strings storing the keys to search for, where the first index is the category
    /// - Returns:
    /// A list of all the files from the specified category which contain the search terms in their metadata, possibly an empty list.
    func filterBy(by terms: [String]) -> [MMFile] {
        
        //remove the category from the list
        var copy = terms
        let category = copy.removeFirst()
        
        //if only one term is in the search and it is the filter search by term and return
        if terms.count == 1 && terms[0] == category {
            return search(term: category)
        }
        
        var resultFiles : [MMFile] = []
        
        //store all the files regardless of the category
        for term in copy {
            resultFiles.append(contentsOf: search(term: term))
        }
        
        var filteredResultFiles : [MMFile] = []
        
        //if the file has corresponding category metadata,
        //add it to filtered results
        for file in resultFiles {
            if file.hasMetadata(key: category) {
                filteredResultFiles.append(file)
            }
        }
        
        filteredResultFiles.sort(by: { $0.filename < $1.filename})
        return filteredResultFiles
        
    }
    
    ///
    /// Removes a piece of metadata from a specified file.
    ///
    /// - Parameters:
    /// - file: the file to remove the metadata from.
    /// - key: the key for the metadata.
    func removeFileData(file: MMFile, key: String) -> Void {
        do {
            try file.removeMetadata(key: key)
        } catch MetadataError.cannotRemoveCreator {
            print("Cannot remove creator from \(file.filename) because it is of type \(file.type)")
        } catch MetadataError.cannotRemoveResolution {
            print("Cannot remove resolution from \(file.filename) because it is of type \(file.type)")
        } catch MetadataError.cannotRemoveRuntime {
            print("Cannot remove runtime from \(file.filename) because it is of type \(file.type)")
        } catch {
            print(error.localizedDescription)
        }
    }

}

//Append an element to an array in a dictionary value, creating the array/value if needed
extension Dictionary where Value : RangeReplaceableCollection {
    
    public mutating func append(element: Value.Iterator.Element, toValueOfKey key: Key) -> Void {
        var value: Value = self[key] ?? Value()
        value.append(element)
        self[key] = value
    }
    
}
