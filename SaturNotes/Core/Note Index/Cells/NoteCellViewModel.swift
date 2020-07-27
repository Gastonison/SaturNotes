//
//  NoteCellTableViewItem.swift
//  SaturNotes
//
//  Created by Gaston Martin on 7/24/20.
//  Copyright © 2020 Gaston Martin. All rights reserved.
//

import Foundation
import UIKit

class NoteCellViewModel: CellViewModel {
    
    var reuseId: String = "noteCellId"
    var height: CGFloat = 94
    
    var imageURLString: String?
    var title: String
    var state: Note.NoteState
    var id: String
    
    init(note: Note) {
        self.title = note.title ?? ""
        self.state = note.state
        self.id = note.id
        switch state {
        case .outOfDate, .updating:
            self.imageURLString = note.noteImage?.localResourceURL
        case .upToDate:
            self.imageURLString = note.noteImage?.imageURL(.small)?.absoluteString
        }
    }
    
}
