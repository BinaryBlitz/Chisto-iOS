//
//  DescriptionListItem.swift
//  Chisto
//
//  Created by Алексей on 11.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit

class DescriptionListItemView: UIView {

  @IBOutlet weak var countImageView: UIImageView!

  @IBOutlet weak var descriptionLabel: UILabel!

  func configure(countImage: UIImage, information: String) {
    countImageView.image = countImage
    descriptionLabel.text = information
    descriptionLabel.sizeToFit()
  }

}
