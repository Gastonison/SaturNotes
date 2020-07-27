//
//  Note.swift
//  SaturNotes
//
//  Created by Gaston Martin on 7/24/20.
//  Copyright © 2020 Gaston Martin. All rights reserved.
//

import Foundation
import RealmSwift

class Note: Object {
    override static func primaryKey() -> String? {
      return "id"
    }
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String?
    @objc dynamic var noteImage: NoteImage?
    @objc dynamic var stateString: String = NoteState.outOfDate.rawValue
    
    var state: NoteState {
        get {
            return NoteState(rawValue: stateString) ?? .upToDate
        }
        set {
            self.stateString = newValue.rawValue
        }
    }
    
    convenience init(json: [String: Any], state: NoteState, localResourceURL: String? = nil) {
        self.init()
        
        if let idVal = json["id"] as? Int {
            self.id = "\(idVal)"
        }
        
        self.title = json["title"] as? String

        if let imageJSON = json["image"] as? [String: Any] {
            self.noteImage = NoteImage(json: imageJSON, localResourceURL: localResourceURL)
            
            
        }
        
        self.state = state
        
    }
    
    convenience init(title: String, localResourceURL: String?) {
        self.init()
        
        self.title = title
        self.noteImage = NoteImage(localResourceURL: localResourceURL)
    }
    
    enum InitError: Error {
        case missingData
    }
    
    enum NoteState: String {
        case upToDate = "upToDate"
        case outOfDate = "outOfDate"
        case updating = "updating"
    }
}
