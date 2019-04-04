//
//  ImagePreview.swift
//
//  Image Preview Controller
//  Used to implement the right most split of the app
//  Shows mini preview selecte file and displays some metadata, ie creator, name, runtime...)
//  Contains objects that will be shown/hidden depending on the type of media
//
//  Created by Daniela Lemow and Megan Seto on 24/09/18.
//

import Cocoa
import Quartz

/*
 * The class to represent the image preview.
 */
class ImagePreview: NSViewController {
    
    //Outlets to show information for selected file. Will update each time a new file is selected
    @IBOutlet weak var fileName : NSTextField!
    @IBOutlet weak var fileCreator : NSTextField!
    @IBOutlet weak var fileResolution : NSTextField!
    @IBOutlet weak var fileRuntime : NSTextField!
    
    //Outlets used for previewing media items. Will update each time new file/type is selected
    @IBOutlet weak var imageWell: NSImageView!
    @IBOutlet weak var noPreviewLabel: NSTextField!
    @IBOutlet weak var documentPreview: NSTextField!
    @IBOutlet weak var pdfPreview: PDFView!
    @IBOutlet weak var documentBox: NSBox!
    @IBOutlet weak var labelBox: NSBox!
    
    //Array of supported document formats. App only supports files with .txt and .pdf extension
    let validDocExt: [String] = ["txt", "pdf"]
    
    //if the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// The default setup sets appropriate outlets/objects to be hidden or shown
    /// Objects depend on media type.
    func defaultSetUp(){
        
        //hides the objects used for previewing
        documentBox.isHidden = true
        documentPreview.isHidden = true
        pdfPreview.isHidden = true
        imageWell.image = nil
        imageWell.isHidden = true
        noPreviewLabel.isHidden = true
        
        //shows necessary text labels
        labelBox.isHidden = false
        fileName.isHidden = false
        fileCreator.isHidden = false
        fileResolution.isHidden = false
        fileRuntime.isHidden=false
    }
    
    /// Called when an error occurs with opening a file. Will show "No preview available" in image well
    /// Used when type cannot be shown in mini preview. 
    func defaultWindows(){
        imageWell.image = nil
        imageWell.isHidden = false
        noPreviewLabel.isHidden = false
    }

}
