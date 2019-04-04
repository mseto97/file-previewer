//
//  FileViewer.swift
//  MediaApp
//
//  Created by Daniela Lemow and Megan Seto on 30/09/18.
//  Copyright © 2018 Megan. All rights reserved.
//

import Cocoa
import AVKit
import Quartz

/*
 * FileViewer is the view that pops up when a user clicks "Show File Info..." from Main View Window
 * Users are able to see a small preview of the selected file, and can add notes, add/remove/edit metadata related
 * To currently viewed file.
 */
class FileViewer: NSViewController {
    
    var viewFiles : [File?] = []
    var currFileIndex : Int = -1
    
    var contentView : ContentView!
    
    @IBOutlet weak var fileLabel: NSTextField! //fileLabel outlet to show name of current file
    @IBOutlet var notesField: NSTextView!   //Field where notes can be added
    
    @IBOutlet weak var extNotSupported: NSTextField!
    @IBOutlet weak var prevNotAvailable: NSTextField!
    
    //Buttons for adding/removing/editing meta data from current files
    @IBOutlet weak var btnAddData: NSButton!
    @IBOutlet weak var btnEditData: NSButton!
    @IBOutlet weak var btnRemoveData: NSButton!
    @IBOutlet weak var dataTableView: NSTableView!  //table for showing the metadata
    
    //Next and previous buttons used for navigating through different files
    @IBOutlet weak var btnPrevious: NSButton!
    @IBOutlet weak var btnNext: NSButton!
    
    //Outlets shown for audio files. Play and pause buttons and other imagery
    @IBOutlet weak var audioBox: NSView!
    @IBOutlet weak var smallAudioBox: NSBox!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var pauseButton: NSButton!
    
    //Objects used for presenting different types of media, depending on the type
    @IBOutlet weak var txtView: NSScrollView!
    @IBOutlet var txtHolder: NSTextView!
    @IBOutlet weak var imageWell: NSImageView!
    @IBOutlet weak var videoPlayer: AVPlayerView!
    @IBOutlet weak var pdfViewer: PDFView!
    
    // Used for playing videos
    var playView = AVPlayer();
    var soundPlayer =  AVAudioPlayer()
    
    //Array of file extensions that are supported by the app. Only these extensions can be used.
    let validExtensions: [String] = ["png", "jpg", "m4a", "mov", "txt", "pdf"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Loads the name of the current file and sets valu eon fileLabel outlet
        fileLabel.stringValue = (viewFiles[currFileIndex]?.name)!
        
        //enables/disables the previous/next buttons when appropriate to allow/prevent scrolling
        if currFileIndex == 0 {
            btnPrevious.isEnabled = false
        } else if currFileIndex == viewFiles.count-1 {
            btnNext.isEnabled = false
        }
        
        btnRemoveData.isEnabled = false
        btnEditData.isEnabled = false
        dataTableView.allowsMultipleSelection = true
        
        //insert the current view files' notes into the notesField text outlet
        notesField.insertText(viewFiles[currFileIndex]?.notes as Any, replacementRange: NSRange())
        
        //tableViews data source and delegate will be the view controller.
        dataTableView.delegate = self
        dataTableView.dataSource = self
        
        //Hides play/pause button used for audio files when not in use.
        playButton.isHidden = true
        pauseButton.isHidden = true
        
        //Reloads the metadata table everytime the view is loaded/a new file is selected
        dataTableView.reloadData()
        
        //Updates the objects shown depending on the type of media file
        updateMediaPreview()
        
    }
    
