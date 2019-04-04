//
//  UnitTesting.swift
//  UnitTesting
//
//  Created by Daniela Lemow on 31/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import XCTest

class FileValidatorTesting: XCTestCase {
    
    /* An instance of the File Validator class to use for testing. */
    let validator = FileValidator()
    
    var testBundle : Bundle?
    
    /* A struct to store information from JSON files. */
    struct MediaStruct : Codable {
        let fullpath : String
        let type : String
        let metadata : [String: String]
    }
    
    /* Initialise one of each type of Media file for testing the getChecks method on */
    var documentFile = Document(filename: "book.pdf", path: "/path/test/book.pdf", type: "document", metadata: [Metadata(keyword: "creator", value: "Fake Author")])
    var imageFile = Image(filename: "image.png", path: "/test/path/image.png", type: "image",
                          metadata: [Metadata(keyword: "creator", value: "Fake Photographer"), Metadata(keyword: "resolution", value: "1024x768")])
    var audioFile = Audio(filename: "song.mp3", path: "/test/path/song.mp3", type: "audio", metadata: [Metadata(keyword: "creator", value: "Fake Musician"), Metadata(keyword: "runtime", value: "78:58")])
    var videoFile = Video(filename: "movie.mov", path: "/test/path/movie.mov", type: "video", metadata: [Metadata(keyword: "creator", value: "Fake Director"), Metadata(keyword: "resolution", value: "1024x768"), Metadata(keyword: "runtime", value: "120:56")])
    
