//
//  CategoryCollectionViewCell.swift
//  Chisto
//
//  Created by Алексей on 28.04.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var iconView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!

  private var type: CategoryCollectionViewCellModelType = .allCategories {
    didSet {
      switch type {
      case .allCategories:
        iconView.image = #imageLiteral(resourceName: "iconAllcategoryAction").withRenderingMode(.alwaysTemplate)
        nameLabel.highlightedTextColor = UIColor.chsSkyBlue
        nameLabel.text = NSLocalizedString("All", comment: "All categories")
      case .category(let category):
        nameLabel.highlightedTextColor = category.color
        iconView.kf.setImage(with: URL(string:category.iconUrl)) { [weak self] image, _, _, _ in
          guard let `self` = self, let image = image?.withRenderingMode(.alwaysTemplate) else { return }
          self.iconView.image = image
        }
        nameLabel.text = category.name
      }
    }
  }

  func configure(viewModel: CategoryCollectionViewCellModel) {
    self.type = viewModel.type
    self.isSelected = viewModel.isSelected

  }

  override var isHighlighted: Bool {
    didSet {
      configureTintColor()
    }
  }

  override var isSelected: Bool {
    didSet {
      configureTintColor()
    }
  }

  func configureTintColor() {
    switch type {
    case .allCategories:
      iconView.tintColor = (isHighlighted || isSelected) ? UIColor.chsSkyBlue : UIColor.chsCoolGrey
    case .category(let category):
      iconView.tintColor = (isHighlighted || isSelected) ? category.color : UIColor.chsCoolGrey
    }
  }

}
