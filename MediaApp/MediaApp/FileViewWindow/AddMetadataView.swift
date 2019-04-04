//
//  AddMetadataView.swift
//  MediaApp
//
//  Created by Daniela Lemow and Megan Seto on 2/10/18.
//  Copyright © 2018 Megan. All rights reserved.
//

import Cocoa
/* AddMetaData View used in  FileViewer window
 * Allows users to enter new metadata key and value into a file
 */
class AddMetadataView: NSView {
    
    //The objects used to take user input values
    @IBOutlet weak var addMetadataView : NSView!
    @IBOutlet weak var key: NSTextField!
    @IBOutlet weak var value: NSTextField!
    

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        Bundle.main.loadNibNamed("AddMetadataView", owner: self, topLevelObjects: nil)
        
        //creates the frames for the outlets/textfields
        let contentFrame = NSMakeRect(0, 0, frame.size.width, frame.size.height)
        self.frame = contentFrame
        
        self.addSubview(self.addMetadataView)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
