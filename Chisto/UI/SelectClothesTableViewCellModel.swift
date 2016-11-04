//
//  SelectClothesTableViewCellModel.swift
//  Chisto
//
//  Created by Алексей on 18.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol SelectClothesTableViewCellModelType {
  // Output
  var titleText: String { get }
  var subTitletext: NSAttributedString { get }
  var iconUrl: URL? { get }
}


class SelectClothesTableViewCellModel: SelectClothesTableViewCellModelType {
  // Input
  var navigationAddButtonDidTap = PublishSubject<Void>()
  var emptyOrderAddButtonDidTap = PublishSubject<Void>()
  
  // Output
  var titleText: String
  var subTitletext: NSAttributedString
  var iconUrl: URL?

  init(item: Item) {
    self.titleText = item.name
    
    let subTitleAttrString = NSMutableAttributedString()
    
    for (index, relatedItem) in item.relatedItems.enumerated() {
      subTitleAttrString.append(NSAttributedString(string: relatedItem.stringValue, attributes: [NSForegroundColorAttributeName: UIColor.chsSlateGrey]))
      if index != item.relatedItems.count - 1 {
        subTitleAttrString.append(NSAttributedString(string: " • ", attributes: [NSForegroundColorAttributeName: UIColor.chsSilver]))
      }
    }
    
    //self.subTitletext = (subTitleAttrString)
    self.subTitletext = NSAttributedString(string: item.descriptionText)
    
    self.iconUrl = URL(string: item.icon)
  }
  
}
