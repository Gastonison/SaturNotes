//
//  NoteImage.swift
//  SaturNotes
//
//  Created by Gaston Martin on 7/25/20.
//  Copyright © 2020 Gaston Martin. All rights reserved.
//

import Foundation
import RealmSwift

class NoteImage: Object {
    
    @objc dynamic var id: String?
    @objc dynamic var contentType: String?
    @objc dynamic var resourceURL: String?
    @objc dynamic var localResourceURL: String?
    
    convenience init(json: [String: Any], localResourceURL: String? = nil) {
        self.init()
        
        self.id = json["id"] as? String
        self.contentType = json["content_type"] as? String
        self.resourceURL = json["resource_url"] as? String
        self.localResourceURL = localResourceURL
        
    }
    
    convenience init(localResourceURL: String?) {
        self.init()
        self.localResourceURL = localResourceURL
    }
    
    func imageURL(_ type: ImageSize) -> URL? {
        guard let resourceURL = resourceURL,
            let contentType = contentType,
            let urlString = resourceURL.components(separatedBy: ".\(contentType)").first
            else { return nil }
        
        switch type {
        case .small:
            return URL(string: resourceURL)
        case .medium:
            return URL(string: "\(urlString)@2x.\(contentType)")
        case .large:
            return URL(string: "\(urlString)@3x.\(contentType)")
        }
        
    }
    
    enum ImageSize {
        case small
        case medium
        case large
    }

    
    enum InitError: Error {
        case missingData
    }
    
}
