//
//  NoteIndexViewModel.swift
//  SaturNotes
//
//  Created by Gaston Martin on 7/24/20.
//  Copyright © 2020 Gaston Martin. All rights reserved.
//

import Foundation
import RealmSwift
import Reachability

protocol NoteIndexViewModelDelegate: class {
    
    func reloadViews()
    func openEditor(_ callback: ((Result<Note, Error>) -> Void)?)
}

class NoteIndexViewModel {
    
    weak var delegate: NoteIndexViewModelDelegate?
    
    var cells: [CellViewModel] = []
    var token: NotificationToken?
    let reachability = try! Reachability()
    
    init(delegate: NoteIndexViewModelDelegate) {
        self.delegate = delegate
        setupReachability()
        setupCellObserver()
        refreshData()
    }
    
    func setupReachability() {
        reachability.whenReachable = { [weak self] reachability in
            guard let strongSelf = self else { return }
            strongSelf.updateNotes()
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
    }
    
    func setupCellObserver() {
        let realm = try! Realm()
        let notes = realm.objects(Note.self)
        
        token = notes.observe { [weak self] changes in
            guard let strongSelf = self else { return }
            switch changes {
            case .initial(let notes), .update(let notes, _,_,_):
                strongSelf.cells = notes
                    .sorted(by: {
                        (Int($0.id) ?? Int.max) > (Int($1.id) ?? Int.max)
                    })
                    .map({
                        NoteCellViewModel(note: $0)
                    })
                strongSelf.delegate?.reloadViews()
            case .error(_):
                break
            }
        }
    }
    
    
    func addTapped() {
        delegate?.openEditor({[weak self] response in
            guard let strongSelf = self else { return }
            switch response {
            case .success(let note):
                strongSelf.noteAdded(note)
            case .failure:
                break
            }
        })
    }
    
    func noteAdded(_ note: Note) {
        self.cells.insert(NoteCellViewModel(note: note), at: 0)
        updateNote(index: 0)
        delegate?.reloadViews()
    }
    
    //MARK:  Web Requests
    // with more time would've built more abstraction around the realm usage below
    
    func updateNotes() {
        let realm = try! Realm()
        let oldNotes = Array(realm.objects(Note.self).filter("stateString = \"\(Note.NoteState.outOfDate)\""))
        oldNotes.forEach({ note in
            self.uploadNote(note)
        })
    }
    
    func updateNote(index: Int) {
        guard let cellModel = cells[index] as? NoteCellViewModel,
            cellModel.state == .outOfDate else { return }
        
        let realm = try! Realm()
        if let note = realm.object(
            ofType: Note.self,
            forPrimaryKey: cellModel.id) {
            uploadNote(note)
        }
        
    }
    
    func uploadNote(_ note: Note) {
        let realm = try! Realm()
        let noteRef = ThreadSafeReference(to: note)
        
        try? realm.write {
            if !note.isInvalidated {
                note.state = .updating
            }
        }
        
        guard let imageData = UIImage
            .loadImage(note.noteImage?.localResourceURL ?? "")?
            .jpegData(compressionQuality: 0.1),
            note.noteImage?.id == nil else {
                createNote(note: note, imageId: note.noteImage?.id ?? "")
                return
        }
        
        SaturnNoteWebService.uploadImage(
            imageData: imageData,
            success: { [weak self] json in
                let realm = try! Realm()
                guard let strongSelf = self,
                    let imageId = json["id"] as? String,
                    let note = realm.resolve(noteRef) else { return }
                
                try? realm.write {
                    if !note.isInvalidated {
                        note.noteImage?.id = imageId
                    }
                }
                
                strongSelf.createNote(note: note, imageId: imageId)
                
            }, fail: { error in
                let realm = try! Realm()
                guard let note = realm.resolve(noteRef) else { return }
                try? realm.write {
                    if !note.isInvalidated {
                        note.state = .outOfDate
                    }
                }
        })
    }
    
    
    func createNote(note: Note, imageId: String) {
        let localResourceURL = note.noteImage?.localResourceURL
        let noteRef = ThreadSafeReference(to: note)
        
        SaturnNoteWebService
            .createNote(
                title: note.title ?? "",
                imageId: imageId,
                success: { json in
                    let realm = try! Realm()
                    guard let note = realm.resolve(noteRef) else { return }
                    try? realm.write {
                        guard let oldNote = realm.object(
                            ofType: Note.self,
                            forPrimaryKey: note.id) else { return }
                        
                        realm.delete(oldNote)
                        realm.add(
                            Note(json: json,
                                 state: .upToDate,
                                 localResourceURL: localResourceURL),
                            update: .all)
                        
                    }
                    
            },
                fail: { error in
                    let realm = try! Realm()
                    guard let note = realm.resolve(noteRef) else { return }
                    try? realm.write {
                        if !note.isInvalidated {
                            note.state = .outOfDate
                        }
                    }
            })
    }
    
    
    func refreshData() {
        updateNotes()
        
        SaturnNoteWebService.getNotes(success: { [weak self] jsonArray in
            guard self != nil else { return }
            let notes = jsonArray.compactMap({
                Note(json: $0, state: .upToDate)
            })
            
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(notes, update:.modified)
                }
            }
            catch {
                print("error writing to realm")
            }
            
        })
    }
    
}

