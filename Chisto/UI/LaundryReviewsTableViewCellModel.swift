//
//  LaundryReviewsTableViewCellModel.swift
//  Chisto
//
//  Created by Алексей on 18.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation

protocol LaundryReviewsViewTableViewCellModelType {
  var rating: Float { get }
  var authorName: String { get }
  var content: String { get }
  var date: String { get }
}

class LaundryReviewsViewTableViewCellModel: LaundryReviewsViewTableViewCellModelType {
  let rating: Float
  let authorName: String
  let content: String
  var date: String
  
  init(rating: Rating) {
    self.rating = Float(rating.value)
    self.authorName = rating.author
    self.content = rating.content
    self.date = rating.createdAtDate.shortDate
  }
}
