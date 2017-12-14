//
//  CatalogueItemCell.swift
//  Catalogue
//
//  Created by Sorin Lumezeanu on 09/12/2017.
//  Copyright © 2017 Sorin Lumezeanu. All rights reserved.
//

import UIKit

class CatalogueItemCell: UITableViewCell {
    
    static let reuseIdentifier = "CatalogueItemCellReuseIdentifier"
    static let nib = UINib(nibName: "CatalogueItemCell", bundle: nil)
        
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var itemIdentifierLabel: UILabel!
    @IBOutlet weak var itemConfidenceLabel: UILabel!
    
    private var viewModel: CatalogueItemCellViewModel!
    
    func configure(with viewModel: CatalogueItemCellViewModel) {
        self.viewModel = viewModel
        
        self.itemDescriptionLabel.text = self.viewModel.itemDescription
        self.itemIdentifierLabel.text = self.viewModel.itemIdentifier
        self.itemConfidenceLabel.text = self.viewModel.itemConfidence

        if let itemImage = self.viewModel.itemImage {
            self.updateItemImage(with: itemImage)
        } else {
            self.showActivityIndicator()

            self.viewModel.delegate = self
            self.viewModel.startLoadingItemImage()
        }
    }
    
    override func prepareForReuse() {
        self.viewModel = nil
        
        self.itemIdentifierLabel.text = nil
        self.itemDescriptionLabel.text = nil
        self.itemConfidenceLabel.text = nil
        self.itemImageView.isHidden = true
        
        self.hideActivityIndicator()
    }
    
    fileprivate func updateItemImage(with itemImage: UIImage?) {
        self.itemImageView.image = itemImage
        self.itemImageView.isHidden = false
    }
    
    fileprivate func showActivityIndicator() {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
    }
    
    fileprivate func hideActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
}

extension CatalogueItemCell: CatalogueItemCellViewModelDelegate {
    
    func didReceiveItemImage(_ itemImage: UIImage?) {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
            self.updateItemImage(with: itemImage)
        }
    }
}
