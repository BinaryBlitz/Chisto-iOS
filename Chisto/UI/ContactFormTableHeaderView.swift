//
//  ContactDataTableHeaderView.swift
//  Chisto
//
//  Created by Алексей on 08.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

class ContactFormTableHeaderView: UIView {
  @IBOutlet weak var iconView: UIImageView!
  @IBOutlet weak var headerLabel: UILabel!
  
  func configure(viewModel: ContactFormTableHeaderViewModel) {
    iconView.image = viewModel.icon
    headerLabel.text = viewModel.title
  }
  
}
