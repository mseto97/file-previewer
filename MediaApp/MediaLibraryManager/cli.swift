//
//  cli.swift
//  MediaLibraryManager
//  COSC346 S2 2018 Assignment 1
//
//  Created by Paul Crane on 21/06/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//
import Foundation

/// The list of exceptions that can be thrown by the CLI command handlers
enum MMCliError: Error {
    
    /// Thrown if there is something wrong with the input parameters for the command
    case invalidParameters
    
    /// Thrown if there is no result set to work with (and this command depends on the previous command)
    case missingResultSet
    
    /// Thrown when the command is not understood
    case unknownCommand
    
    /// Thrown if the command has yet to be implemented
    case unimplementedCommand
    
    /// Thrown if there is no command given
    case noCommand
    
    // Thrown if there are no files in the library
    case emptyLibrary
}

/// Generate a friendly prompt and wait for the user to enter a line of input
/// - parameter prompt: The prompt to use
/// - parameter strippingNewline: Strip the newline from the end of the line of
///   input (true by default)
/// - return: The result of `readLine`.
/// - seealso: readLine
func prompt(_ prompt: String, strippingNewline: Bool = true) -> String? {
    // the following terminator specifies *not* to put a newline at the
    // end of the printed line
    print(prompt, terminator:"")
    return readLine(strippingNewline: strippingNewline)
}

/// This class represents a set of results.
class MMResultSet{
    
    typealias MMFile = Media
    
    /// The list of files produced by the command
    private var results: [MMFile]
    
    /// Constructs a new result set.
    /// - parameter results: the list of files produced by the executed
    /// command, could be empty.
    init(_ results:[MMFile]){
        self.results = results
    }
    /// Constructs a new result set with an empty list.
    convenience init(){
        self.init([MMFile]())
    }
    
    /// If there are some results to show, enumerate them and print them out.
    /// - note: this enumeration is used to identify the files in subsequent
    /// commands.
    func showResults(){
        guard self.results.count > 0 else{
            return
        }
        for (i,file) in self.results.enumerated() {
            print("\(i): \(file)")
        }
    }
    
    /// Determines if the result set has some results.
    /// - returns: True if there are results in this set
    func hasResults() -> Bool{
        return self.results.count > 0
    }
    
    /// Returns the results data field allowing the results to be accesssed.
    /// - returns: The results contained in the Result Set.
    func getResults() -> [MMFile] {
        return self.results
    }
}

/// The interface for the command handler.
protocol MMCommandHandler{
    
    /// The handle function executes the command.
    ///
    /// - parameter params: The list of parameters to the command. For example,
    /// typing 'load foo.json' at the prompt will result in params containing
    /// *just* the foo.json part.
    ///
    /// - parameter last: The previous result set, used to give context to some
    /// of the commands that add/set/del the metadata associated with a file.
    ///
    /// - Throws: one of the `MMCliError` exceptions
    ///
    /// - returns: an instance of `MMResultSet`
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet;
    
    /// Takes a list of parameters and determines if any key value pairs
    /// have values which contain more than one word.
    ///
    /// - parameter parts: A list of params taken from main.
    ///
    /// - returns: An array of String where values that were originally
    /// wrapped in single quotations have been concatenated into one String.
    static func processInput(from parts: [String]) -> [String]
    
    /// Takes a list of parameters and determines if any parameters are
    /// composed of more than one word.
    ///
    /// - parameter parts: A list of params taken from main.
    ///
    /// - returns: An array of String where values that were originally
    /// wrapped in single quotations have been concatenated into one String.
    static func listInput(from parts: [String]) -> [String]
    
}

extension MMCommandHandler {
    
