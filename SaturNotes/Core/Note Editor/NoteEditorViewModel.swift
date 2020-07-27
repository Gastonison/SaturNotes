//
//  NoteEditorViewModel.swift
//  SaturNotes
//
//  Created by Gaston Martin on 7/24/20.
//  Copyright © 2020 Gaston Martin. All rights reserved.
//

import Foundation
import RealmSwift
import SDWebImage

protocol NoteEditorViewModelDelegate: class {
    // didn't add anything to it but on a prod app with more functionality would be useful
    
}

class NoteEditorViewModel {
    
    weak var delegate: NoteEditorViewModelDelegate?
    var callback: ((Result<Note, Error>) -> Void)?
    var imageURL: String?
    
    init(delegate: NoteEditorViewModelDelegate,
         callback: ((Result<Note, Error>) -> Void)?) {
        self.delegate = delegate
        
        self.callback = {callback?($0)}
        
    }
    
    func doneTapped(title: String, image: UIImage) {
     
        image.saveToDocuments { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let imageURL):
                strongSelf.imageURL = imageURL
                let image = UIImage.loadImage(imageURL)
                SDImageCache
                    .shared
                    .store(image,
                           imageData: image?.jpegData(compressionQuality: 1.0),
                           forKey: imageURL,
                           cacheType: .all)
                let note = Note(title: title, localResourceURL: imageURL)
                
                let realm = try! Realm()
                
                try! realm.write {
                    realm.add(note)
                }
                
                strongSelf.callback?(Result.success(note))
                
            case .failure(let error):
                print(error)
            }
        }
        

        
    }
}
