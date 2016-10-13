//
//  DescriptionListItem.swift
//  Chisto
//
//  Created by Алексей on 11.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import EasyPeasy

class DescriptionListItemView: UIView {
    
    private let counterLabel = UIImageView()
    private let informationLabel = UILabel()

    init(countImage: UIImage, information: String) {
        super.init(frame: CGRect.null)
        counterLabel.image = countImage
        counterLabel.contentMode = .scaleAspectFit
        
        self.addSubview(counterLabel)
        
        counterLabel <- [
            Top(),
            Bottom(),
            Left(),
            Width(29),
            Height(29)
        ]
        
        informationLabel.text = information
        informationLabel.textColor = UIColor.chsSlateGrey
        informationLabel.font = UIFont.preferredFont(forTextStyle: )
        informationLabel.numberOfLines = 2
        
        self.addSubview(informationLabel)
        informationLabel <- [
            Top().to(counterLabel, .top),
            Right(),
            Left(20).to(counterLabel)
        ]
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
