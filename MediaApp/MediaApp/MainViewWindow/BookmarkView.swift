//
//  BookmarkView.swift
//  MediaApp
//
// BookmarkView is used to make the Bookmark View Panel (Left panel)
//
//  Created by Daniela Lemow and Megan Seto on 23/09/18.
//  Copyright © 2018 Megan. All rights reserved.
//

import Cocoa
/*
 * The class to represent the bookmark view.
 */
class BookmarkView: NSViewController {
    
    //The data field that stores the bookmarks collection
    static var bookmarks : [Files?] = [Files(files: [], name: "All"), Files(files: [], name: "Audio"), Files(files: [], name: "Documents"), Files(files: [], name: "Images"), Files(files: [], name: "Videos")]
  
    
   //Lets the bookmark view know about the content view
    var contentView : ContentView!
    
    //Button outlets for adding and removing bookmarks
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    
    //Table outlet, tableview that represents the existing bookmarks and shows them to the user
    @IBOutlet weak var tableView: NSTableView!
    
    
    //Function is called when the Bookmark View loads
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self //as NSTableViewDelegate
        tableView.dataSource = self //as NSTableViewDataSource
        tableView.allowsMultipleSelection = false
        
        //reloads the table with updated data/new bookmarks
        tableView.reloadData()
        tableView.selectRowIndexes(IndexSet([0]), byExtendingSelection: true)
        
        //disables the button used for removing bookmarks
        btnRemove.isEnabled = false
    }
    
    /// Called when user imports files
    /// Populates the default bookmarks (Audio, Document, Image, Video) with appropriate files
    /// Default bookmarks are "All", "Document", "Image", "Video"
    func updateBasicBookmarks() {
        BookmarkView.bookmarks[0]?.files = CommandController.allFiles()
        BookmarkView.bookmarks[1]?.files = CommandController.filter(by: "-a")
        BookmarkView.bookmarks[2]?.files = CommandController.filter(by: "-d")
        BookmarkView.bookmarks[3]?.files = CommandController.filter(by: "-i")
        BookmarkView.bookmarks[4]?.files = CommandController.filter(by: "-v")
    }
    
    /// 
    ///
    /// - Parameters:
    /// - view:
    func setContentView(to view: ContentView) {
        self.contentView = view
    }
    
    /// Function creates a new bookmark
    ///
    /// - Parameters:
    /// - bookmark: the Array files to add to the bookmark
    /// - name: bookmark to add the files to
    func add(bookmark: [File], with name: String) {
        BookmarkView.bookmarks.append(Files(files: bookmark, name: name))
    }
    
    
    /// Adds a file to a bookmark
    /// The selected file is added to the selected bookmark
    ///
    /// - Parameters:
    /// - file: the selected file
    /// - bookmark: the bookmark to add the file to
    func add(file: File, to bookmark: String) {
        
        var bookmarkIndex = -1
        
        //finds the desired bookmarks index
        for i in 1..<BookmarkView.bookmarks.count where BookmarkView.bookmarks[i]?.bookmarkTitle == bookmark {
            bookmarkIndex = i
        }
        
        //adds the file to the bookmark if its index is valid
        if (bookmarkIndex > -1) {
            BookmarkView.bookmarks[bookmarkIndex]?.files.append(file)
        }
        
    }
    
    /// Adds multiple files to a bookmark
    /// selected files are added to the selected bookmark
    ///
    /// - Parameters:
    /// - files: the array that holds the files to be added to the bookmark
    /// - bookmark: the bookmark to add the files to
    func add(files: [File], to bookmark: String) {
        
        var bookmarkIndex = -1
        
        for i in 1..<BookmarkView.bookmarks.count where BookmarkView.bookmarks[i]?.bookmarkTitle == bookmark {
            bookmarkIndex = i
        }
        
        if (bookmarkIndex > -1) {
            BookmarkView.bookmarks[bookmarkIndex]?.files.append(contentsOf: files)
        }
        
    }
    
    /// Action creates a new bookmark.
    ///
    /// - Parameters:
    /// - Any: + (Add bookmark) button that calls the action to execute
    ///
    /// - Returns:
    /// - nil: if the users cancels action
    @IBAction func btnAdd(_ sender: Any) {
        
        let bookmarkTitle = getString(title: "Enter Bookmark Name:", question: "What would you like to name the bookmark?", defaultValue: "")
        
        if bookmarkTitle.isEmpty {
            return
        } else {
            //adds the bookmark to the table and reloads the bookmark with appropriate data
            add(bookmark: [], with: bookmarkTitle)
            tableView.reloadData()
        }
        
    }
    
    /// Deletes the selected bookmark.
    ///
    /// - Parameters:
    /// - Any: - (Remove Bookmark) button that calls the action to execute
    @IBAction func btnRemove(_ sender: Any) {
        
        //gets the selected bookmark that is to be deleted
        let selectedBookmark = BookmarkView.bookmarks[tableView.selectedRow]?.bookmarkTitle

        //An alert is created asking the user if they want to delete the bookmark
        let msg = NSAlert()
        msg.accessoryView = NSView(frame: NSMakeRect(0, 0, 350, 0))
        msg.addButton(withTitle: "Delete Bookmark")
        msg.addButton(withTitle: "Cancel")
        msg.messageText = "Are you sure you want to delete the bookmark:\n\(String(selectedBookmark!))?"
       
        let response: NSApplication.ModalResponse = msg.runModal()
        
        //if the user wants to delete the bookmark the selected bookmark is removed
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            BookmarkView.bookmarks.remove(at: tableView.selectedRow)
            
            //reloads the table view with valid bookmarks
            tableView.reloadData()
            tableView.selectRowIndexes(IndexSet([0]), byExtendingSelection: true)
        }
        
    }
    
    //Referenced in report, gets a String from a user using an alert
    //https://stackoverflow.com/questions/28362472/is-there-a-simple-input-box-in-cocoa
    func getString(title: String, question: String, defaultValue: String) -> String {
        let msg = NSAlert()
        msg.addButton(withTitle: "Add Bookmark")      // 1st button
        msg.addButton(withTitle: "Cancel")  // 2nd button
        msg.messageText = title
        msg.informativeText = question
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 230, height: 24))
        txt.stringValue = defaultValue
        
        msg.accessoryView = txt
        let response: NSApplication.ModalResponse = msg.runModal()
        
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            return txt.stringValue
        } else {
            return ""
        }
    }
    
}