    override func viewDidDisappear() {
        updateFile(with: (viewFiles[currFileIndex]?.url)!, and: notesField.string)
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?, viewFiles: inout [File?], currIndex: Int, contentView: ContentView) {
        self.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.viewFiles = viewFiles
        self.currFileIndex = currIndex
        self.contentView = contentView
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    /// Previous button action, goes the the previous file array
    /// Updates/Reloads the tables with correct file/data/objects
    //
    /// - Parameters:
    /// - sender: The previous button object that executes the action
    @IBAction func btnPrevious(_ sender: Any) {
        
        //Before changing the index of the file we are viewing, give the view file
        //whatever has been typed in the notes field
        updateFile(with: (viewFiles[currFileIndex]?.url)!, and: notesField.string)
        viewFiles[currFileIndex]?.notes = notesField.string
        
        //Decrement the index to look at the next file in the list as long as
        //we are not at the minimum index
        if currFileIndex > 0 {
            currFileIndex -= 1
            
        }
        
        //Executes the appropriate view updates
        updateViewState()
        updateMediaPreview()
        dataTableView.reloadData()
    }
    
    /// Next button action, goes the the next file in the file array
    /// Updates/Reloads the tables with correct file/data/objects
    ///
    /// - Parameters:
    /// - sender: The previous button object that executes the action
    @IBAction func btnNext(_ sender: Any) {
        
        //Before changing the index of the file we are viewing, give the view file
        //whatever has been typed in the notes field
        updateFile(with: (viewFiles[currFileIndex]?.url)!, and: notesField.string)
        viewFiles[currFileIndex]?.notes = notesField.string
        
        //Increment the index to look at the next file in the list as long as
        //we are not at the maximum index
        if currFileIndex < viewFiles.count-1 {
            currFileIndex += 1
        }
        
        //Executes the appropriate view updates
        updateViewState()
        updateMediaPreview()
        dataTableView.reloadData()
    }
    

    /// Updates the selected file with any new note inputs from the user
    ///
    /// - Parameters:
    /// - url: The url of the selected files whose notes will be updated
    /// - notes: The notes that will be updated/saved
    func updateFile(with url: String, and notes: String) {
        
        //Content view
        var fileToModify = -1
        
        for i in 0..<contentView.fileItems.count where url == contentView.fileItems[i]?.url {
            fileToModify = i
        }
        
        if fileToModify > -1 {
            contentView.fileItems[fileToModify]?.notes = notes
        }
        
        //Bookmark view
        fileToModify = -1
        
        for i in 0..<BookmarkView.bookmarks[0]!.files.count where url == BookmarkView.bookmarks[0]?.files[i].url {
            fileToModify = i
        }
        
        if fileToModify > -1 {
            BookmarkView.bookmarks[0]?.files[fileToModify].notes = notes
        }
    }
    
    
    /// Updates the UI objects in the view depending on the selected file
    /// Updates file label with file name and notes field
    /// Enables and disables "Next" and "Previous" buttons when appropriate
    func updateViewState() {
        
        fileLabel.stringValue = (viewFiles[currFileIndex]?.name)!    //Update the file label to the current file's name
        notesField.string = (viewFiles[currFileIndex]?.notes)!      //Update the notes field to the current file's notes
        
        //Determines if the previous and next buttons should be enabled or disabled
        //depending on the index of the current file we are looking at.
        if (currFileIndex == 0) {
            btnPrevious.isEnabled = false
            btnNext.isEnabled = true
        } else if (currFileIndex == viewFiles.count-1) {
            btnNext.isEnabled = false
            btnPrevious.isEnabled = true
        } else if (viewFiles.count == 1) {
            btnNext.isEnabled = false
            btnPrevious.isEnabled = false
        } else {
            btnNext.isEnabled = true
            btnPrevious.isEnabled = true
        }
        
    }
    
    /// Allows users to add metadata (key: value) to the current file.
    ///
    /// - Parameters:
    /// - sender: Add Metadata button that executes the action
    @IBAction func btnAddData(_ sender: Any) {
        typealias MMMetadata = Metadata
        let msg = NSAlert()
        msg.addButton(withTitle: "Add Metadata")      // 1st button
        msg.addButton(withTitle: "Cancel")  // 2nd button
        msg.messageText = "Add Metadata"
        msg.informativeText = "Please enter the key and value you would like for the new piece of data below:"
        
        //View that allows users to enter the metadata key and value they wish to add
        let addDataView = AddMetadataView(frame: NSRect(x: 0, y: 0, width: 277, height: 63))
        msg.accessoryView = addDataView
        let response: NSApplication.ModalResponse = msg.runModal()
        
        //if the user clicks add metadata from user prompt, the input metadata is added to the file
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            let key = addDataView.key.stringValue
            let value = addDataView.value.stringValue
            viewFiles[currFileIndex]?.metadata.append(MMMetadata(keyword: key, value: value))
            
            //table reloaded to reflect changes
            dataTableView.reloadData()
        }
        
    }
    