    /// Takes a list of parameters and determines if any key value pairs
    /// have values which contain more than one word.
    ///
    /// - parameter parts: A list of params taken from main.
    ///
    /// - returns: An array of String where values that were originally
    /// wrapped in single quotations have been concatenated into one String.
    static func processInput(from parts: [String]) -> [String] {
        
        var jointTerms : [String : String] = [:] // A dictionary to store the key followed by the value
        var termsToRemove : [String] = [] // Words that will need removed from the input parts
        var key = "" //A String to store the term's key in
        var firstWord : String = "" // A String to store the first word of the joint value in
        var middleWords : [String] = [] // An array to store the word between the first word and the last word
        var sequenceStarted = false // Indicates if a sequence has begun or not
        
        //For each part in parts
        for i in 0...parts.count-1 {
            
            //If the part we are looking at begins with a single quotation, we know we are at the start of a multiworded value
            if (parts[i].starts(with: "\'")) {
                key = parts[i-1] //Store the keyword for the value
                sequenceStarted = true //Set to true to indicate a sequence of words has begun
                firstWord = parts[i] //Store the first word
                termsToRemove.append(parts[i]) //Add the first word to our termsToRemove list
                
            } else if (parts[i].last! == "\'") {
                //If the part we are looking at ends with a single quotation,
                //we know we are at the end of a multiworded value
                
                sequenceStarted = false //Set to false to indicate we are no longer in a sequence
                var jointTerm = firstWord + " " //Add the first word to the joined term
                termsToRemove.append(parts[i]) //Add the last word to the terms to remove list
                //add all the words in the middle of the term to the result
                for word in middleWords {
                    jointTerm += (word + " ")
                }
                
                //Store the joined term with reference to its key, so that we can determine where to place it in the results list
                jointTerms[key] = (jointTerm + parts[i]).replacingOccurrences(of: "'", with: "")
                
            } else if (sequenceStarted == true) {
                //If the word does not begin or end with a single quotation, and a sequence has been started,
                //we know it belongs in the middle of the sequence
                middleWords.append(parts[i])
                termsToRemove.append(parts[i])
            }
            
        }
        
        var results = parts.filter( {!termsToRemove.contains($0)}) // Remove the terms to remove from the original array

        // For each joint term
        for term in jointTerms {
            // Find the index of the joint term's key
            let insertLocation = results.index(of: term.key)
            
            // If the key exists, insert the joint term in front of they key
            if insertLocation != nil {
                results.insert(term.value, at: insertLocation!+1)
            }
        }
        
        //Return the processed parts
        return results
        
    }
    
    /// Takes a list of parameters and determines if any parameters are
    /// composed of more than one word.
    ///
    /// - parameter parts: A list of params taken from main.
    ///
    /// - returns: An array of String where values that were originally
    /// wrapped in single quotations have been concatenated into one String.
    static func listInput(from parts: [String]) -> [String] {
        
        var jointTerms : [String] = []
        var termsToRemove : [String] = []
        var firstWord : String = ""
        var middleWords : [String] = []
        var sequenceStarted = false
        
        if parts.isEmpty {
            return []
        }
        for i in 0...parts.count-1 {
            
            if (parts[i].starts(with: "\'")) {
                sequenceStarted = true
                firstWord = parts[i].replacingOccurrences(of: "'", with: "")
                termsToRemove.append(parts[i])
                
            } else if (parts[i].last! == "\'") {
                
                sequenceStarted = false
                var jointTerm = firstWord + " "
                termsToRemove.append(parts[i])
                for word in middleWords {
                    jointTerm += (word + " ")
                }
                
                jointTerms.append(jointTerm + parts[i].replacingOccurrences(of: "'", with: ""))
            } else if (sequenceStarted == true) {
                middleWords.append(parts[i])
                termsToRemove.append(parts[i])
            }
            
        }
        
        var results = parts.filter( {!termsToRemove.contains($0)})
        
        results.append(contentsOf: jointTerms)
        
        return results
        
    }
    
}

/// Handles the 'help' command -- prints usage information
/// - Attention: There are some examples of the commands in the source code
/// comments
class HelpCommandHandler: MMCommandHandler{
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet{
        print("""
\thelp                              - this text
\tload <filename> ...               - load file into the collection
\tlist <term> ...                   - list all the files that have the term specified
\tlist                              - list all the files in the collection
\tadd <number> <key> <value> ...    - add some metadata to a file
\tset <number> <key> <value> ...    - this is really a del followed by an add
\tdel <number> <key> ...            - removes a metadata item from a file
\tsave-search <filename>            - saves the last list results to a file
\tsave <filename>                   - saves the whole collection to a file
\ttest                              - runs unit tests for program
\tquit                              - quit the program
""")
        return MMResultSet()
    }
}

