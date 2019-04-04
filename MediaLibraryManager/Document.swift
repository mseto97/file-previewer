//
//  Document.swift
//  MediaLibraryManager
//
//  Created by Daniela Lemow on 30/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

class Document : Media {
    
    override init(filename: String, path: String, type: String, metadata: [Metadata]) {
        super.init(filename: filename, path: path, type: type, metadata: metadata)
        self.metadata.append(Metadata(keyword: "-d", value: "document"))
    }
}
