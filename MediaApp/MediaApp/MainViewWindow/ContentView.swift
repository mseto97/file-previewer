//
//  ContentView.swift
//  MediaApp
//
// ContentView used for making the ContentView
//
//  Created by Daniela Lemow and Megan Seto on 23/09/18.
//  Copyright © 2018 Megan. All rights reserved.
//

import Cocoa
import AppKit
import AVKit
import Quartz

///
/// This class represents the "ContentView"
/// Class allows you to import valid json files and populate a table and open them
///
class ContentView: NSViewController {
    
    //Gives the content view a reference to the bookmark view, the image preview, and the main window
    var bookmarkView : BookmarkView!
    var imagePreview : ImagePreview!
    var mainWindow: MainWindowController!
    
    
    //Outlet reference to tableView (table that shows imported items)
    @IBOutlet weak var tableView: NSTableView!
    
    //Outlets buttons for importing/exporting
    @IBOutlet weak var btnExportFiles: NSButton!
    @IBOutlet weak var btnViewFile: NSButton!
    
    //Outlet buttons for adding files to a bookmark
    @IBOutlet weak var btnAddToBookmark: NSButton!
    
    //Outlet buttonf or opening a file to view
    @IBOutlet weak var btnProjectorView: NSButton!
    
    //Search outlet
    @IBOutlet weak var searchText : NSSearchFieldCell!
    
    // Array of valid imported files
    var fileItems: [File?] = []
    
    init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?, bookmarks : BookmarkView, preview : ImagePreview, mainWindow: MainWindowController) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.bookmarkView = bookmarks
        self.imagePreview = preview
        self.mainWindow = mainWindow
    
        /** Allows persistent storage and for files to be loaded upon start**/