/// Handle the 'quit' command
class QuitCommandHandler : MMCommandHandler{
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        
        let resultFiles = last.getResults()
        let exporter = IEManager()
        
        // If the last result set contains files, we know the last search has not been saved
        if resultFiles.count > 0 {
            
            //prompt the user to save their results
            print("Your results from the previous search have not been saved. Would you like to save them before exiting? (y/n)")
            print("> ", terminator: "")
            var response = readLine(strippingNewline: true)!
            
            // If they enter an invalid response, print an error message and ask for valid input
            while (!(response == "y" || response == "n")) {
                print("\"\(response)\" is not a valid response -- please enter 'y' for yes or 'n' for no.")
                print("> ", terminator: "")
                response = readLine(strippingNewline: true)!
            }
            
            //If the user answers 'y'
            if response == "y" {
                print("Please enter the directory you would like your file saved in: ")
                print("> ", terminator: "")
                //Get the path to where the user would like their file saved
                if let directory = readLine() {
                    //Call the write function with the appropriate filename and result files
                    try exporter.write(filename: directory, items: resultFiles)
                  
                }
            }
            
        }
        
        exit(0)
    }
}

// All the other commands are unimplemented
class UnimplementedCommandHandler: MMCommandHandler{
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        throw MMCliError.unimplementedCommand
    }
}

/// Handles the 'load' command
class LoadCommandHandler : MMCommandHandler {
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        
        //If no file to load is specified, throw invalidParameters
        guard !params.isEmpty else {
            throw MMCliError.invalidParameters
        }
        
        typealias MMFile = Media
        
        let importHandler = IEManager()
        var loadedfiles : [MMFile] = []
        
        //For each file specified, load the contents into the media library, and add the loaded files to a list
        for filename in params {
            do {
                try loadedfiles.append(contentsOf: importHandler.read(filename: filename))
            } catch ImportExportError.invalidFilepath {
                print("File path: \"\(importHandler.getFilePath(from: filename))\" does not exist -- please try again with a valid path. ")
            }
        }
        
        //Return a result set containing the files that have been loaded in to the library
        return MMResultSet(loadedfiles)
    }
}

/// Handles the 'list' command
class ListCommandHandler : MMCommandHandler {
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        
        typealias MMFile = Media
        
        let library = Library()
        var resultFiles : [MMFile] = []
        //Check if the parameters contain any multiworded search terms
        let processedParams = listInput(from: params)
        
        //If no term to search for is specified, return all files in the collection
        if processedParams.isEmpty {
            resultFiles = library.all()
            guard !resultFiles.isEmpty else {
                throw MMCliError.emptyLibrary
            }
            //If the first parameter is a filtering option
        } else if ["-a", "-d", "-v", "-i"].contains(processedParams[0]) {
            //Call the filterBy method
            resultFiles = library.filterBy(by: processedParams)
        } else {
            //Otherwise search for each term in processed params, and
            //append the results if they aren't already contained in the resultFiles
            for term in processedParams {
                let search = library.search(term: term)
                for file in search {
                    if !resultFiles.contains(file) {
                        resultFiles.append(contentsOf: library.search(term: term))
                    }
                }
            }
        }
        
        if resultFiles.isEmpty {
            print("No files with metadata containing the key(s) \(processedParams) found.")
        }
        
        return MMResultSet(resultFiles)
    }
    
}

/// Handles the 'add' command
class AddCommandHandler : MMCommandHandler {
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        
        typealias MMFile = Media
        
        let library = Library()
        let resultFiles = last.getResults()
        let resultSize = resultFiles.count;
        let processedParams = processInput(from: params)
        
        //Check there is a previous result set to work with
        guard !resultFiles.isEmpty else {
            throw MMCliError.missingResultSet
        }
        
