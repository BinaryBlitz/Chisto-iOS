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

protocol ItemTableViewCellModelType {
  // Output
  var titleText: String { get }
  var subTitletext: NSAttributedString { get }
  var priceText: String { get }
  var iconUrl: URL? { get }
  var iconColor: UIColor { get }
}

class ItemTableViewCellModel: ItemTableViewCellModelType {
  // Constants
  let dayEndings = ["вещь", "вещи", "вещей"]
  let titleText: String
  var priceText: String
  let subTitletext: NSAttributedString
  let iconUrl: URL?
  let iconColor: UIColor

  init(item: Item) {
    self.titleText = item.name
    self.iconUrl = URL(string: item.iconUrl)
    self.iconColor = item.category?.color ?? UIColor.chsSkyBlue
    self.priceText = ""
    
    self.subTitletext = NSAttributedString(string: item.descriptionText, attributes: [NSForegroundColorAttributeName: UIColor.chsSlateGrey])
  }

}