//        //loads the files from the previous application session back into the library
//        let homeDirectory = (FileManager.default.homeDirectoryForCurrentUser.absoluteString).replacingOccurrences(of: "file://", with: "")
//        let fileToLoadFrom = homeDirectory + "Library/Application Support/MediaApp/library.json"
//        fileItems = CommandController.load(from: fileToLoadFrom)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    ///Function that gets called when view/UI loads on screen
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableViews data source and delegate will be the view controller.
        tableView.delegate = self //as NSTableViewDelegate
        tableView.dataSource = self //as NSTableViewDataSource
        
        //used for responding to double clicks
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        
        //disables uneeded UI objects
        btnExportFiles.isEnabled = false
        btnViewFile.isEnabled = false
        btnProjectorView.isEnabled = false
        btnAddToBookmark.isEnabled = false
        tableView.allowsColumnReordering = false
        
        //updates the bookmark tables with appropriate files
        bookmarkView.updateBasicBookmarks()
        
    }
    
    
    override func viewDidAppear() {
        mainWindow.window?.makeFirstResponder(self)
    }
    
    
    /// Gets keyboard keyDown events and execute code for particular keys
    ///
    /// - Parameters:
    /// - event: the event that may correspond with a keyCode code
    override func keyDown(with event: NSEvent) {
        
        let keyCode = event.keyCode
        
        // Enter key opens the File View on the selected item
        if (keyCode == 36){
            
            guard tableView.selectedRow >= 0 else {
                return
            }
            if fileItems.count > 0 {
                mainWindow.openFileView(with: &fileItems, from: tableView.selectedRow)
            }
        }
        
        // Space bar opens the file view on the selected items
        if (keyCode == 49) {
            guard tableView.selectedRow >= 0 else {
                return
            }
            if fileItems.count > 0 {
                mainWindow.openFileView(with: &fileItems, from: tableView.selectedRow)
            }
        }
    }
    
    /// Sets the fileItems
    ///
    /// - Parameters:
    /// - files: files that will be in fileItems
    func setFiles(to files: [File]) {
        self.fileItems = files
    }
    
    
    /// Search bar filters files in table on users input
    /// Search performed on metadata
    ///
    /// - Parameters:
    /// - sender: Objects that executes the action (enter key pressed in the search bar)

    @IBAction func btnSearch(_ sender: Any) {
        
        //Get the value the user has typed in from the search field
        let searchString = searchText.stringValue
        
        //If the search string is empty, update file items to contain the selected bookmark's files,
        //and reload the tableView to reflect this.
        if searchString.isEmpty {
            fileItems = (BookmarkView.bookmarks[bookmarkView.tableView.selectedRow]?.files)!
            tableView.reloadData()
        } else {
            
            //Get the list of files contained in the selected bookmark
            let filesSelected = (BookmarkView.bookmarks[bookmarkView.tableView.selectedRow]?.files)!
            
            //Perform a search for the specified term in the selected files, and store the result in fileItems
            fileItems = CommandController.search(for: searchString, in: filesSelected)
            tableView.reloadData()  //Reload the tableView to show the resulting files.
        }
        
    }
    
    /// Exports selected files
    ///
    /// - Parameters:
    /// - rawpath: The raw path to manipulate the full path to a file from.
    @IBAction func btnExportFiles(_ sender: Any) {
        
        //Opens a panel that allows the user to select location to export file to
        let fileSaver: NSSavePanel = NSSavePanel()
        fileSaver.runModal()
        let saveLocation = fileSaver.url!
        
        //Gets the selected files for import and puts them in a file array
        let fileIndexesSelected = tableView.selectedRowIndexes
        let filesIndexes = Array(fileIndexesSelected)
        var filesSelected : [File] = []
        
        
        for i in 0..<fileItems.count where filesIndexes.contains(i) {
            filesSelected.append(fileItems[i]!)
        }
        
        CommandController.updateSelectedFiles(add: filesSelected)
        CommandController.export(to: saveLocation)
    }
    
    
    ///btnImportFiles action imports selected json files into the app
    ///presents sucesfully imported files on the tableView
    ///
    /// - Parameters:
    /// - sender: The raw path to manipulate the full path to a file from.
    @IBAction func btnImportFiles(_ sender: Any) {
        
        let filePicker: NSOpenPanel = NSOpenPanel()
        
        filePicker.allowsMultipleSelection = true //allows the user to select more than one file
        filePicker.canChooseDirectories = false //allows the user to pick multiple directories
        filePicker.canChooseFiles = true
        filePicker.allowedFileTypes = ["json"] //only allow json files to be chosen
        filePicker.runModal()
        
        //Get the url's of the files the user has chosen
        let chosenFiles = filePicker.urls
        
        guard !chosenFiles.isEmpty else {
            return
        }
        
        // Allows more files to be imported and added to the viewTable.
        // Do we want to be able to import the same file twice? If not then this doesnt work as it should
        if fileItems.count > 0 {
            tableView.reloadData()
        }
        
        do {
            //Use the load handler to load the files into the Library
            fileItems.append(contentsOf: try CommandController.load(from: chosenFiles))
            bookmarkView.updateBasicBookmarks()
        } catch {
            print("Naughty") //Fix this hahaha
        }
        
        //refreshes the table to update
        tableView.reloadData()
        
        
        //Error message window should only pop up if there are errors to show
        if (IEManager.errorMessages.count > 1){
            
            //Display any import errors in an alert
            let errorMessage = NSAlert()
            errorMessage.accessoryView = NSView(frame: NSMakeRect(0, 0, 350, 0))
            errorMessage.window.title = "Import Errors"
            errorMessage.messageText = IEManager.errorMessages
            errorMessage.runModal()
        }
    }
    
    /// Implements double click to open File Viewer on selected file
    ///
    /// - Parameters:
    /// - sender: doubleclick that executes the action
    @objc func tableViewDoubleClick(_ sender: AnyObject) {
        
        //Checks the double click was on an existing item in the tableView
        guard tableView.selectedRow >= 0 else {
            return
        }
        
        //If there is at least one file to view, open the file view with the files in the view,
        //and the selected item.
        if fileItems.count > 0 {
            mainWindow.openProjectorView(with: (fileItems[tableView.selectedRow]?.url)!, and: (fileItems[tableView.selectedRow]?.type)!)
        }
        
    }
    
    /// Opens the selected file in a Projector View window
    ///
    /// - Parameters:
    /// - sender: User clicks Show File Info/presses enter key or space bar

    @IBAction func btnViewFile(_ sender: Any) {
        
        //Checks the double click was on an existing item in the tableView
        guard tableView.selectedRow >= 0 else {
            return
        }
        
        //If there is at least one file to view, open the file view with the files in the view,
        //and the selected item.
        if fileItems.count > 0 {
            mainWindow.openFileView(with: &fileItems, from: tableView.selectedRow)
        }
    }
    

    /// Opens the File Viewer window for the selected file
    /// - Parameters:
    /// - sender: View File... button that calls the action to execute

    @IBAction func btnProjectorView(_ sender: Any) {
        
        //Checks the double click was on an existing item in the tableView
        guard tableView.selectedRow >= 0 else {
            return
        }
        
        //If there is at least one file to view, open the file view with the files in the view,
        //and the selected item.
        if fileItems.count > 0 {
            mainWindow.openProjectorView(with: (fileItems[tableView.selectedRow]?.url)!, and: (fileItems[tableView.selectedRow]?.type)!)
        }
    }
    
    
    /// btnAddToBookmark adds selected file(s) to an existing bookmark
    ///
    /// - Parameters:
    /// - sender: "Add to bookmarks" button is clicked
    @IBAction func btnAddToBookmark(_ sender: Any) {
        
        //gets the index of the selected files from the table
        let fileIndexesSelected = tableView.selectedRowIndexes
        let filesIndexes = Array(fileIndexesSelected)
        
        // Asks user if they want to add files to the selected bookmark or cancel
        let msg = NSAlert()
        msg.messageText = "Select the Bookmark you would like to add the file(s) to:"
        msg.addButton(withTitle: "Add")      // 1st button
        msg.addButton(withTitle: "Cancel")
        
        // Cannot add files to default bookmarks
        let nonAddable = ["All", "Audio", "Videos", "Documents", "Images"]
        
        //playlist holds existing bookmarks that user can add selected files to
        let playlists = NSComboBox(frame: NSRect(x: 0, y: 0, width: 230, height: 30))
        playlists.isEditable = false
        for bookmark in BookmarkView.bookmarks {
            let bookmarkTitle = bookmark?.bookmarkTitle
            if (!nonAddable.contains(bookmarkTitle!)) {
                playlists.addItem(withObjectValue: bookmarkTitle!)
            }
        }
        
        playlists.selectItem(at: 0)
        
        msg.accessoryView = playlists
        let response: NSApplication.ModalResponse = msg.runModal()
        
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            if (filesIndexes.count == 1) {
                bookmarkView.add(file: fileItems[tableView.selectedRow]!, to: (playlists.selectedCell()?.stringValue)!)
            } else if filesIndexes.count > 1 {
                
                var filesToAdd : [File] = []
                
                for i in filesIndexes {
                    filesToAdd.append(fileItems[Int(i)]!)
                }
                
                bookmarkView.add(files: filesToAdd, to: (playlists.selectedCell()?.stringValue)!)
                
            }
        }
        
    }
}//end ContentView class


