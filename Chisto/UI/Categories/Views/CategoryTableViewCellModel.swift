//
//  CategoryTableViewCellModel.swift
//  Chisto
//
//  Created by Алексей on 14.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol CategoryTableViewCellModelType {
  // Output
  var titleText: String { get }
  var subTitletext: NSAttributedString { get }
  var icon: UIImage? { get }
  
}


class CategoryTableViewCellModel: CategoryTableViewCellModelType {
  // Constants
  let dayEndings = ["вещь", "вещи", "вещей"]
  let titleText: String
  let subTitletext: NSAttributedString
  let icon: UIImage?
  
  init(category: Category) {
    self.titleText = category.name

    let subTitleAttrString = NSMutableAttributedString()
    
    for (index, subCategory) in category.subCategories.enumerated() {
      if index < 3 {
        subTitleAttrString.append(NSAttributedString(string: subCategory, attributes: [NSForegroundColorAttributeName: UIColor.chsSlateGrey]))
        if index != 2 {
          subTitleAttrString.append(NSAttributedString(string: " • ", attributes: [NSForegroundColorAttributeName: UIColor.chsSilver]))
        }
      }
      
    }
    
    let leftCount = category.subCategories.count - 3
    if leftCount > 0 {
      subTitleAttrString.append(NSAttributedString(string: " и еще \(leftCount) " + getRussianNumEnding(number: leftCount, endings: dayEndings), attributes: [NSForegroundColorAttributeName: UIColor.chsSilver]))
      
    }
    
    self.subTitletext = (subTitleAttrString)
    
    self.icon = category.icon
  }
  
}