    // This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
        testBundle = Bundle(for: type(of: self))
    }
    
    // This method is called after the invocation of each test method in the class.
    override func tearDown() {
        super.tearDown()
    }
    
    func testValidateData() {
        
        let fileUrl = testBundle?.url(forResource: "test-9", withExtension: ".json", subdirectory: "test-files")
        
        if let relPath = fileUrl?.relativePath {
            
            let jsonData = readMedia(from: URL(fileURLWithPath: relPath))
            
            //Check if the first file in test-9.json is valid, it has a valid path and valid type
            let firstFileValid = validator.validateData(fullpath: jsonData[0].fullpath, type: jsonData[0].type)
            XCTAssertTrue(firstFileValid)
            
            //Check if the second file in test-9.json is invalid, it has no fullpath and no type
            let secondFileInvalid = validator.validateData(fullpath: jsonData[1].fullpath, type: jsonData[1].type)
            XCTAssertFalse(secondFileInvalid)
            
            //Check if the third file in test-9.json is invalid, it has a valid fullpath and an invalid type
            let thirdFileInvalid = validator.validateData(fullpath: jsonData[2].fullpath, type: jsonData[2].type)
            XCTAssertFalse(thirdFileInvalid)
            
            //Check if the fourth file in test-9.json is invalid, it has no fullpath and an invalid type
            let fourthFileInvalid = validator.validateData(fullpath: jsonData[3].fullpath, type: jsonData[3].type)
            XCTAssertFalse(fourthFileInvalid)
            
        }
       
    }
    
    func testValidateMetadata() {
        
        //test-1 contains one of each type of media, containing the required metadata.
        var fileUrl = testBundle?.url(forResource: "test-1", withExtension: ".json", subdirectory: "test-files")
        
        if let relPath = fileUrl?.relativePath {
            
            let jsonData = readMedia(from: URL(fileURLWithPath: relPath))
            
            let fileOneMetadata = validator.validateMetadata(type: jsonData[0].type, checks: getChecks(from: jsonData[0]))
            XCTAssertTrue(fileOneMetadata)
            
            let fileTwoMetadata = validator.validateMetadata(type: jsonData[1].type, checks: getChecks(from: jsonData[1]))
            XCTAssertTrue(fileTwoMetadata)
            
            let fileThreeMetadata = validator.validateMetadata(type: jsonData[2].type, checks: getChecks(from: jsonData[2]))
            XCTAssertTrue(fileThreeMetadata)
            
            let fileFourMetadata = validator.validateMetadata(type: jsonData[3].type, checks: getChecks(from: jsonData[3]))
            XCTAssertTrue(fileFourMetadata)
        }
        
        //test-6.json contains one of each type of media, containing extra metadata
        fileUrl = testBundle?.url(forResource: "test-6", withExtension: ".json", subdirectory: "test-files")
        
        if let relPath = fileUrl?.relativePath {
            
            let jsonData = readMedia(from: URL(fileURLWithPath: relPath))
            
            let fileOneMetadata = validator.validateMetadata(type: jsonData[0].type, checks: getChecks(from: jsonData[0]))
            XCTAssertTrue(fileOneMetadata)
            
            let fileTwoMetadata = validator.validateMetadata(type: jsonData[1].type, checks: getChecks(from: jsonData[1]))
            XCTAssertTrue(fileTwoMetadata)
            
            let fileThreeMetadata = validator.validateMetadata(type: jsonData[2].type, checks: getChecks(from: jsonData[2]))
            XCTAssertTrue(fileThreeMetadata)
            
            let fileFourMetadata = validator.validateMetadata(type: jsonData[3].type, checks: getChecks(from: jsonData[3]))
            XCTAssertTrue(fileFourMetadata)
            
        }
        
        //test-7.json contains one of each type of media, all containing nil values (excluding fullpath and type)
        fileUrl = testBundle?.url(forResource: "test-7", withExtension: ".json", subdirectory: "test-files")
        
        if let relPath = fileUrl?.relativePath {
            
            let jsonData = readMedia(from: URL(fileURLWithPath: relPath))
            
            let fileOneMetadata = validator.validateMetadata(type: jsonData[0].type, checks: getChecks(from: jsonData[0]))
            XCTAssertFalse(fileOneMetadata)
            
            let fileTwoMetadata = validator.validateMetadata(type: jsonData[1].type, checks: getChecks(from: jsonData[1]))
            XCTAssertFalse(fileTwoMetadata)
            
            let fileThreeMetadata = validator.validateMetadata(type: jsonData[2].type, checks: getChecks(from: jsonData[2]))
            XCTAssertFalse(fileThreeMetadata)
            
            let fileFourMetadata = validator.validateMetadata(type: jsonData[3].type, checks: getChecks(from: jsonData[3]))
            XCTAssertFalse(fileFourMetadata)
            
        }
        
    }
    
    func testGetChecks() {
        
        let checksDocument = validator.getChecks(from: documentFile)
        
        let documentResult = [
            "creator" : true,
            "resolution" : false,
            "runtime" : false
        ]
        
        XCTAssertTrue(checksDocument == documentResult)
        
        let checksVideo = validator.getChecks(from: videoFile)
        
        let videoResult = [
            "creator" : true,
            "resolution" : true,
            "runtime" : true
        ]
        
        XCTAssertTrue(checksVideo == videoResult)
        
        let checksAudio = validator.getChecks(from: audioFile)
        
        let audioResult = [
            "creator" : true,
            "resolution" : false,
            "runtime" : true
        ]
        
        XCTAssertTrue(checksAudio == audioResult)
        
        let checksImage = validator.getChecks(from: imageFile)
        
        let imageResult = [
            "creator" : true,
            "resolution" : true,
            "runtime" : false
        ]
        
        XCTAssertTrue(checksImage == imageResult)
        
    }
    
    func readMedia(from url: URL) -> [MediaStruct] {
        
        //Read the data from the JSON file
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode([MediaStruct].self, from: data)
            return jsonData
        } catch {
            print(error.localizedDescription)
        }
        
        return []
        
    }
    
    func getChecks(from media: MediaStruct) -> [String : Bool] {
        
        var checks = [
            "creator": false,
            "runtime": false,
            "resolution": false
        ]
        
        for d in media.metadata {
            
            if d.key.lowercased() == "creator" && !d.value.isEmpty {
                checks["creator"] = true
            }
            if d.key.lowercased() == "resolution" && !d.value.isEmpty {
                checks["resolution"] = true
                
            }
            if d.key.lowercased() == "runtime" && !d.value.isEmpty {
                checks["runtime"] = true
            }
            
        }
        
        return checks
    }
    
    
    func testGetErrorMessages(){

        //Tests should not have any error messages because they are valid
        let validDocCheck1 = validator.getErrorMessages(fullpath: "/path/test/book.pdf", type: "document", checks: validator.getChecks(from: documentFile))
        XCTAssertTrue(validDocCheck1.isEmpty)
        
        let validVidCheck1 = validator.getErrorMessages(fullpath: "/path/test/movie.mov", type: "video", checks: validator.getChecks(from: videoFile))
        XCTAssertTrue(validVidCheck1.isEmpty)
        
        let validAudCheck1 = validator.getErrorMessages(fullpath: "/path/test/song.mp3", type: "audio", checks: validator.getChecks(from: audioFile))
        XCTAssertTrue(validAudCheck1.isEmpty)
        
        let validImgCheck1 = validator.getErrorMessages(fullpath: "/path/test/image.png", type: "image", checks: validator.getChecks(from: imageFile))
        XCTAssertTrue(validImgCheck1.isEmpty)
        
        
        /*DOCUMENT FILES*/
       // document doesnt contain a creator
        let invalidDocumentFile1 = Document(filename: "invalidBook.pdf", path: "/path/test/invalidBook.pdf", type: "document", metadata: [Metadata(keyword: "creator", value: "")])
        
        let invalidDocCheck1 = validator.getErrorMessages(fullpath: invalidDocumentFile1.path, type: invalidDocumentFile1.type, checks: validator.getChecks(from: invalidDocumentFile1))
        
        XCTAssertTrue(invalidDocCheck1.contains("does not contain a creator"))
        XCTAssertFalse(invalidDocCheck1.contains("does not contain a resolution"))
        XCTAssertFalse(invalidDocCheck1.contains("does not contain a runtime"))
        
        
        //document doesnt contain fullpath
        let invalidDocumentFile2 = Document(filename: "", path: "", type: "document", metadata: [Metadata(keyword: "creator", value: "Fake Creator")])
        let invalidDocCheck2 = validator.getErrorMessages(fullpath: invalidDocumentFile2.filename, type: invalidDocumentFile2.type, checks: validator.getChecks(from: invalidDocumentFile2))
        
        XCTAssertTrue(invalidDocCheck2.contains("does not contain a fullpath"))
        XCTAssertFalse(invalidDocCheck2.contains("does not contain a creator"))
        XCTAssertFalse(invalidDocCheck2.contains("does not contain a resolution"))
        XCTAssertFalse(invalidDocCheck2.contains("does not contain a runtime"))
        
        
        //document doesnt contain type
        let invalidDocumentFile3 = Document(filename: "invalidBook3.pdf", path: "/path/test/invalidBook3.pdf", type: "", metadata: [Metadata(keyword: "creator", value: "Fake Creator")])
        let invalidDocCheck3 = validator.getErrorMessages(fullpath: invalidDocumentFile3.filename, type: invalidDocumentFile3.type, checks: validator.getChecks(from: invalidDocumentFile3))
        
        XCTAssertTrue(invalidDocCheck3.contains("does not contain a type - may be missing metadata"))
        XCTAssertFalse(invalidDocCheck3.contains("does not contain a creator"))
        XCTAssertFalse(invalidDocCheck3.contains("does not contain a resolution"))
        XCTAssertFalse(invalidDocCheck3.contains("does not contain a runtime"))
        
        
        //document contains invalid type
        let invalidDocumentFile4 = Document(filename: "invalidBook4.pdf", path: "/path/test/invalidBook4.pdf", type: "documint", metadata: [Metadata(keyword: "creator", value: "Fake Creator")])
        let invalidDocCheck4 = validator.getErrorMessages(fullpath: invalidDocumentFile4.filename, type: invalidDocumentFile4.type, checks: validator.getChecks(from: invalidDocumentFile4))
        
        XCTAssertTrue(invalidDocCheck4.contains("\"documint\" is not a valid file type"))
        XCTAssertFalse(invalidDocCheck4.contains("does not contain a type - may be missing metadata"))
        XCTAssertFalse(invalidDocCheck4.contains("does not contain a creator"))
        XCTAssertFalse(invalidDocCheck4.contains("does not contain a resolution"))
        XCTAssertFalse(invalidDocCheck4.contains("does not contain a runtime"))
        
        
        
        /*IMAGE FILES*/
        //image doesnt contain a valid type
        let invalidImageFile1 = Image(filename: "invalidImage.png", path: "/path/test/invalidImage.png", type: "imig",
                                         metadata: [Metadata(keyword: "creator", value: "Fake Photographer"), Metadata(keyword: "resolution", value: "1024x768")])
        
        let invalidImageCheck1 = validator.getErrorMessages(fullpath: invalidImageFile1.filename, type: invalidImageFile1.type, checks: validator.getChecks(from: invalidImageFile1))
        
        XCTAssertTrue(invalidImageCheck1.contains("\"imig\" is not a valid file type"))
        XCTAssertFalse(invalidImageCheck1.contains("does not contain a fullpath"))
        XCTAssertFalse(invalidImageCheck1.contains("does not contain a creator"))
        XCTAssertFalse(invalidImageCheck1.contains("does not contain a resolution"))
        XCTAssertFalse(invalidImageCheck1.contains("does not contain a runtime"))
        
        
        //image doesnt contain a type or required creator or resolution
        let invalidImageFile2 = Image(filename: "invalidImage.png", path: "/path/test/invalidImage.png", type: "",
                                      metadata: [Metadata(keyword: "resolution", value: "1024x768")])
        
        let invalidImageCheck2 = validator.getErrorMessages(fullpath: invalidImageFile2.filename, type: invalidImageFile2.type, checks: validator.getChecks(from: invalidImageFile2))
        
        XCTAssertTrue(invalidImageCheck2.contains("does not contain a type - may be missing metadata"))
        XCTAssertTrue(invalidImageCheck2.contains("does not contain a creator"))
        XCTAssertFalse(invalidImageCheck2.contains("does not contain a fullpath"))
        XCTAssertFalse(invalidImageCheck2.contains("does not contain a resolution"))
        XCTAssertFalse(invalidImageCheck2.contains("does not contain a runtime"))
        
        
        //image doesnt contain required resolution
        let invalidImageFile3 = Image(filename: "invalidImage.png", path: "/path/test/invalidImage.png", type: "image",
                                      metadata: [Metadata(keyword: "creator", value: "Fake Photographer")])
        
        let invalidImageCheck3 = validator.getErrorMessages(fullpath: invalidImageFile3.filename, type: invalidImageFile3.type, checks: validator.getChecks(from: invalidImageFile3))
        
        XCTAssertTrue(invalidImageCheck3.contains("does not contain a resolution"))
        XCTAssertFalse(invalidImageCheck3.contains("does not contain a type - may be missing metadata"))
        XCTAssertFalse(invalidImageCheck3.contains("does not contain a creator"))
        XCTAssertFalse(invalidImageCheck3.contains("does not contain a fullpath"))
        XCTAssertFalse(invalidImageCheck3.contains("does not contain a runtime"))
        
        
        //image doesnt contain filename or fullpath
        let invalidImageFile4 = Image(filename: "", path: "", type: "image",
                                      metadata: [Metadata(keyword: "creator", value: "Fake Photographer"), Metadata(keyword: "resolution", value: "1024x768")])
        let invalidImageCheck4 = validator.getErrorMessages(fullpath: invalidImageFile4.filename, type: invalidImageFile4.type, checks: validator.getChecks(from: invalidImageFile4))
        XCTAssertTrue(invalidImageCheck4.contains("does not contain a fullpath"))
        XCTAssertFalse(invalidImageCheck4.contains("does not contain a creator"))
        XCTAssertFalse(invalidImageCheck4.contains("does not contain a resolution"))
        XCTAssertFalse(invalidImageCheck4.contains("does not contain a runtime"))
        
        
        
        /*AUDIO FILES*/
        
        //audiofile doesnt have required type
        let invalidAudioFile1 = Audio(filename: "invalidSong.mp3", path: "/test/path/invalidSong.mp3", type: "", metadata: [Metadata(keyword: "creator", value: "Fake Musician"), Metadata(keyword: "runtime", value: "78:58")])
        
        let invalidAudioCheck1 = validator.getErrorMessages(fullpath: invalidAudioFile1.filename, type: invalidAudioFile1.type, checks: validator.getChecks(from: invalidAudioFile1))
        
        XCTAssertTrue(invalidAudioCheck1.contains("does not contain a type - may be missing metadata"))
        XCTAssertFalse(invalidImageCheck1.contains("does not contain a fullpath"))
        XCTAssertFalse(invalidImageCheck1.contains("does not contain a creator"))
        XCTAssertFalse(invalidImageCheck1.contains("does not contain a resolution"))
        XCTAssertFalse(invalidImageCheck1.contains("does not contain a runtime"))
        
        
        //audiofile doesnt have valid type
        let invalidAudioFile2 = Audio(filename: "invalidSong2.mp3", path: "/test/path/invalidSong2.mp3", type: "aw-hellyeah-dio", metadata: [Metadata(keyword: "creator", value: "Fake Musician"), Metadata(keyword: "runtime", value: "78:58")])
        
        let invalidAudioCheck2 = validator.getErrorMessages(fullpath: invalidAudioFile2.filename, type: invalidAudioFile2.type, checks: validator.getChecks(from: invalidAudioFile2))
        
        XCTAssertTrue(invalidAudioCheck2.contains("\"aw-hellyeah-dio\" is not a valid file type"))
        XCTAssertFalse(invalidAudioCheck2.contains("does not contain a type - may be missing metadata"))
        XCTAssertFalse(invalidAudioCheck2.contains("does not contain a creator"))
        XCTAssertFalse(invalidAudioCheck2.contains("does not contain a resolution"))
        XCTAssertFalse(invalidAudioCheck2.contains("does not contain a runtime"))
        
        
        //audiofile doesnt have required creator or runtime
        let invalidAudioFile3 = Audio(filename: "invalidSong3.mp3", path: "/test/path/invalidSong3.mp3", type: "audio", metadata: [])
        
        let invalidAudioCheck3 = validator.getErrorMessages(fullpath: invalidAudioFile3.filename, type: invalidAudioFile3.type, checks: validator.getChecks(from: invalidAudioFile3))
        
        XCTAssertTrue(invalidAudioCheck3.contains("does not contain a creator"))
        XCTAssertTrue(invalidAudioCheck3.contains("does not contain a runtime"))
        XCTAssertFalse(invalidAudioCheck3.contains("does not contain a type - may be missing metadata"))
        XCTAssertFalse(invalidAudioCheck3.contains("does not contain a fullpath"))
        XCTAssertFalse(invalidAudioCheck3.contains("does not contain a resolution"))

        //audiofile doesnt have full path
        let invalidAudioFile4 = Audio(filename: "", path: "", type: "audio", metadata: [Metadata(keyword: "creator", value: "Fake Musician"), Metadata(keyword: "runtime", value: "78:58")])
        
        let invalidAudioCheck4 = validator.getErrorMessages(fullpath: invalidAudioFile4.filename, type: invalidAudioFile4.type, checks: validator.getChecks(from: invalidAudioFile4))
        
        XCTAssertTrue(invalidAudioCheck4.contains("does not contain a fullpath"))
        XCTAssertFalse(invalidAudioCheck4.contains("does not contain a creator"))
        XCTAssertFalse(invalidAudioCheck4.contains("does not contain a resolution"))
        XCTAssertFalse(invalidAudioCheck4.contains("does not contain a runtime"))
        
        
        /*VIDEO FILES*/
        //video doesnt contain required resolution, creator or runtime
        let invalidVideoFile1 = Video(filename: "invalidMovie.mov", path: "/test/path/invalidMovie.mov", type: "video", metadata: [])
        
        let invalidVideoFileCheck = validator.getErrorMessages(fullpath: invalidVideoFile1.filename, type: invalidVideoFile1.type, checks: validator.getChecks(from: invalidVideoFile1))
        
        XCTAssertTrue(invalidVideoFileCheck.contains("does not contain a resolution"))
        XCTAssertTrue(invalidVideoFileCheck.contains("does not contain a runtime"))
        XCTAssertTrue(invalidVideoFileCheck.contains("does not contain a creator"))
        XCTAssertTrue(invalidVideoFileCheck.count == 3)
        
        
        //video had invalid type
        let invalidVideoFile2 = Video(filename: "invalidMovie2.mov", path: "/test/path/invalidMovie2.mov", type: "vid", metadata: [Metadata(keyword: "creator", value: "Fake Director"), Metadata(keyword: "resolution", value: "1080p"), Metadata(keyword: "runtime", value: "10:25")])
        
        let invalidVideoFileCheck2 = validator.getErrorMessages(fullpath: invalidVideoFile2.filename, type: invalidVideoFile2.type, checks: validator.getChecks(from: invalidVideoFile2))
        
        XCTAssertTrue(invalidVideoFileCheck2.contains("\"vid\" is not a valid file type"))
        XCTAssertFalse(invalidVideoFileCheck2.contains("does not contain a type - may be missing metadata"))
        XCTAssertFalse(invalidVideoFileCheck2.contains("does not contain a creator"))
        XCTAssertFalse(invalidVideoFileCheck2.contains("does not contain a resolution"))
        XCTAssertFalse(invalidVideoFileCheck2.contains("does not contain a runtime"))
        XCTAssertTrue(invalidVideoFileCheck2.count == 1)
        
        
        //video had missing type
        let invalidVideoFile3 = Video(filename: "invalidMovie3.mov", path: "/test/path/invalidMovie3.mov", type: "", metadata: [Metadata(keyword: "creator", value: "Fake Director"), Metadata(keyword: "resolution", value: "1080p"), Metadata(keyword: "runtime", value: "10:25")])
        
        let invalidVideoFileCheck3 = validator.getErrorMessages(fullpath: invalidVideoFile3.filename, type: invalidVideoFile3.type, checks: validator.getChecks(from: invalidVideoFile3))
        
        XCTAssertTrue(invalidVideoFileCheck3.contains("does not contain a type - may be missing metadata"))
        XCTAssertFalse(invalidVideoFileCheck3.contains("does not contain a creator"))
        XCTAssertFalse(invalidVideoFileCheck3.contains("does not contain a resolution"))
        XCTAssertFalse(invalidVideoFileCheck3.contains("does not contain a runtime"))
        XCTAssertTrue(invalidVideoFileCheck3.count == 1)

        
        //video had missing pathname
        let invalidVideoFile4 = Video(filename: "", path: "", type: "video", metadata: [Metadata(keyword: "creator", value: "Fake Director"), Metadata(keyword: "resolution", value: "1080p"), Metadata(keyword: "runtime", value: "10:25")])
        
        let invalidVideoFileCheck4 = validator.getErrorMessages(fullpath: invalidVideoFile4.filename, type: invalidVideoFile4.type, checks: validator.getChecks(from: invalidVideoFile4))
        
        XCTAssertTrue(invalidVideoFileCheck4.contains("does not contain a fullpath"))
        XCTAssertFalse(invalidVideoFileCheck4.contains("does not contain a creator"))
        XCTAssertFalse(invalidVideoFileCheck4.contains("does not contain a resolution"))
        XCTAssertFalse(invalidVideoFileCheck4.contains("does not contain a runtime"))
        XCTAssertTrue(invalidVideoFileCheck4.count == 1)
    }
        
  
}