/// Extension needed for the tableview. Implements required protocol
/// Gets the amount of rows for the tables
/// Row number is equivalent to the amount of files imported
extension ContentView: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return fileItems.count
    }
}

/// Extension populates the tableView with appropriate data using CellID
extension ContentView: NSTableViewDelegate {
    
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
    
    //list of tableView cells and their column identifiers
    fileprivate enum CellIdentifiers {
        static let BookMarkCell = "BookMarkCellID"
        static let NameCell = "NameCellID"
        static let TypeCell = "TypeCellID"
        static let CreatorCell = "CreatorCellID"
        static let ResolutionCell = "ResolutionCellID"
        static let RuntimeCell = "RuntimeCellID"
    }
    
    //Sets up the table view to populate it with information
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
        guard let item = fileItems[row] else {
            return nil
        }
        
        //Populates table column with correct file values
        if tableColumn == tableView.tableColumns[0] {
            cellIdentifier = CellIdentifiers.BookMarkCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.name
            cellIdentifier = CellIdentifiers.NameCell
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.type
            cellIdentifier = CellIdentifiers.TypeCell
        } else if tableColumn == tableView.tableColumns[3] {
            text = item.creator
            cellIdentifier = CellIdentifiers.CreatorCell
        } else if tableColumn == tableView.tableColumns[4] {
            text = item.resolution
            cellIdentifier = CellIdentifiers.ResolutionCell
        }  else if tableColumn == tableView.tableColumns[5] {
            text = item.runtime
            cellIdentifier = CellIdentifiers.RuntimeCell
        }
        
