//
//  CatalogueViewController.swift
//  Catalogue
//
//  Created by Sorin Lumezeanu on 09/12/2017.
//  Copyright © 2017 Sorin Lumezeanu. All rights reserved.
//

import UIKit

class CatalogueViewController: UIViewController {

    var viewModel: CatalogueViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching newer items...")
        refreshControl.addTarget(self, action: #selector(self.refreshControlValueChanged(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = CatalogueViewModel(withDelegate: self)
        
        self.tableView.register(CatalogueItemCell.nib, forCellReuseIdentifier: CatalogueItemCell.reuseIdentifier)
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = self.refreshControl
        } else {
            self.tableView.addSubview(self.refreshControl)
        }        
        self.tableView.tableFooterView = UIView()
        
        self.viewModel.startLoadingItems()
    }
    
    func refreshControlValueChanged(_ refreshControl: UIRefreshControl) {
        self.viewModel.refreshItems()
    }
}

extension CatalogueViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfCatalogueItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let catalogueItem = self.viewModel.catalogueItem(for: indexPath) else { return UITableViewCell() }
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: CatalogueItemCell.reuseIdentifier) as! CatalogueItemCell
        cell.configure(with: CatalogueItemCellViewModel(with: catalogueItem))
        return cell
    }
}

extension CatalogueViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        
        if indexPath.row == self.viewModel.numberOfCatalogueItems() - 1 {
            self.viewModel.loadMoreOldItems()
        }
    }
}

extension CatalogueViewController: CatalogueViewModelDelegate {
    
    func didReceiveCatalogueItems(_ items: [CatalogueItem]) {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            if items.isEmpty == false {
                self.tableView.reloadData()
            }
        }
    }
    
    func didReceiveError(_ error: Error) {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            
            var errorTitle: String?
            var errorMessage: String?
            
            if let urlError = error as? URLError {
                if urlError.code == URLError.Code.cancelled {
                    // indicates either that the Alamofire SessionManager has gone out of scope (which is not the case here, we use a singletone for that)
                    // or, more likely, that the SSL Pinning verification has failed
                    errorTitle = "SSL Pinning Error"
                    errorMessage = "SSL Pinning validation failed"
                } else {
                    errorTitle = "There was a problem with your request"
                    errorMessage = "Code: \(urlError.code) Description: \(urlError.localizedDescription)"
                }
            } else {
                errorTitle = "Unknown Error"
                errorMessage = "\(error.localizedDescription)"
            }
            
            let alertViewController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alertViewController, animated: true, completion: nil)

        }
    }
}

