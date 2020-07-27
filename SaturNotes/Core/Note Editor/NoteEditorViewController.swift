//
//  NoteEditorViewController.swift
//  SaturNotes
//
//  Created by Gaston Martin on 7/24/20.
//  Copyright © 2020 Gaston Martin. All rights reserved.
//

import Foundation
import UIKit

class NoteEditorViewController: UIViewController, NoteEditorViewModelDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var viewModel: NoteEditorViewModel?
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    //Would normally have some factory abstraction
    static func instantiate(callback: ((Result<Note, Error>) -> Void)?) -> NoteEditorViewController {
        let vc =
            UIStoryboard(
                name: "Main",
                bundle: Bundle.main)
                .instantiateViewController(
                    withIdentifier: "noteEditor") as! NoteEditorViewController
        
        vc.viewModel =
            NoteEditorViewModel(
                delegate: vc,
                callback: callback)
        
        return vc
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        guard let image = imageView.image else { return }
        viewModel?.doneTapped(title: textField.text, image: image)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chooseImageTapped(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else { return }
        self.imageView.image = image
    }
    
}

