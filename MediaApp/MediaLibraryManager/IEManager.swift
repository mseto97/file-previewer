//
//  IEManager.swift
//  MediaLibraryManager
//
//  Created by Daniela Lemow on 31/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

/**
 * Custom errors for the import and export of files
 */
enum ImportExportError: Error {
    
    /// Thrown if the filepath does not exist
    case invalidFilepath
    
    /// Thrown if a file does not exist after it has been saved
    case fileNotSaved
    
}

/**
 * A class to manage importing and exporting MMFiles.
 */
class IEManager : MMFileImport, MMFileExport {
    
    typealias MMMetadata = Metadata
    typealias MMFile = Media
    
    /* An instance of library to store files in and retrieve files from. */
    let library = Library()
    
    /* A struct to store information from JSON files. */
    struct MediaStruct : Codable {
        let fullpath : String
        let type : String
        let metadata : [String: String]
    }
    
    /// Imports files into the media collection from a specified file.
    ///
    /// - Parameters:
    /// - filename: The filename given by the user to import files from.
    /// - Returns:
    /// A list of the successfully imported files.
    func read(filename: String) throws -> [MMFile] {
        
        let fileFullPath = getFilePath(from: filename)
        // Check that the given path to file exists, otherwise throw invalid filepath error
        guard FileManager.default.fileExists(atPath: fileFullPath) else {
            throw ImportExportError.invalidFilepath
        }
        
        //Create array to store successfully imported files
        var valid : [MMFile] = []
        
        //create a new instance of FileValidator to use for validating files
        let fvalidate = FileValidator()
        
        do {
            
            //Read the data from the JSON file
            let data = try Data(contentsOf: URL(fileURLWithPath: fileFullPath))
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode([MediaStruct].self, from: data)
            
            var allValid = true
            
            //For each Media Struct read from file
            for m in jsonData {
                
                //Create a dictionary to indicate if the media we are looking at contains a creator, resolution,
                //and runtime. True indicates it does contain that piece of metadata, false indicates it does not
                //(defaults to false).
                var checks : [String : Bool] = [
                    "creator" : false,
                    "resolution" : false,
                    "runtime" : false
                ]
                
                // Get and store filename
                let mediafilename = getFilename(from: m.fullpath)
                
                //Create an Array of Metadata from the JSON data. If the piece of Metadata we are looking at
                //has the keyword creator, resolution, or runtime and its value is not empty, the checks dictionary
                //will be updated to reflect this.
                var data = [Metadata]()
                for d in m.metadata {
                    let temp = Metadata(keyword: d.key, value: d.value)
                    if temp.keyword.lowercased() == "creator" && !temp.value.isEmpty {
                        checks["creator"] = true
                    }
                    if temp.keyword.lowercased() == "resolution" && !temp.value.isEmpty {
                        checks["resolution"] = true
                        
                    }
                    if temp.keyword.lowercased() == "runtime" && !temp.value.isEmpty {
                        checks["runtime"] = true
                    }
                    data.append(temp)
                }
                
                //Check if the file contains a fullpath and a valid type
                if fvalidate.validateData(fullpath: m.fullpath, type: m.type) {
                    // Deal with the appropriate type of media. If the media is valid, instantiate the
                    // corresponding Media subclass and add it to both the library and valid file list
                    if fvalidate.validateMetadata(type: m.type, checks: checks){
                        
                        if m.type == "document" {
                            let file = Document(filename: mediafilename, path: m.fullpath, type: m.type, metadata: data)
                            library.add(file: file)
                            valid.append(file)
                        }
                        
                        if m.type == "audio" {
                            let file = Audio(filename: mediafilename, path: m.fullpath, type: m.type, metadata: data)
                            library.add(file: file)
                            valid.append(file)
                        }
                        
                        if m.type == "image" {
                            let file = Image(filename: mediafilename, path: m.fullpath, type: m.type, metadata: data)
                            library.add(file: file)
                            valid.append(file)
                        }
                        if m.type == "video" {
                            let file = Video(filename: mediafilename, path: m.fullpath, type: m.type, metadata: data)
                            library.add(file: file)
                            valid.append(file)
                        }
                    }
                }
                
                //If the file is invalid, find the appropriate errors and print them
                if !fvalidate.validateData(fullpath: m.fullpath, type: m.type) || !fvalidate.validateMetadata(type: m.type, checks: checks) {
                    
                    if (allValid) {
                        print("> Files not successfully imported for \(filename):")
                        print()
                        allValid = false
                    }
                    
                    if !m.fullpath.isEmpty {
                        print("\t\(m.fullpath):")
                    } else {
                        print("\tThis piece of media did not contain a path -- it was not added to the library.")
                    }
                    let errorMessages = fvalidate.getErrorMessages(fullpath: m.fullpath, type: m.type, checks: checks)
                    for e in errorMessages {
                        print("\t* \(e)")
                    }
                    print()
                    
                }
            }
        } catch {
            print("\tIssue with \(fileFullPath): \(error.localizedDescription)")
        }
        
        //Return a list of the valid files that were imported successfully
        return valid.sorted(by: { $0.filename < $1.filename})
        
    }
    
