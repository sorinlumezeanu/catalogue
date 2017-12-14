//
//  CatalogueItemCellViewModel.swift
//  Catalogue
//
//  Created by Sorin Lumezeanu on 09/12/2017.
//  Copyright © 2017 Sorin Lumezeanu. All rights reserved.
//

import UIKit

protocol CatalogueItemCellViewModelDelegate: AnyObject {
    func didReceiveItemImage(_ itemImage: UIImage?)
}

class CatalogueItemCellViewModel {
    
    let catalogueItem: CatalogueItem
    weak var delegate: CatalogueItemCellViewModelDelegate?
    
    init(with catalogueItem: CatalogueItem) {
        self.catalogueItem = catalogueItem
    }
    
    var itemIdentifier: String? {
        return self.catalogueItem.identifier
    }
    
    var itemDescription: String? {
        return self.catalogueItem.text
    }
    
    var itemConfidence: String? {
        guard let confidence = self.catalogueItem.confidence else { return nil }
        
        return String(format: "%.2f", confidence)
    }
    
    var itemImage: UIImage? {
        return self.catalogueItem.image()
    }
    
    func startLoadingItemImage() {
        let catalogueService: CatalogueServiceProtocol = ServiceProvider.resolve()
        catalogueService.fetchImage(forCatalogueItem: self.catalogueItem) { [weak self] (image) in
            self?.delegate?.didReceiveItemImage(image)
        }
    }
}
