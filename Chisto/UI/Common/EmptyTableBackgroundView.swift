//
//  EmptyTableBackgroundView.swift
//  Chisto
//
//  Created by Алексей on 25.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

class EmptyTableBackgroundView: UIView {
  @IBOutlet weak var titleLabel: UILabel!
  
  var title: String? {
    get {
      return titleLabel.text
    }
    set {
      titleLabel.text = newValue
    }
  }
}
