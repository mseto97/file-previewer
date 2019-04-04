//
//  ProjectorView.swift
//  MediaApp
//
//  Created by Daniela Lemow on 5/10/18.
//  Copyright © 2018 Megan. All rights reserved.
//

import Cocoa
import Quartz
import AVKit
/*
 * The "Projector View" for the application.
 * This is the view that appears when a user double clicks on an imported file from the MainWindowController
 * This is the view that is also used when a user clicks "View File..." button on MainWindowController
 * View allows user to preview the file in a new resizeable window
 */
class ProjectorView: NSViewController {
    
    var filePath : String!
    var type : String!
    
    //Different objects that are used to help display the different media types
    @IBOutlet weak var imageWell: NSImageView!
    
    @IBOutlet weak var noPreview: NSTextField!
    
    //Used for showing pdf files
    @IBOutlet weak var pdfView: PDFView!
    
    //Used for showing .txt files
    @IBOutlet weak var textView: NSScrollView!
    @IBOutlet var textField: NSTextView!
   
    //video player object used for playing videos
    @IBOutlet weak var videoPlayer: AVPlayerView!
    var playView = AVPlayer();
    var soundPlayer =  AVAudioPlayer()
    
    //Audio viewer objects. Play, pause, image
    @IBOutlet weak var audioBox: NSBox!
    @IBOutlet weak var btnPlay: NSButton!
    @IBOutlet weak var btnPause: NSButton!
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?, filePath: String, type: String) {
        self.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.filePath = filePath
        self.type = type
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hides all of the objects and windows.
        imageWell.isHidden = true
        pdfView.isHidden = true
        textView.isHidden = true
        textField.isHidden = true
        textField.isEditable = false
        videoPlayer.isHidden = true
        audioBox.isHidden = true
        noPreview.isHidden = true
        
        //if the file type is an image
        if (self.type == "image") {
            
            //Creates NSImage and sets it
            let chosenImage = NSImage(byReferencingFile: getFilePath(from: filePath))
            
            //checks if the image/filepath is valid
            if (chosenImage?.isValid)!{
                imageWell.image = chosenImage
                imageWell.isHidden = false
            } else {
                noPreview.isHidden = false
            }
            
        //if the file type is a document
        } else if (self.type == "document") {
            
            //gets the text files extensions
            let pieces = filePath.split(separator: ".")
            let fileExtension = String(pieces[pieces.count-1])
            
            //if the document is a pdf
            if (fileExtension == "pdf") {
                pdfView.isHidden = false
                
                //Gets NSURL to create pdfDocument
                let fileURL = NSURL(fileURLWithPath: getFilePath(from: filePath))
                
                //creates PDFDocument object using selected files url
                let pdfDocument = PDFDocument(url: fileURL as URL)
                
                if (pdfDocument != nil) {
                    //sets the document and shows it
                    pdfView.document = pdfDocument
                    pdfView.isHidden = false
                    
                }
                
            //else treated as a txt file
            } else if (fileExtension == "txt") {
                
                do {
                    let contents = try String(contentsOfFile: getFilePath(from: filePath))
                    textField.string = contents
                    textField.isHidden = false
                    textView.isHidden = false
                } catch {
                
                }
                
            } else {
                noPreview.isHidden = false
            }
            
        //if the type is a video file
        } else if (self.type == "video") {
            
            //gets appropriate type of url
            let filepath : String = NSString(string: filePath).expandingTildeInPath
            let fileURL = NSURL(fileURLWithPath: filepath)
            
            
            //sets up the video player
            // playView = AVPlayer(url: fileURL as URL)
            playView = AVPlayer(url: fileURL as URL)
            videoPlayer.player = playView
            videoPlayer.isHidden = false
            
        //if the file is an audio file
        } else if (self.type == "audio") {
            
            do {
                soundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: getFilePath(from: filePath)))
                soundPlayer.prepareToPlay()
                
                //Shows appropriate objects
                audioBox.isHidden = false
                btnPlay.isHidden = false
                btnPause.isHidden = false
                btnPause.isEnabled = false
            } catch {
                
            } 
    
        } else {
            imageWell.image = nil
            imageWell.isHidden = true
            imageWell.isHidden = true
            noPreview.isHidden  = false
        }
    }
    
    /// Action plays current files audio when "Play" button is clicked
    ///
    /// - Parameters:
    /// - sender: Play button that executes action

    @IBAction func btnPlay(_ sender: Any) {
        
        if(self.type == "audio"){
            btnPlay.isEnabled = false    //disables the play button if audio is playing
            btnPause.isEnabled = true    //enables pause button if audio is playing
            soundPlayer.play()              //starts the audio file
        } else {
            //if the current file isnt an audio file, play and pause button are disabled.
            btnPlay.isEnabled = false
            btnPause.isEnabled = false
        }
    }
    
    /// Action pauses the current files audio when "Pause" button is clicked
    ///
    /// - Parameters:
    /// - sender: Pause button that executes action
    ///
    @IBAction func btnPause(_ sender: Any) {
        
        //enables/disables play/pause buttons appropriately
        btnPause.isEnabled = false
        btnPlay.isEnabled = true
        
        //pauses audio
        soundPlayer.pause()
    }
    
    
    
}
