//
//  MediaFileTesting.swift
//  UnitTesting
//
//  Created by Daniela Lemow on 1/09/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import XCTest

class MediaFileTesting: XCTestCase {
    
    /* Initialise one of each type of Media file for testing the Media class methods on */
    var documentFile = Document(filename: "book.pdf", path: "/path/test/book.pdf", type: "document", metadata: [Metadata(keyword: "creator", value: "Fake Author")])
    var imageFile = Image(filename: "image.png", path: "/test/path/image.png", type: "image",
                      metadata: [Metadata(keyword: "creator", value: "Fake Photographer"), Metadata(keyword: "resolution", value: "1024x768")])
    var audioFile = Audio(filename: "song.mp3", path: "/test/path/song.mp3", type: "audio", metadata: [Metadata(keyword: "creator", value: "Fake Musician"), Metadata(keyword: "runtime", value: "78:58")])
    var videoFile = Video(filename: "movie.mov", path: "/test/path/movie.mov", type: "video", metadata: [Metadata(keyword: "creator", value: "Fake Director"), Metadata(keyword: "resolution", value: "1024x768"), Metadata(keyword: "runtime", value: "120:56")])
    
    /*Duplicate files identical to the ones defined above for testing the overridden == method */
    var documentFileCopy = Document(filename: "book.pdf", path: "/path/test/book.pdf", type: "document", metadata: [Metadata(keyword: "creator", value: "Fake Author")])
    var imageFileCopy = Image(filename: "image.png", path: "/test/path/image.png", type: "image",
                          metadata: [Metadata(keyword: "creator", value: "Fake Photographer"), Metadata(keyword: "resolution", value: "1024x768")])
    var audioFileCopy = Audio(filename: "song.mp3", path: "/test/path/song.mp3", type: "audio", metadata: [Metadata(keyword: "creator", value: "Fake Musician"), Metadata(keyword: "runtime", value: "78:58")])
    var videoFileCopy = Video(filename: "movie.mov", path: "/test/path/movie.mov", type: "video", metadata: [Metadata(keyword: "creator", value: "Fake Director"), Metadata(keyword: "resolution", value: "1024x768"), Metadata(keyword: "runtime", value: "120:56")])
    
