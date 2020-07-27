//
//  TableItem.swift
//  SaturNotes
//
//  Created by Gaston Martin on 7/24/20.
//  Copyright © 2020 Gaston Martin. All rights reserved.
//

import Foundation
import UIKit

@objc protocol CellViewModel: class {

    @objc optional var nibName: String { get set }
    var reuseId: String { get set }
    var height: CGFloat { get }
    
}

extension CellViewModel {
    
    func register(for tableView: UITableView) {
        guard let nibName = self.nibName else { return }
        let nib = UINib(nibName: nibName, bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: reuseId)
    }
    
}
