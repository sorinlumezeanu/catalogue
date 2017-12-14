//
//  CatalogueViewModel.swift
//  Catalogue
//
//  Created by Sorin Lumezeanu on 09/12/2017.
//  Copyright © 2017 Sorin Lumezeanu. All rights reserved.
//

import Foundation

protocol CatalogueViewModelDelegate: AnyObject {
    func didReceiveCatalogueItems(_ items: [CatalogueItem])
    func didReceiveError(_ error: Error)
}

public class CatalogueViewModel {
    
    weak var delegate: CatalogueViewModelDelegate?      // access requied by the test target
    
    var catalogueItems: [CatalogueItem] = []            // access requied by the test target
    private var moreOldItemsAvailable = true
    
    init(withDelegate delegate: CatalogueViewModelDelegate?) {
        self.delegate = delegate
    }
    
    func numberOfCatalogueItems() -> Int {
        return self.catalogueItems.count
    }
    
    func catalogueItem(for indexPath: IndexPath) -> CatalogueItem? {
        guard indexPath.section == 0 else { return nil }
        guard indexPath.row >= 0 && indexPath.row < self.catalogueItems.count else { return nil }
        
        return self.catalogueItems[indexPath.row]
    }
    
    func startLoadingItems() {
        self.loadMoreOldItems()
    }
    
    func loadMoreOldItems() {
        guard self.moreOldItemsAvailable else { return }     // no use poking for old items anymore, we've received all of them already
        
        var fetchingOptions: CatalogueFetchingOptions?
        if let oldestItemIdentifier = self.catalogueItems.last?.identifier {
            fetchingOptions = .olderThan(itemIdentifier: oldestItemIdentifier)
        }

        let catalogueService: CatalogueServiceProtocol = ServiceProvider.resolve()
        catalogueService.fetchCatalogueItems(fetchingOptions: fetchingOptions, useCache: true) { [weak self] (oldItems, error) in
            if let error = error {
                self?.delegate?.didReceiveError(error)
            } else {
                if let oldItems = oldItems {
                    if oldItems.isEmpty {
                        self?.moreOldItemsAvailable = false
                    } else {
                        self?.catalogueItems.append(contentsOf: oldItems)
                        self?.delegate?.didReceiveCatalogueItems(oldItems)
                    }
                }
            }
        }
    }
    
    func refreshItems() {
        var fetchingOptions: CatalogueFetchingOptions?
        if let mostRecentItemIdentifier = self.catalogueItems.first?.identifier {
            fetchingOptions = .newerThan(itemIdentifier: mostRecentItemIdentifier)
        }
        
        let catalogueService: CatalogueServiceProtocol = ServiceProvider.resolve()
        catalogueService.fetchCatalogueItems(fetchingOptions: fetchingOptions, useCache: false) { [weak self] (newItems, error) in
            if let error = error {
                self?.delegate?.didReceiveError(error)
            } else {
                if let newItems = newItems {
                    self?.catalogueItems.insert(contentsOf: newItems, at: 0)
                    self?.delegate?.didReceiveCatalogueItems(newItems)
                }
            }
        }
    }
}