    // This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
    }
    
    // This method is called after the invocation of each test method in the class.
    override func tearDown() {
        super.tearDown()
    }
    
    func testAddMetadata() {
        
        //Create a piece of metadata to add to the file
        let testData = Metadata(keyword: "key", value: "value")
        
        //Add the piece of metadata to the document file
        documentFile.addMetadata(data: testData)
        //Add the piece of metadata to the image file
        imageFile.addMetadata(data: testData)
        //Add the piece of metadata to the audio file
        audioFile.addMetadata(data: testData)
        //Add the piece of metadata to the video file
        videoFile.addMetadata(data: testData)
        
        //Check that each file's metadata contains the added piece of data
        XCTAssert(documentFile.metadata.contains(testData))
        XCTAssert(imageFile.metadata.contains(testData))
        XCTAssert(audioFile.metadata.contains(testData))
        XCTAssert(videoFile.metadata.contains(testData))

    }
    
    func testHasMetadata() {
        
        //Check the hasMetadata method with Metadata that we know the files include
        XCTAssertTrue(documentFile.hasMetadata(data: Metadata(keyword: "creator", value: "Fake Author")))
        
        XCTAssertTrue(imageFile.hasMetadata(data: Metadata(keyword: "creator", value: "Fake Photographer")))
        XCTAssertTrue(imageFile.hasMetadata(data: Metadata(keyword: "resolution", value: "1024x768")))
        
        XCTAssertTrue(audioFile.hasMetadata(data: Metadata(keyword: "creator", value: "Fake Musician")))
        XCTAssertTrue(audioFile.hasMetadata(data: Metadata(keyword: "runtime", value: "78:58")))
        
        XCTAssertTrue(videoFile.hasMetadata(data: Metadata(keyword: "creator", value: "Fake Director")))
        XCTAssertTrue(videoFile.hasMetadata(data: Metadata(keyword: "resolution", value: "1024x768")))
        XCTAssertTrue(videoFile.hasMetadata(data: Metadata(keyword: "runtime", value: "120:56")))
        
        //create a piece of metadata not contained by any of the test files
        let notContained = Metadata(keyword: "not contained", value: "not contained")
        
        //Check the hasMetadata method with the metadata not contained by any of the test files
        XCTAssertFalse(documentFile.hasMetadata(data: notContained))
        XCTAssertFalse(imageFile.hasMetadata(data: notContained))
        XCTAssertFalse(audioFile.hasMetadata(data: notContained))
        XCTAssertFalse(videoFile.hasMetadata(data: notContained))
        
    }
    
    func testHasMetadataByKey() {
        
        //Check the hasMetadata method with Metadata that we know the files include
        XCTAssertTrue(documentFile.hasMetadata(key: "creator"))
        
        XCTAssertTrue(imageFile.hasMetadata(key: "creator"))
        XCTAssertTrue(imageFile.hasMetadata(key: "resolution"))
        
        XCTAssertTrue(audioFile.hasMetadata(key: "creator"))
        XCTAssertTrue(audioFile.hasMetadata(key: "runtime"))
        
        XCTAssertTrue(videoFile.hasMetadata(key: "creator"))
        XCTAssertTrue(videoFile.hasMetadata(key: "runtime"))
        XCTAssertTrue(videoFile.hasMetadata(key: "resolution"))
        
        //Test if the hasMetadata method returns false when we check for keys which don't exist
        XCTAssertFalse(documentFile.hasMetadata(key: "not contained"))
        XCTAssertFalse(imageFile.hasMetadata(key: "not contained"))
        XCTAssertFalse(audioFile.hasMetadata(key: "not contained"))
        XCTAssertFalse(videoFile.hasMetadata(key: "not contained"))

    }
    
    func testRemoveMetadata() {
        
        let dataToRemove = Metadata(keyword: "data", value: "to remove")
        
        documentFile.addMetadata(data: dataToRemove)
        imageFile.addMetadata(data: dataToRemove)
        audioFile.addMetadata(data: dataToRemove)
        videoFile.addMetadata(data: dataToRemove)
        
        documentFile.removeMetadata(data: dataToRemove)
        imageFile.removeMetadata(data: dataToRemove)
        audioFile.removeMetadata(data: dataToRemove)
        videoFile.removeMetadata(data: dataToRemove)
        
        XCTAssertFalse(documentFile.hasMetadata(data: dataToRemove))
        XCTAssertFalse(imageFile.hasMetadata(data: dataToRemove))
        XCTAssertFalse(audioFile.hasMetadata(data: dataToRemove))
        XCTAssertFalse(videoFile.hasMetadata(data: dataToRemove))
        
    }
    
    func testRemoveDataByKey() throws {
        
        let dataToRemove = Metadata(keyword: "data", value: "to remove")
        
        documentFile.addMetadata(data: dataToRemove)
        imageFile.addMetadata(data: dataToRemove)
        audioFile.addMetadata(data: dataToRemove)
        videoFile.addMetadata(data: dataToRemove)
        
        try documentFile.removeMetadata(key: "data")
        try imageFile.removeMetadata(key: "data")
        try audioFile.removeMetadata(key: "data")
        try videoFile.removeMetadata(key: "data")
        
        XCTAssertFalse(documentFile.hasMetadata(data: dataToRemove))
        XCTAssertFalse(imageFile.hasMetadata(data: dataToRemove))
        XCTAssertFalse(audioFile.hasMetadata(data: dataToRemove))
        XCTAssertFalse(videoFile.hasMetadata(data: dataToRemove))
        
    }
    
    func testGetMetadata() {
        
        let documentFileData = [
            "creator" : "Fake Author"
        ]
        
        let imageFileData = [
            "creator" : "Fake Photographer",
            "resolution" : "1024x768"
        ]
        
        let audioFileData = [
            "creator" : "Fake Musician",
            "runtime" : "78:58"
        ]
        
        let videoFileData = [
            "creator" : "Fake Director",
            "resolution" : "1024x768",
            "runtime" : "120:56"
        ]
        
        let documentComparisonData = documentFile.getMetadata()
        let imageComparisonData = imageFile.getMetadata()
        let audioComparisonData = audioFile.getMetadata()
        let videoComparisonData = videoFile.getMetadata()
        
        XCTAssertTrue(documentFileData == documentComparisonData)
        XCTAssertTrue(imageFileData == imageComparisonData)
        XCTAssertTrue(audioFileData == audioComparisonData)
        XCTAssertTrue(videoFileData == videoComparisonData)
        
    }
    
    func testBooleanEquals() {
        
        //Check each file is equal to a copy of itself
        XCTAssertTrue(documentFile == documentFileCopy)
        XCTAssertTrue(imageFile == imageFileCopy)
        XCTAssertTrue(audioFile == audioFileCopy)
        XCTAssertTrue(videoFile == videoFileCopy)
        
        //Check that when files are not the same false is returned
        XCTAssertFalse(documentFile == videoFile)
        XCTAssertFalse(audioFile == imageFile)
        
    }
}
