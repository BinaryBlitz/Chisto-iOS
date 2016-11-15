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
    self.iconUrl = URL(string: category.icon)

    self.subTitletext = NSAttributedString(string: category.descriptionText, attributes: [NSForegroundColorAttributeName: UIColor.chsSlateGrey])
  }

}
