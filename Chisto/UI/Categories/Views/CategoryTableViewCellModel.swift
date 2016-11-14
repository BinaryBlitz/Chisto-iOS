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
  var iconUrl: URL? { get }
  
}


class CategoryTableViewCellModel: CategoryTableViewCellModelType {
  // Constants
  let dayEndings = ["вещь", "вещи", "вещей"]
  let titleText: String
  let subTitletext: NSAttributedString
  let iconUrl: URL?
  
  init(category: Category) {
    self.titleText = category.name
    // self.iconUrl = URL(string: category.icon)
    self.iconUrl = URL(string: "https://www.fillmurray.com/30/30")
    /*
    let subTitleAttrString = NSMutableAttributedString()
    
    
    for (index, subCategory) in category..enumerated() {
      if index < 3 {
        subTitleAttrString.append(NSAttributedString(string: subCategory.stringValue, attributes: [NSForegroundColorAttributeName: UIColor.chsSlateGrey]))
        if index != 2 {
          subTitleAttrString.append(NSAttributedString(string: " • ", attributes: [NSForegroundColorAttributeName: UIColor.chsSilver]))
        }
      }
      
    }
    
    let leftCount = category.subCategories.count - 3
    if leftCount > 0 {
      subTitleAttrString.append(NSAttributedString(string: " и еще \(leftCount) " + getRussianNumEnding(number: leftCount, endings: dayEndings), attributes: [NSForegroundColorAttributeName: UIColor.chsSilver]))
      
    }
     */
    
    // self.subTitletext = (subTitleAttrString)
    self.subTitletext = NSAttributedString(string: category.descriptionText, attributes: [NSForegroundColorAttributeName: UIColor.chsSlateGrey])
    
  }
  
}
