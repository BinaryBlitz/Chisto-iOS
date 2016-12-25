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
  var iconColor: UIColor { get }
}


class CategoryTableViewCellModel: CategoryTableViewCellModelType {
  // Constants
  let dayEndings = ["вещь", "вещи", "вещей"]
  let titleText: String
  let subTitletext: NSAttributedString
  let iconUrl: URL?
  let iconColor: UIColor

  init(category: Category) {
    self.titleText = category.name
    self.iconUrl = URL(string: category.icon)
    self.iconColor = category.color


    guard category.descriptionText.characters.isEmpty else {
      self.subTitletext = NSAttributedString(string: category.descriptionText, attributes: [NSForegroundColorAttributeName: UIColor.chsSlateGrey])
      return
    }

    let subTitleAttrString = NSMutableAttributedString()

    var itemsLeftCount = 0

    for (index, itemPreview) in category.itemsPreview.enumerated() {
      if index < 3 {
        itemsLeftCount += 1
        subTitleAttrString.append(NSAttributedString(string: itemPreview.stringValue, attributes: [NSForegroundColorAttributeName: UIColor.chsSlateGrey]))
        if index != category.itemsPreview.count - 1 && index != 2 {
          subTitleAttrString.append(NSAttributedString(string: " • ", attributes: [NSForegroundColorAttributeName: UIColor.chsSilver]))
        }
      }

    }

    let leftCount = category.itemsCount - itemsLeftCount
    if leftCount > 0 {
      subTitleAttrString.append(NSAttributedString(string: " и еще \(leftCount) " + getRussianNumEnding(number: leftCount, endings: dayEndings), attributes: [NSForegroundColorAttributeName: UIColor.chsSilver]))
    }
    self.subTitletext = subTitleAttrString
  }

}