    /// Exports a list of media files into the given filename.
    ///
    /// - Parameters:
    /// - filename: The filepath given by the user to write media file JSON data to.
    func write(filename: String, items: [MMFile]) throws {
        
        let validate = FileValidator()
        let encoder = JSONEncoder()
        var fileLocation = getFilePath(from: filename)
        var dataToBeWritten : [MediaStruct] = []
        
        for file in items {
            //If the file has the valid metadata, create a media struct and add it to the data to be written
            let checks = validate.getChecks(from: file)
            if validate.validateMetadata(type: file.type, checks: checks) {
                let m = MediaStruct(fullpath: file.path, type: file.type, metadata: file.getMetadata())
                dataToBeWritten.append(m)
            }
        }
        
        //Encode the data
        let jsonData = try encoder.encode(dataToBeWritten)
        
        //If the file already exists, make the user choose another file name so it is not overwritten
        while (FileManager.default.fileExists(atPath: fileLocation)) {
            print("The file \"\(getFilePath(from: filename))\" already exists -- please enter another filename:")
            print("> ", terminator: "")
            let response = readLine(strippingNewline: true)!
            fileLocation = getFilePath(from: response)
        }
        
        //Write the data to the specified location
        do {
            try jsonData.write(to: URL(fileURLWithPath: fileLocation))
        } catch {
            print(error.localizedDescription)
        }
        
        //If the file has been written, print a success messages
        if !FileManager.default.fileExists(atPath: fileLocation) {
            print("Data has been successfully saved.")
        }
        
    }
    
    /// A helper function that takes a raw path and determines if it should be read from the current working
    /// directory, the users home directory, or treated as a fullpath.
    ///
    /// - Parameters:
    /// - rawpath: The raw path to manipulate the full path to a file from.
    /// - Returns:
    /// The full path needed to locate the specified file.
    func getFilePath(from rawPath: String) -> String {
        
        var finalPath = ""
        let fileManager = FileManager.default
        
        //if the raw path has a ~ at the beginning, get the home directory for the current user and replace the ~ with it.
        if rawPath.starts(with: "~") {
            let userDirectory = (fileManager.homeDirectoryForCurrentUser).absoluteString
            let tempPath = rawPath.replacingOccurrences(of: "~/", with: userDirectory)
            finalPath = tempPath.replacingOccurrences(of: "file://", with: "")
        } else if !rawPath.contains("/") {
            //If there is no path preceeding the filename, find the path to the current directory and add it to the originalPath
            finalPath = fileManager.currentDirectoryPath + "/" + rawPath
        }
        
        if !finalPath.isEmpty {
            return finalPath
        }
        
        //Return the original raw path if it turns out to be the full path to the file
        return rawPath
        
    }
    
    /// A helper function that takes a full path and returns only the filename.
    ///
    /// - Parameters:
    /// - path: The fullpath to find the filename from.
    /// - Returns:
    /// The filename taken from the fullpath.
    func getFilename(from path: String) -> String {
        
        if path.contains("/") {
            var pieces = path.split(separator: "/")
            return String(pieces[pieces.count-1])
        }
        
        return path
    }
    
}
