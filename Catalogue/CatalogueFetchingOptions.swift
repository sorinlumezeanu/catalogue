//
//  CatalogueFetchingOptions.swift
//  Catalogue
//
//  Created by Sorin Lumezeanu on 10/12/2017.
//  Copyright © 2017 Sorin Lumezeanu. All rights reserved.
//

import Foundation

public enum CatalogueFetchingOptions {
    case newerThan(itemIdentifier: String)
    case olderThan(itemIdentifier: String)
}
