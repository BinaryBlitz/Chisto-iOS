//
//  LaundryReviewsTableViewCell.swift
//  Chisto
//
//  Created by Алексей on 18.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import FloatRatingView

class LaundryReviewsTableViewCell: UITableViewCell {
  @IBOutlet weak var authorNameLabel: UILabel!
  @IBOutlet weak var reviewContentLabel: UILabel!
  @IBOutlet weak var reviewRatingView: FloatRatingView!
  @IBOutlet weak var reviewDateLabel: UILabel!

  func configure(viewModel: LaundryReviewsViewTableViewCellModelType) {
    authorNameLabel.text = viewModel.authorName
    reviewContentLabel.text = viewModel.content
    reviewRatingView.rating = viewModel.rating
    reviewDateLabel.text = viewModel.date
  }
}
