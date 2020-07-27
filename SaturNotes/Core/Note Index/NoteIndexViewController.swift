//
//  ViewController.swift
//  SaturNotes
//
//  Created by Gaston Martin on 7/24/20.
//  Copyright © 2020 Gaston Martin. All rights reserved.
//

import Foundation
import UIKit

class NoteIndexViewController: UITableViewController, NoteIndexViewModelDelegate {
    
    var viewModel: NoteIndexViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = NoteIndexViewModel(delegate: self)
        tableView.reloadData()
        
        configureViews()
    }
    
    func configureViews() {
        let addButton =
            UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(addTapped))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    func reloadViews() {
        UIView.transition(with: tableView,
        duration: 0.35,
        options: .transitionCrossDissolve,
        animations: { self.tableView.reloadData() })
    }
    
    @IBAction func pulledToRefresh(_ sender: Any) {
        viewModel?.refreshData()
        self.refreshControl?.endRefreshing()
    }
    
    @objc func addTapped() {
        viewModel?.addTapped()
    }
    
    func openEditor(_ callback: ((Result<Note, Error>) -> Void)?) {
        self.navigationController?.present(
            NoteEditorViewController.instantiate(callback: {callback?($0)}),
            animated: true,
            completion: nil)
    }
    
    //MARK: Tableview Delegate / Data Source Methods
    
    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel?.cells[indexPath.row].height ?? 0
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else { return UITableViewCell() }
        
        let cellModel = viewModel.cells[indexPath.row]
        
        let cell = tableView
            .dequeueReusableCell(
                withIdentifier: cellModel.reuseId)
        
        (cell as? ConfigurableCell)?
            .configureCell(
                tableCellModel: cellModel)
        
        return cell ?? UITableViewCell()
    }
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        return viewModel?.cells.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.updateNote(index: indexPath.row)
    }
    
}