    /// Action allows selected metadata of a file to be edited
    ///
    /// - Parameters:
    /// - sender: The "Edit Metadata" button executes the action
    @IBAction func btnEditData(_ sender: Any) {
        
        typealias MMMetadata = Metadata
        
        //gets the piece of data to be edited
        let selectedDataIndex = dataTableView.selectedRow
        let data = viewFiles[currFileIndex]?.metadata[selectedDataIndex]
        
        if (data == nil) {
            return
        }
        
        //Sets up the popup settings
        let msg = NSAlert()
        msg.addButton(withTitle: "Edit Metadata")      // 1st button
        msg.addButton(withTitle: "Cancel")  // 2nd button
        msg.messageText = "Edit Metadata"
        msg.informativeText = "Please the new value you would like for the piece of data below:"
        
        //Opens a view to allow the user to edit the metadata
        let addDataView = AddMetadataView(frame: NSRect(x: 0, y: 0, width: 277, height: 63))
        addDataView.key.stringValue = (data?.keyword)!
        addDataView.key.isEnabled = false
        msg.accessoryView = addDataView
        let response: NSApplication.ModalResponse = msg.runModal()
        
        //if the user clicks "Edit metadata" button prompt opposed to "Cancel"
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            let value = addDataView.value.stringValue
            
            var indexToModify = -1;
            
            //gets the index of the metadata that is to be edited
            for i in 0..<viewFiles[currFileIndex]!.metadata.count where viewFiles[currFileIndex]!.metadata[i].keyword == data?.keyword {
                indexToModify = i
            }
            
            //modifies the metadata with new values
            if (indexToModify > -1) {
                viewFiles[currFileIndex]!.metadata[indexToModify].value = value
            }
            
            //reloads the table with the updated data
            dataTableView.reloadData()
        }
        
        
    }
    
    /// Removes the selected piece of metadata
    /// Users cannot remove required metadata ie Creator
    ///
    /// - Parameters:
    /// - sender: Remove Metadata button is clicked
    @IBAction func btnRemoveData(_ sender: Any) {
        
        //Gets the selected rows
        let dataIndexesSelected = dataTableView.selectedRowIndexes
        var dataIndexes = Array(dataIndexesSelected)
        dataIndexes.reverse()
        
        //Alert pop up asking for user confirmation to remove selected metadata
        let msg = NSAlert()
        msg.addButton(withTitle: "Remove")      // 1st button
        msg.addButton(withTitle: "Cancel")  // 2nd button
        msg.messageText = "Are you sure you want to remove the following metadata:"
        
        var info = ""
        
        for i in dataIndexes {
            info.append("\"")
            info.append((viewFiles[currFileIndex]?.metadata[i].keyword)!)
            info.append(" ")
            info.append((viewFiles[currFileIndex]?.metadata[i].value)!)
            info.append("\"")
            info.append("\n")
        }
        
        msg.informativeText = info
        
        //gets the response from the user
        let response: NSApplication.ModalResponse = msg.runModal()
        
        
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            //Need to check if data is needed
            let required = ["creator", "resolution", "runtime"]
            var errorMessage = ""
            
            //remove the selected metadata if it isnt "required"
            for i in dataIndexes {
                if (!required.contains((viewFiles[currFileIndex]?.metadata[i].keyword)!)) {
                    viewFiles[currFileIndex]?.metadata.remove(at: i)
                    
                //stops the user from removing required metadata and alerts the user that it failed.
                } else {
                    errorMessage.append((viewFiles[currFileIndex]?.metadata[i].keyword)!)
                    errorMessage.append(" is a required piece of metadata and cannot be removed.\n")
                }
            }
            
            if (!errorMessage.isEmpty) {
                let msg = NSAlert()
                msg.messageText = "The following pieces of metadata are required and cannot be removed:"
                msg.informativeText = errorMessage
                msg.runModal()
            }
            
            dataTableView.reloadData()
        }
        
    }

    /// Action plays current files audio (if valid) when "Play" button is clicked
    ///
    /// - Parameters:
    /// - sender: Play button is clicked
    @IBAction func play(_ sender: NSButtonCell) {
        
        
        if(viewFiles[currFileIndex]?.type == "audio"){
            playButton.isEnabled = false    //disables the play button if audio is playing
            pauseButton.isEnabled = true    //enables pause button if audio is playing
            soundPlayer.play()              //starts the audio file
        } else {
            //if the current file isnt an audio file, play and pause button are disabled.
            playButton.isEnabled = false
            pauseButton.isEnabled = false
        }
    }
    
    /// Action pauses the current files audio when "Pause" button is clicked
    ///
    /// - Parameters:
    /// - sender: Pause button is clicked
    @IBAction func pauseButton(_ sender: NSButtonCell) {
        
        //enables/disables play/pause buttons appropriately
        pauseButton.isEnabled = false
        playButton.isEnabled = true
        
        //pauses audio
        soundPlayer.pause()
    }
    
    /// Updates the different UI objects that are shown
    /// Only shows objects relevant to current files media type
    /// Action pauses the current files audio when "Pause" button is clicked
    @objc func updateMediaPreview(){
        
        txtView.isHidden = true
        txtHolder.isHidden = true
        imageWell.isHidden = true
        videoPlayer.isHidden = true
        pdfViewer.isHidden = true
        playButton.isHidden = true
        pauseButton.isHidden = true
        extNotSupported.isHidden = true
        audioBox.isHidden = true
        prevNotAvailable.isHidden = true
        
        
        //Gets the current file and its filepath
        let selectedFile = viewFiles[currFileIndex]
        let filePath = getFilePath(from: (viewFiles[currFileIndex]?.url)!)
        
        //Finds the file extension (based on . occurance)
        let seperatedPath = filePath.split(separator: ".")
        let fileExtension = (seperatedPath[seperatedPath.count-1]).lowercased()
        
        //checks if it is a valid file extension
        let validResult = validExtensions.contains(where: fileExtension.contains)
        
        if (validResult) {
            //if the selected file type is a document
            if (selectedFile?.type == "document") {


                //if the document is of type .pdf
                if (fileExtension == "pdf"){

                    //Gets NSURL to create pdfDocument
                    let fileURL = NSURL(fileURLWithPath: getFilePath(from: (selectedFile?.url)!))
                    
                    //creates PDFDocument object using selected files url
                    let pdfDocument = PDFDocument(url: fileURL as URL)
                    
                    if (pdfDocument != nil) {
                        
                        //sets the document and shows it
                        pdfViewer.document = pdfDocument
                        pdfViewer.isHidden = false
  
                    }  else {
                        
                        defaultWindows()
                    }
                    
                //else if the document is of .txt
                } else {
                    
                    //get the contents of the file and put it in the text box
                    do {
                        let contents = try String(contentsOfFile: getFilePath(from: filePath))
                        txtHolder.isEditable = true
                        txtHolder.string = contents
                        
                        
                        txtHolder.isEditable = false
                        txtHolder.isEditable = false
                        txtHolder.isHidden = false
                        txtView.isHidden = false
                        
                    } catch {
                        //if it failes show the default windows
                        defaultWindows()
                    }
                }
                
                //if the selected file type is a video
            } else if (selectedFile?.type == "video") {
                
                //gets appropriate type of url
                let filepath : String = NSString(string: filePath).expandingTildeInPath
                let fileURL = NSURL(fileURLWithPath: filepath)
                

                //sets up the video player
               // playView = AVPlayer(url: fileURL as URL)
                playView = AVPlayer(url: fileURL as URL)
                videoPlayer.player = playView
                videoPlayer.isHidden = false
                
                //if the selected file type is a image
            } else if (selectedFile?.type == "image"){
                
                //Creates NSImage and sets it
                let chosenImage = NSImage(byReferencingFile: filePath)
                
                if (chosenImage?.isValid)!{
                    imageWell.image = chosenImage
                    imageWell.isHidden = false
                } else {
                   // defaultWindows()
                }
                
            //if the selected file type is a audio
            } else if (selectedFile?.type == "audio"){
            
                //gets url for audio
                let url = URL(fileURLWithPath: getFilePath(from: filePath))
                
                //prepares the audio to play
                do {
    
                    soundPlayer = try AVAudioPlayer(contentsOf: url as URL)
                    soundPlayer.prepareToPlay()
                    
                    //Shows appropriate objects
                    audioBox.isHidden = false
                    playButton.isHidden = false
                    pauseButton.isHidden = false
                    pauseButton.isEnabled = false
                    
                } catch {
                    //shows the default window
                    defaultWindows()
                }
            }
            
        //if if doesnt have a valid extension show default
        } else {
            extNotSupported.isHidden = false
            imageWell.image = nil
            imageWell.isHidden = false
        }
    }
    
    /// Sets objects to show the default windows
    /// Used for when a file cannot be previewed
    /// Or the filepath is invalid
    func defaultWindows() {
        prevNotAvailable.isHidden = false
        imageWell.image = nil
        imageWell.isHidden = false
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
    
}

