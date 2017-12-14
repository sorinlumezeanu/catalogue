//
//  CatalogueItem.swift
//  Catalogue
//
//  Created by Sorin Lumezeanu on 09/12/2017.
//  Copyright © 2017 Sorin Lumezeanu. All rights reserved.
//

import UIKit
import ObjectMapper

open class CatalogueItem: NSObject, NSCoding, Mappable {
    
    var identifier: String?
    var text: String?
    var confidence: Double?
    var base64EncodedImage: String?
    
    // required for subclassing in the Testing target
    override public init() {
        super.init()
    }
    
    public required init?(map: Map) {
    }
    
    public required init(coder aDecoder: NSCoder) {
        self.identifier = aDecoder.decodeObject(forKey: "identifier") as? String
        self.text = aDecoder.decodeObject(forKey: "text") as? String
        self.confidence = aDecoder.decodeObject(forKey: "confidence") as? Double
        
        // note: image bytes are not present in the object's archive (they are persisted in a dedicatd cache)
    }
    
    public func encode(with aCoder: NSCoder) {
        guard let identifier = self.identifier else { return }
        
        aCoder.encode(identifier, forKey: "identifier")
        aCoder.encode(self.text, forKey: "text")
        aCoder.encode(self.confidence, forKey: "confidence")
        
        // note: image bytes are not encoded (they are persisted in a dedicatd cache)
    }
    
    public func mapping(map: Map) {
        self.identifier <- map["_id"]
        self.text <- map["text"]
        self.confidence <- map["confidence"]
        
        self.base64EncodedImage <- map["img"]
    }
    
    func image() -> UIImage? {
        guard let base64EncodedImage = self.base64EncodedImage else { return nil }
        guard let imageData = Data(base64Encoded: base64EncodedImage) else { return nil }
        
        return UIImage(data: imageData)
    }
}


