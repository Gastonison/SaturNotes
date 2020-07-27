//
//  ImageManager.swift
//  SaturNotes
//
//  Created by Gaston Martin on 7/26/20.
//  Copyright © 2020 Gaston Martin. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

extension UIImage {
    
    func saveToDocuments(callback: @escaping ((Result<String, Error>) -> Void)) {
        
        let queue = DispatchQueue(label: "save-queue")
        queue.async {
            guard let data = self.jpegData(compressionQuality: 0) else { return }
            
            guard let directory =
                try? FileManager.default.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false) as URL else {
                        return
            }
            
            let id = Utilities.randomString(length: 16)
            let filePath = "images/saturn_notes_\(id).jpg"

            let filename = directory.appendingPathComponent(filePath)
            let fm = FileManager.default
            
            if !fm.fileExists(atPath: directory.appendingPathComponent("images").path) {
                do {
                    try fm.createDirectory(
                        at: directory.appendingPathComponent("images"),
                        withIntermediateDirectories: true,
                        attributes: nil)
                }
                catch {
                    
                    callback(Result.failure(error))
                }
            }
            do {
                try data.write(to: filename)
                DispatchQueue.main.async {
                    callback(Result.success(filePath))
                }                
            }
            catch {
                callback(Result.failure(error))
            }
        }
                
    }
    
    enum SaveError: Error {
        case imageCouldNotBeSaved
    }
    
    static func loadImage(_ path: String) -> UIImage? {
        guard let dir = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false) else { return nil }
        
        
        return UIImage(
            contentsOfFile: URL(fileURLWithPath: dir.absoluteString)
                .appendingPathComponent(path).path)
        
    }
    
}
