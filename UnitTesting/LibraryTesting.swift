//
//  LibraryTesting.swift
//  UnitTesting
//
//  Created by Daniela Lemow on 1/09/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import XCTest

class LibraryTesting: XCTestCase {
    
    let testingLibrary = Library()
    
    /* Initialise one of each type of Media file for testing the Media class methods on */
    var documentFile = Document(filename: "book.pdf", path: "/path/test/book.pdf", type: "document", metadata: [Metadata(keyword: "creator", value: "Fake Author")])
    var documentFile2 = Document(filename: "book2.pdf", path: "/path/test/book2.pdf", type: "document", metadata: [Metadata(keyword: "creator", value: "Fake Author")])
    var imageFile = Image(filename: "image.png", path: "/test/path/image.png", type: "image",
                          metadata: [Metadata(keyword: "creator", value: "Fake Photographer"), Metadata(keyword: "resolution", value: "1024x768")])
    var imageFile2 = Image(filename: "image2.png", path: "/test/path/image.png2", type: "image",
                           metadata: [Metadata(keyword: "creator", value: "Fake Photographer2"), Metadata(keyword: "resolution", value: "1024x700")])
    var audioFile = Audio(filename: "song.mp3", path: "/test/path/song.mp3", type: "audio", metadata: [Metadata(keyword: "creator", value: "Fake Musician"), Metadata(keyword: "runtime", value: "78:58")])
    var audioFile2 = Audio(filename: "song2.mp3", path: "/test/path/song2.mp3", type: "audio", metadata: [Metadata(keyword: "creator", value: "Fake Composer"), Metadata(keyword: "runtime", value: "78:58")])
    var videoFile = Video(filename: "movie.mov", path: "/test/path/movie.mov", type: "video", metadata: [Metadata(keyword: "creator", value: "Fake Director"), Metadata(keyword: "resolution", value: "1024x768"), Metadata(keyword: "runtime", value: "120:56")])
    var videoFile2 = Video(filename: "movie2.mov", path: "/test/path/movie2.mov", type: "video", metadata: [Metadata(keyword: "creator", value: "Fake Director2"), Metadata(keyword: "resolution", value: "1024x768"), Metadata(keyword: "runtime", value: "120:56")])
    // This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
    }
    
    // This method is called after the invocation of each test method in the class.
    override func tearDown() {
        super.tearDown()
    }
    
    func testAdd() {
        
        testingLibrary.add(file: documentFile)
        testingLibrary.add(file: imageFile)
        testingLibrary.add(file: audioFile)
        testingLibrary.add(file: videoFile)
        
        XCTAssertTrue(Library.files.contains(documentFile))
        XCTAssertTrue(Library.files.contains(imageFile))
        XCTAssertTrue(Library.files.contains(audioFile))
        XCTAssertTrue(Library.files.contains(videoFile))
        
    }
    
    func testAll() {
        
        testingLibrary.add(file: documentFile)
        testingLibrary.add(file: imageFile)
        testingLibrary.add(file: audioFile)
        testingLibrary.add(file: videoFile)
        
        let files = testingLibrary.all()
        
        XCTAssertTrue(files.contains(documentFile))
        XCTAssertTrue(files.contains(imageFile))
        XCTAssertTrue(files.contains(audioFile))
        XCTAssertTrue(files.contains(videoFile))
        
    }
    
    func testSearchByTerm() {
        
        testingLibrary.add(file: documentFile)
        testingLibrary.add(file: imageFile)
        testingLibrary.add(file: audioFile)
        testingLibrary.add(file: videoFile)
        
        let firstResult = testingLibrary.search(term: "creator")
        
        XCTAssertTrue(firstResult.contains(documentFile))
        XCTAssertTrue(firstResult.contains(imageFile))
        XCTAssertTrue(firstResult.contains(audioFile))
        XCTAssertTrue(firstResult.contains(videoFile))
        
        let secondResult = testingLibrary.search(term: "Fake Author")
        
        XCTAssertTrue(secondResult.contains(documentFile))
        
        let thirdResult = testingLibrary.search(term: "Fake Photographer")
        
        XCTAssertTrue(thirdResult.contains(imageFile))
        
        
        let fourthResult = testingLibrary.search(term: "Fake Musician")
        
        XCTAssertTrue(fourthResult.contains(audioFile))
        
        
        let fifthResult = testingLibrary.search(term: "Fake Director")
        
        XCTAssertTrue(fifthResult.contains(videoFile))
        
        
        let emptyResult = testingLibrary.search(term: "non existent")
        XCTAssertTrue(emptyResult.isEmpty)
        
    }
    
    
    func testAddFileData() {
        testingLibrary.add(file: documentFile)
        testingLibrary.add(file: imageFile)
        testingLibrary.add(file: audioFile)
        testingLibrary.add(file: videoFile)
        
        testingLibrary.add(metadata: Metadata(keyword: "testDescription1", value: "Test Description"), file: documentFile)
        testingLibrary.add(metadata: Metadata(keyword: "dateCreated", value: "02-SEP-2018"), file: documentFile)
        testingLibrary.add(metadata: Metadata(keyword: "dateCreated", value: "07-APR-2016"), file: imageFile)
        testingLibrary.add(metadata: Metadata(keyword: "modified", value: "07-APR-2016"), file: audioFile)
        testingLibrary.add(metadata: Metadata(keyword: "lastOpened", value: "31-MAY-2017"), file: videoFile)
        
        let firstResultKey = testingLibrary.search(term: "testDescription1")
        XCTAssertTrue(firstResultKey.contains(documentFile))
        XCTAssertFalse(firstResultKey.contains(imageFile))
        XCTAssertFalse(firstResultKey.contains(videoFile))
        XCTAssertFalse(firstResultKey.contains(audioFile))
        XCTAssertTrue(firstResultKey.count==1)
        
        let secondResultKey = testingLibrary.search(term: "dateCreated")
        XCTAssertTrue(secondResultKey.contains(documentFile))
        XCTAssertTrue(secondResultKey.contains(imageFile))
        XCTAssertFalse(secondResultKey.contains(videoFile))
        XCTAssertFalse(secondResultKey.contains(audioFile))
        XCTAssertTrue(secondResultKey.count == 2)
        
        
        let thirdResultKey = testingLibrary.search(term: "modified")
        XCTAssertTrue(thirdResultKey.contains(audioFile))
        XCTAssertFalse(thirdResultKey.contains(videoFile))
        XCTAssertFalse(thirdResultKey.contains(documentFile))
        XCTAssertFalse(thirdResultKey.contains(imageFile))
        XCTAssertTrue(thirdResultKey.count==1)
        
        
        let fourthResultKey = testingLibrary.search(term: "lastOpened")
        XCTAssertTrue(fourthResultKey.contains(videoFile))
        XCTAssertFalse(fourthResultKey.contains(documentFile))
        XCTAssertFalse(fourthResultKey.contains(audioFile))
        XCTAssertFalse(fourthResultKey.contains(imageFile))
        XCTAssertTrue(fourthResultKey.count==1)
        
    }
    
    func testFilterBy() {
        
        testingLibrary.add(file: documentFile)
        testingLibrary.add(file: documentFile2)
        testingLibrary.add(file: imageFile)
        testingLibrary.add(file: imageFile2)
        testingLibrary.add(file: audioFile)
        testingLibrary.add(file: audioFile2)
        testingLibrary.add(file: videoFile)
        testingLibrary.add(file: videoFile2)
        
        //filtered on key "creator" and type "audio"
        let filteredResult = testingLibrary.filterBy(by: ["-a", "creator"])
        
        XCTAssertTrue(filteredResult.contains(audioFile))
        XCTAssertTrue(filteredResult.contains(audioFile2))
        XCTAssertFalse(filteredResult.contains(documentFile))
        XCTAssertFalse(filteredResult.contains(documentFile2))
        XCTAssertFalse(filteredResult.contains(imageFile))
        XCTAssertFalse(filteredResult.contains(imageFile2))
        XCTAssertFalse(filteredResult.contains(videoFile))
        XCTAssertFalse(filteredResult.contains(videoFile2))
        XCTAssertTrue(filteredResult.count == 2)
        
        
        
        //filtered on value "Fake Author" and type "document"
        let filteredResult2 = testingLibrary.filterBy(by: ["-d", "Fake Author"])
        
        XCTAssertTrue(filteredResult2.contains(documentFile))
        XCTAssertTrue(filteredResult2.contains(documentFile2))
        XCTAssertFalse(filteredResult2.contains(audioFile))
        XCTAssertFalse(filteredResult2.contains(audioFile2))
        XCTAssertFalse(filteredResult2.contains(imageFile))
        XCTAssertFalse(filteredResult2.contains(imageFile2))
        XCTAssertFalse(filteredResult2.contains(videoFile))
        XCTAssertFalse(filteredResult2.contains(videoFile2))
        XCTAssertTrue(filteredResult2.count == 2)
        
        
        //filtered on type "document" all documents should be added
        let filteredResult3 = testingLibrary.filterBy(by: ["-d"])
        
        XCTAssertTrue(filteredResult3.contains(documentFile))
        XCTAssertTrue(filteredResult3.contains(documentFile2))
        XCTAssertTrue(filteredResult3.count == 2)
        
        
        //filtered on type "audio" all documents should be added
        let filteredResult4 = testingLibrary.filterBy(by: ["-a"])
        
        XCTAssertTrue(filteredResult4.contains(audioFile))
        XCTAssertTrue(filteredResult4.contains(audioFile2))
        XCTAssertTrue(filteredResult4.count == 2)
        
        
        //filtered on type "video" all videos should be added
        let filteredResult5 = testingLibrary.filterBy(by: ["-v"])
        
        XCTAssertTrue(filteredResult5.contains(videoFile))
        XCTAssertTrue(filteredResult5.contains(videoFile2))
        XCTAssertTrue(filteredResult5.count == 2)
        
        
        //filtered on type "image". all images should be added
        let filteredResult6 = testingLibrary.filterBy(by: ["-i"])
        
        XCTAssertTrue(filteredResult6.contains(imageFile))
        XCTAssertTrue(filteredResult6.contains(imageFile2))
        XCTAssertTrue(filteredResult6.count == 2)
        
        
        //filtered on "Fake Musician" and "Fake Composer" (values) of type "audio"
        let filteredResult7 = testingLibrary.filterBy(by: ["-a", "Fake Musician", "Fake Composer"])
        
        XCTAssertTrue(filteredResult7.contains(audioFile))
        XCTAssertTrue(filteredResult7.contains(audioFile2))
        XCTAssertFalse(filteredResult7.contains(documentFile))
        XCTAssertFalse(filteredResult7.contains(documentFile2))
        XCTAssertFalse(filteredResult7.contains(imageFile))
        XCTAssertFalse(filteredResult7.contains(imageFile2))
        XCTAssertFalse(filteredResult7.contains(videoFile))
        XCTAssertFalse(filteredResult7.contains(videoFile2))
        XCTAssertTrue(filteredResult7.count == 2)
        
        
        //filtered on "Fake Musician" and "Fake Composer" (keys) of type "audio"
        let filteredResult8 = testingLibrary.filterBy(by: ["-a", "Fake Musician", "Fake Composer"])
        
        XCTAssertTrue(filteredResult8.contains(audioFile))
        XCTAssertTrue(filteredResult8.contains(audioFile2))
        XCTAssertFalse(filteredResult8.contains(documentFile))
        XCTAssertFalse(filteredResult8.contains(documentFile2))
        XCTAssertFalse(filteredResult8.contains(imageFile))
        XCTAssertFalse(filteredResult8.contains(imageFile2))
        XCTAssertFalse(filteredResult8.contains(videoFile))
        XCTAssertFalse(filteredResult8.contains(videoFile2))
        XCTAssertTrue(filteredResult8.count == 2)
        
        
        //filtered on "resolution" and "runtime" (keys) of type "image".
        let filteredResult9 = testingLibrary.filterBy(by: ["-i", "runtime"])
        
        //Result should be of size 0 as given image files dont contain a runtime
        XCTAssertTrue(filteredResult9.count == 0)
        
        
        
        //filtered on "1024x768"(value) and "runtime"(key) of type "image".
        let filteredResult10 = testingLibrary.filterBy(by: ["-i", "runtime", "1024x768"])
        
        //Result should be of size1 as there is only 1 1024x768 image
        XCTAssertTrue(filteredResult10.count == 1)

    }
    
        func testRemoveFileData() throws {
            testingLibrary.add(file: documentFile)
            testingLibrary.add(file: imageFile)
            testingLibrary.add(file: audioFile)
            testingLibrary.add(file: videoFile)
    
            testingLibrary.add(metadata: Metadata(keyword: "testDescription", value: "Test Description"), file: documentFile)
            testingLibrary.add(metadata: Metadata(keyword: "date", value: "07-APR-2016"), file: imageFile)
            testingLibrary.add(metadata: Metadata(keyword: "modified", value: "07-APR-2016"), file: audioFile)
            testingLibrary.add(metadata: Metadata(keyword: "lastOpened", value: "31-MAY-2017"), file: videoFile)
    
    
            let firstResultKey = testingLibrary.search(term: "testDescription")
            XCTAssertTrue(firstResultKey.contains(documentFile))
            testingLibrary.removeFileData(file: documentFile, key: "testDescription")
            XCTAssertFalse(documentFile.hasMetadata(key: "testDescription"))
            
            
            let secondResultKey = testingLibrary.search(term: "date")
            XCTAssertTrue(secondResultKey.contains(imageFile))
            testingLibrary.removeFileData(file: imageFile, key: "date")
            XCTAssertFalse(imageFile.hasMetadata(key: "date"))

            
            let thirdResultKey = testingLibrary.search(term: "modified")
            XCTAssertTrue(thirdResultKey.contains(audioFile))
            testingLibrary.removeFileData(file: audioFile, key: "modified")
            XCTAssertFalse(audioFile.hasMetadata(key: "modified"))
            
            
            let fourthResultKey = testingLibrary.search(term: "lastOpened")
            XCTAssertTrue(fourthResultKey.contains(videoFile))
            testingLibrary.removeFileData(file: videoFile, key: "lastOpened")
            XCTAssertFalse(videoFile.hasMetadata(key: "lastOpened"))
            
    }
    
}