        //If the first parameter cannot be converted to an integer representing the index of the result file to modify, throw invalid parameters
        guard let fileToModify = Int(processedParams[0]) else {
            throw MMCliError.invalidParameters
        }
        
        //If the fileToModify index is greater than the number of files in the result set, or there are an uneven number of key value pairs, throw invalid parameters
        guard fileToModify <= resultSize-1 && (processedParams.count-1) % 2 == 0 else {
            throw MMCliError.invalidParameters
        }
        
        //Add the new pieces of metadata of the specified file
        for i in stride(from: 2, to: processedParams.count, by: 2) {
            library.add(metadata: Metadata(keyword: processedParams[i-1], value: processedParams[i]), file:  resultFiles[fileToModify])
        }
        
        return MMResultSet()
    }
}

/// Handles the 'del' command
class DelCommandHandler : MMCommandHandler {
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        
        let library = Library()
        let resultFiles = last.getResults()
        
        //Check there is a previous result set to work with
        guard !resultFiles.isEmpty else {
            throw MMCliError.missingResultSet
        }
        
        //If the first parameter cannot be converted to an integer representing the index of the result file to modify, throw invalid parameters
        guard let fileToModify = Int(params[0]) else {
            throw MMCliError.invalidParameters
        }
        
        //For each key to be deleted, remove the metadata with the corresponding key from the fileToModify
        for i in 1...(params.count-1) {
            library.removeFileData(file: resultFiles[fileToModify], key: params[i])
        }
        
        return MMResultSet()
    }
    
}

/// Handles the 'save' command
class SaveCommandHandler : MMCommandHandler {
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        
        let exportHandler = IEManager()
        let library = Library()
        
        //If no file to write to is specified, or there is more than one file specified throw invalidParameters
        guard !params.isEmpty && params.count == 1 else {
            throw MMCliError.invalidParameters
        }
        
        //Write the contents of the library to the specified location
        let filename = params[0]
        try exportHandler.write(filename: filename, items: library.all())
        
        return MMResultSet()
    }
}

/// Handles the 'search-save' command
class SearchSaveCommandHandler : MMCommandHandler {
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        
        let exportHandler = IEManager()
        let resultFiles = last.getResults()
        
        //Check there is a previous result set
        guard !resultFiles.isEmpty else {
            throw MMCliError.missingResultSet
        }
        
        //If no file to write to is specified, or there is more than one file specified throw invalidParameters
        guard !params.isEmpty && params.count == 1 else {
            throw MMCliError.invalidParameters
        }
        
        //Write the results from the previous search to the specified location
        let filename = params[0]
        try exportHandler.write(filename: filename, items: resultFiles)
        
        return MMResultSet()
    }
}

/// Handles the 'set' command
class SetCommandHandler : MMCommandHandler {
    
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        
        let library = Library()
        let resultFiles = last.getResults()
        let resultSize = resultFiles.count
        let processedParams = processInput(from: params)
        
        //Check there is a previous result set
        guard !resultFiles.isEmpty else {
            throw MMCliError.missingResultSet
        }
        
        //If the first parameter cannot be converted to an integer representing the index of the result file to modify, throw
        //invalid parameters
        guard let fileToModify = Int(processedParams[0]) else {
            throw MMCliError.invalidParameters
        }
        
        //If the fileToModify index is greater than the number of files in the result set, or there is an uneven number of parameters, throw invalid parameters
        guard fileToModify <= resultSize-1 && (processedParams.count-1) % 2 == 0 else {
            throw MMCliError.invalidParameters
        }
        
        //For each key-value pair
        for i in stride(from: 2, to: processedParams.count, by: 2) {
            
            //Delete the existing piece of metadata from the file, and add the new piece of metadata to the specified file
            library.removeFileData(file: resultFiles[fileToModify], key: processedParams[i-1])
            library.add(metadata: Metadata(keyword: processedParams[i-1], value: processedParams[i]), file: resultFiles[fileToModify])
        }
        
        return MMResultSet()
    }
    
}


