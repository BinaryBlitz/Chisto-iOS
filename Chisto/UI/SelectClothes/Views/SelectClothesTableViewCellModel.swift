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
  var iconColor: UIColor { get }
  var slowItemButtonDidTap: PublishSubject<Void> { get }
  var disposeBag: DisposeBag { get }
  var longTreatment: Bool { get }
}

class SelectClothesTableViewCellModel: SelectClothesTableViewCellModelType {
  var disposeBag = DisposeBag()

  // Input
  var slowItemButtonDidTap = PublishSubject<Void>()

  // Output
  var titleText: String
  var subTitletext: NSAttributedString
  var iconUrl: URL?
  var iconColor: UIColor
  var longTreatment: Bool

  init(item: Item) {
    self.titleText = item.name
    self.subTitletext = NSAttributedString(string: item.descriptionText)

    self.iconUrl = URL(string: item.iconUrl)
    self.iconColor = item.category?.color ?? UIColor.chsSkyBlue
    self.longTreatment = item.longTreatment
  }

}
