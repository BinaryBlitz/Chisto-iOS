//
//  ServiceSelectTableViewCell.swift
//  Chisto
//
//  Created by Алексей on 19.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import RxSwift
import UIKit

class ServiceSelectTableViewCell: UITableViewCell {
  @IBOutlet weak var checkButton: UIButton!
  @IBOutlet weak var serviceTitleLabel: UILabel!
  @IBOutlet weak var serviceDescriptionLabel: UILabel!
  
  var selectedBackgroundColor = UIColor.chsSkyBlue
  var defaultBackgroundColor = UIColor.chsSilver50
  
  func configure(viewModel: ServiceSelectTableViewCellModelType) {
    selectedBackgroundColor = viewModel.color
    serviceTitleLabel.text = viewModel.serviceTitle
    serviceDescriptionLabel.text = viewModel.serviceDescription
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    checkButton.backgroundColor = selected ? selectedBackgroundColor : defaultBackgroundColor
  }
  
}
