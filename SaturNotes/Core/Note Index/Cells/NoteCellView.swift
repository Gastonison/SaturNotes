//
//  NoteCellViewController.swift
//  SaturNotes
//
//  Created by Gaston Martin on 7/24/20.
//  Copyright © 2020 Gaston Martin. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class NoteCellView: UITableViewCell, ConfigurableCell {
    
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var noteTitleLabel: UILabel!
    @IBOutlet weak var noteLoadingView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    func configureCell(tableCellModel: CellViewModel)  {
        guard let model = tableCellModel as? NoteCellViewModel else { return }
        
        self.noteTitleLabel.text = model.title
        
        noteLoadingView.layer.cornerRadius = noteLoadingView.frame.height/2.0
        noteLoadingView.layer.masksToBounds = true
        
        noteImageView.image = nil
        activityIndicatorView.alpha = 0
        activityIndicatorView.stopAnimating()
        
        switch model.state {
        case .upToDate:
            noteLoadingView.backgroundColor = .green
        case .outOfDate:
            noteLoadingView.backgroundColor = .red
        case .updating:
            activityIndicatorView.alpha = 1
            activityIndicatorView.startAnimating()
            noteLoadingView.backgroundColor = .clear
        }
        
        if let imageURLString = model.imageURLString,
            let imageURL = URL(string: imageURLString) {
            self.noteImageView.sd_imageTransition = .fade
            switch model.state {
            case .upToDate:
                self.noteImageView.sd_setImage(
                    with: imageURL,
                    placeholderImage: nil,
                    context: [.imageThumbnailPixelSize : CGSize(width: 350, height: 350)])
            case .outOfDate:
                self.noteImageView.sd_setImage(with: imageURL, completed: nil)
            default:
                break
            }
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        noteImageView.sd_cancelCurrentImageLoad()
        noteImageView.image = nil
    }
    
}
