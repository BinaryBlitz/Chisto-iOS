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
  var icon: UIImage? { get }
}


class SelectClothesTableViewCellModel: SelectClothesTableViewCellModelType {
  // Input
  var navigationAddButtonDidTap = PublishSubject<Void>()
  var emptyOrderAddButtonDidTap = PublishSubject<Void>()
  
  // Output
  var titleText: String
  var subTitletext: NSAttributedString
  var icon: UIImage?

  init(clothesItem: ClothesItem) {
    self.titleText = clothesItem.name
    
    let subTitleAttrString = NSMutableAttributedString()
    
    for (index, relatedItem) in clothesItem.relatedItems.enumerated() {
      subTitleAttrString.append(NSAttributedString(string: relatedItem, attributes: [NSForegroundColorAttributeName: UIColor.chsSlateGrey]))
      if index != clothesItem.relatedItems.count - 1 {
        subTitleAttrString.append(NSAttributedString(string: " • ", attributes: [NSForegroundColorAttributeName: UIColor.chsSilver]))
      }
    }
    
    self.subTitletext = (subTitleAttrString)
    
    self.icon = clothesItem.icon
  }
  
}