/// Extension needed for the tableview. Implements required protocol
/// Gets the amount of rows for the tables
/// Row number is equivalent to the amount of bookmarks that have been created
extension BookmarkView: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return BookmarkView.bookmarks.count
    }
}


/// Extension populates the tableView with appropriate data using CellIdentifiers
/// NSTableViewDelegate allows the Bookmark's table and behaviour to be customised
/// Provides views for the rows and columns
extension BookmarkView: NSTableViewDelegate {
    
    // The Valid cell/column identifier
    fileprivate enum CellIdentifiers {
        static let BookMarkCell = "bookmarkCellID"
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier: String = ""
        
        //gets a row in the table that will be populated with data, else returns nil
        guard let item = BookmarkView.bookmarks[row] else {
            return nil
        }
        
        //Identifies the first/only column in the Bookmark table, identifying it with the bookmark cell's ID
        if tableColumn == tableView.tableColumns[0] {
            text = item.bookmarkTitle
            cellIdentifier = CellIdentifiers.BookMarkCell
        } 
        
        //sets the table cell with the value
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    
    /// Tells the table views delegate that the view is in the process of changing
    /// When a different bookmark is selected by the user, the Content tableview is reloaded
    /// with files that have been added to the selected bookmark
    ///
    /// - Parameters:
    /// - notfication: A notification that tells the delegate that the view is changing
    ///
    func tableViewSelectionIsChanging(_ notification: Notification) {
        
        let row = tableView.selectedRow
        
        //When a new bookmark is selected
        if (contentView.tableView.selectedRow != -1) {
            contentView.tableView.deselectAll(nil) //deselect the files in the content view
            contentView.btnViewFile.isEnabled = false //disable the preview file button
        }
        
        if (row != -1) {
            contentView.setFiles(to: (BookmarkView.bookmarks[row]?.files)!)
            contentView.tableView.reloadData()
        }
        
        // doesnt allow you to remove bookmarks if there are only 4 bookmarks
        // The existing 4 bookmarks are the default bookmarks that users cannot delete (all, document...)
        if (row < 5) {
            btnRemove.isEnabled = false
        } else {
            btnRemove.isEnabled = true
        }
    }

}