/// Extension needed for the tableview
/// Gets the amount of rows for the tables
/// Row number is equivalent to the metadata count of selected file
extension FileViewer: NSTableViewDataSource {
    func numberOfRows(in dataTableView: NSTableView) -> Int {
        return (viewFiles[currFileIndex]?.metadata.count)!
        
    }
}

/// Extension populates the tableView with appropriate data using CellID
extension FileViewer: NSTableViewDelegate {
    
    //list of tableView cells and their column identifiers
    fileprivate enum CellIdentifiers {
        static let KeyCell = "KeyCellID"
        static let ValueCell = "ValueCellID"
    }
    
    
    //Sets up the table view to populate it with information
    /// Action pauses the current files audio when "Pause" button is clicked
    ///
    /// - Parameters:
    /// - dataTableView: the table that will be populated with the data
    /// - tableColumm: the table column, identidied by the Cell Identifiers
    /// - row: the current row of the table
    ///
    /// - Returns:
    /// - nil
    func tableView(_ dataTableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        
        var text: String = ""   //String that will be the cells value
        var cellIdentifier: String = "" // Cell Identifer
        
        let currItem = viewFiles[currFileIndex] as File?
        
        guard let item = currItem?.metadata[row] else {
            return nil
        }
        
        //Populates table column with correct file values
        if tableColumn == dataTableView.tableColumns[0] {
            text = item.keyword
            cellIdentifier = CellIdentifiers.KeyCell
        } else if tableColumn == dataTableView.tableColumns[1] {
            text = item.value
            cellIdentifier = CellIdentifiers.ValueCell
        }
        
        //sets the table with appropriate cell values
        if let cell = dataTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        
        return nil
        
    }
    
    /// Monitors when the selected has changed.
    /// Enables and disables the remove metadata button when appropriate
    ///
    /// - Parameters:
    /// - notification: Notification indicating that the selection on the table has changed
    func tableViewSelectionIsChanging(_ notification: Notification) {
        
        let fileIndexesSelected = dataTableView.selectedRowIndexes
        let filesIndexes = Array(fileIndexesSelected)
        
        if (filesIndexes.count > 0) {
            btnRemoveData.isEnabled = true
        } else {
            btnRemoveData.isEnabled = false
        }
        
        if (filesIndexes.count == 1) {
            btnEditData.isEnabled = true
        } else {
            btnEditData.isEnabled = false
        }
        
        
    }
    
}
