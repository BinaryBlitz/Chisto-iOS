//
//  CategoryTableViewCell.swift
//  Chisto
//
//  Created by Алексей on 13.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import RxSwift
import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryIconImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configure(viewModel: CategoryTableViewModelType) {
        categoryIconImageView.image = viewModel.icon
        titleLabel.text = viewModel.titleText
        descriptionLabel.attributedText = viewModel.subTitletext
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