        //sets the cells in the tables to appropriate file values
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        //Get the index selected row
        let row = tableView.selectedRow
        
        let fileIndexesSelected = tableView.selectedRowIndexes
        let filesIndexes = Array(fileIndexesSelected)
        
        if (filesIndexes.count == 1 && BookmarkView.bookmarks.count > 5) {
            btnAddToBookmark.isEnabled = true
        } else if BookmarkView.bookmarks.count == 5 {
            btnAddToBookmark.isEnabled = false
        }
        
        //If one or more files are selected, enable the export button,
        //otherwise disable it
        if filesIndexes.count == 1 {
            btnViewFile.isEnabled = true
            btnProjectorView.isEnabled = true
            btnAddToBookmark.isEnabled = true
        } else {
            btnViewFile.isEnabled = false
            btnProjectorView.isEnabled = false
        }
        
        if filesIndexes.count > 0 {
            btnExportFiles.isEnabled = true
        } else {
            btnExportFiles.isEnabled = false
        }
        
        if filesIndexes.count >= 1 && BookmarkView.bookmarks.count > 5 {
             btnAddToBookmark.isEnabled = true
        } else {
             btnAddToBookmark.isEnabled = false
        }
        
        if (filesIndexes.count == 1) {
            
            //hides objects for previewing media
            imagePreview.defaultSetUp()
            
            let selectedFile = fileItems[row]
            imagePreview.fileName.stringValue = (selectedFile?.name)!
            imagePreview.fileCreator.stringValue = (selectedFile?.creator)!
            imagePreview.fileResolution.stringValue = (selectedFile?.resolution)!
            imagePreview.fileRuntime.stringValue = (selectedFile?.runtime)!
            
            //previewing data in the "image preview split"
            if (selectedFile?.type == "image"){
                
                let chosenImage = NSImage(contentsOfFile: getFilePath(from: (selectedFile?.url)!))
                if (chosenImage != nil){
                    imagePreview.imageWell.isHidden = false
                    imagePreview.imageWell.image = chosenImage
                } else {
                    imagePreview.defaultWindows()
                }
                
            } else if (selectedFile?.type == "document"){
                
                //Finds the file extension (based on . occurance)
                let seperatedPath = (selectedFile?.url)!.split(separator: ".")
                let fileExtension = (seperatedPath[seperatedPath.count-1]).lowercased()
                
                //checks if file contains valid extension
                let validResult = imagePreview.validDocExt.contains(where: fileExtension.contains)
                //if the extension is valid
                if (validResult){
                    //if the document is a pdf
                    if (fileExtension == "pdf") {
                        let fileURL = NSURL(fileURLWithPath: (getFilePath(from: (selectedFile?.url)!)))
                        let pdfDocument = PDFDocument(url: fileURL as URL)
                        
                        //shows appropriate windows
                        if (pdfDocument != nil) {
                            //sets the document and shows it
                            imagePreview.pdfPreview.document = pdfDocument
                            imagePreview.pdfPreview.isHidden = false
                        
                        //file couldnt be opened due to bad file path
                        }  else {
                            imagePreview.defaultSetUp()
                            imagePreview.defaultWindows()
                        }
                    
                    //assumes file has .txt extension
                    } else {
                        
                        do {
                            let contents = try String(contentsOfFile: getFilePath(from: (selectedFile?.url)!))
                            imagePreview.documentBox.isHidden = false
                            imagePreview.documentPreview.stringValue = contents
                            imagePreview.documentPreview.isEditable = false
                            imagePreview.documentPreview.isHidden = false
                        
                        //file couldnt be opened due to incorrect file path
                        } catch {
                            imagePreview.defaultWindows()
                        }
                    }
                
                //if the extension is not a supported document file format
                } else {
                    imagePreview.defaultSetUp()
                    imagePreview.defaultWindows()
                }
            
            //if the file is a video or audio
            } else {
                imagePreview.defaultSetUp()
                imagePreview.defaultWindows()
            }
            
        //Sets the initial label values in "ImagePreview" to empty equivalents
        } else if filesIndexes.count == 0 || filesIndexes.count > 1 {
            
            imagePreview.fileName.stringValue = "---"
            imagePreview.fileCreator.stringValue = "---"
            imagePreview.fileResolution.stringValue = "---"
            imagePreview.fileRuntime.stringValue = "---"
            
        }
        
        
        /// Monitors when the selected has changed.
        /// Enables and disables buttons when appropriate
        /// Updates the image preview view with appropriate values
        ///
        /// - Parameters:
        /// - notification: Notification indicating that the selection on the table has changed
        func tableViewSelectionIsChanging(_ notification: Notification) {
            
            //Get the index selected row
            let row = tableView.selectedRow
            
            let fileIndexesSelected = tableView.selectedRowIndexes
            let filesIndexes = Array(fileIndexesSelected)
            
            if (filesIndexes.count == 1 && BookmarkView.bookmarks.count > 5) {
                btnAddToBookmark.isEnabled = true
            } else if BookmarkView.bookmarks.count == 5 {
                btnAddToBookmark.isEnabled = false
            }
            
            //If one or more files are selected, enable the export button,
            //otherwise disable it
            if (filesIndexes.count == 1) {
                
                //hides objects for previewing media
                imagePreview.defaultSetUp()
                
                let selectedFile = fileItems[row]
                imagePreview.fileName.stringValue = (selectedFile?.name)!
                imagePreview.fileCreator.stringValue = (selectedFile?.creator)!
                imagePreview.fileResolution.stringValue = (selectedFile?.resolution)!
                imagePreview.fileRuntime.stringValue = (selectedFile?.runtime)!
                
                //previewing data in the "image preview split"
                if (selectedFile?.type == "image"){
                    
                    let chosenImage = NSImage(contentsOfFile: getFilePath(from: (selectedFile?.url)!))
                    if (chosenImage != nil){
                        imagePreview.imageWell.isHidden = false
                        imagePreview.imageWell.image = chosenImage
                    } else {
                        imagePreview.defaultWindows()
                    }
                    
                } else if (selectedFile?.type == "document"){
                    
                    //Finds the file extension (based on . occurance)
                    let seperatedPath = (selectedFile?.url)!.split(separator: ".")
                    let fileExtension = (seperatedPath[seperatedPath.count-1]).lowercased()
                    
                    //checks if file contains valid extension
                    let validResult = imagePreview.validDocExt.contains(where: fileExtension.contains)
                    
                    //if the extension is valid
                    if (validResult){
                        
                        //if the document is a pdf
                        if (fileExtension == "pdf") {
                            let fileURL = NSURL(fileURLWithPath: (selectedFile?.url)!)
                            let pdfDocument = PDFDocument(url: fileURL as URL)
                            
                            //shows appropriate windows
                            if (pdfDocument != nil) {
                                //sets the document and shows it
                                imagePreview.pdfPreview.document = pdfDocument
                                imagePreview.pdfPreview.isHidden = false
                                
                                //file couldnt be opened due to bad file path
                            }  else {
                                imagePreview.defaultWindows()
                            }
                            
                            //assumes file has .txt extension
                        } else {
                            
                            do {
                                let contents = try String(contentsOfFile: (selectedFile?.url)!)
                                imagePreview.documentPreview.stringValue = contents
                                imagePreview.documentPreview.isEditable = false
                                imagePreview.documentPreview.isHidden = false
                                imagePreview.documentBox.isHidden = false
                                
                                //file couldnt be opened due to incorrect file path
                            } catch {
                                imagePreview.defaultWindows()
                            }
                        }
                        
                        //if the extension is not a supported document file format
                    } else {
                        imagePreview.defaultSetUp()
                        imagePreview.defaultWindows()
                    }
                    
                    //if the file is a video or audio
                } else {
                    imagePreview.defaultSetUp()
                    imagePreview.defaultWindows()
                }
                //Sets the initial label values in "ImagePreview" to empty equivalents
            } else if filesIndexes.count == 0 || filesIndexes.count > 1 {
                
                imagePreview.fileName.stringValue = "---"
                imagePreview.fileCreator.stringValue = "---"
                imagePreview.fileResolution.stringValue = "---"
                imagePreview.fileRuntime.stringValue = "---"
                
            }
        }
    }
}

