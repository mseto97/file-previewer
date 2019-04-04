//
//  IEManagerTesting.swift
//  UnitTesting
//
//  Created by Daniela Lemow on 1/09/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import XCTest

class IEManagerTesting: XCTestCase {
    
    var testBundle : Bundle?
    var testLibrary = Library()
    var testIEManager = IEManager()
    
    // This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
        testBundle = Bundle(for: type(of: self))
    }
    
    // This method is called after the invocation of each test method in the class.
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetFilename() {
        
        var fullpath = "/videos/movies/die-hard.mov"
        var filename = testIEManager.getFilename(from: fullpath)
        
        XCTAssert(filename == "die-hard.mov")
        
        fullpath = "die-hard.mov"
        filename = testIEManager.getFilename(from: fullpath)
        
        XCTAssert(filename == "die-hard.mov")
        
    }
    
    func testRead() {
        
        //test-1 contains one of each type of media, containing the required metadata.
        let fileUrl = testBundle?.url(forResource: "test-1", withExtension: ".json", subdirectory: "test-files")
        
        //create four files with identical data to the files contained in test-1.json
        //these can be used to check if the result set and library contain the loaded files
        let file1 = Image(filename: "image.png", path: "/path/image.png", type: "image",
                          metadata: [Metadata(keyword: "creator", value: "John Smith"), Metadata(keyword: "resolution", value: "1024x768")])
        let file2 = Video(filename: "movie.mov", path: "/path/test/movie.mov", type: "video",
                          metadata: [Metadata(keyword: "creator", value: "Mary Duncan"), Metadata(keyword: "resolution", value: "1024x768"), Metadata(keyword: "runtime", value: "119:23")])
        let file3 = Document(filename: "the-book-thief.pdf", path: "/path/test/the-book-thief.pdf", type: "document",
                             metadata: [Metadata(keyword: "creator", value: "Markus Zusak")])
        let file4 = Audio(filename: "song.mp3", path: "/path/test/song.mp3", type: "audio",
                          metadata: [Metadata(keyword: "creator", value: "The Smiths"), Metadata(keyword: "runtime", value: "03:45")])
        
        if let relPath = fileUrl?.relativePath {
            
            do {
                
                //call the read function for the IEManager
                let loadedFiles = try testIEManager.read(filename: relPath)
                
                //Check that the result set from the read function contains all four files
                XCTAssertTrue(loadedFiles.contains(file1))
                XCTAssertTrue(loadedFiles.contains(file2))
                XCTAssertTrue(loadedFiles.contains(file3))
                XCTAssertTrue(loadedFiles.contains(file4))
                
                //Check that all four files have been saved in the library
                XCTAssertTrue(Library.files.contains(file1))
                XCTAssertTrue(Library.files.contains(file2))
                XCTAssertTrue(Library.files.contains(file3))
                XCTAssertTrue(Library.files.contains(file4))
                
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}
