//
//  EmptyOrderView.swift
//  Chisto
//
//  Created by Алексей on 13.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import EasyPeasy

class EmptyOrderView: UIView {
    // CONSTANTS
    let titleText = "С какой вещью вам требуется помощь?"
    let buttonText = "Добавить"
    
    let titleLabel = UILabel()
    let addButton = UIButton()
    let contentView = UIView()

    init() {
        super.init(frame: CGRect.null)
        self.backgroundColor = UIColor.chsWhite
                
        self.addSubview(contentView)
        contentView <- [
            CenterY(),
            Left(),
            Right(),
        ]
        
        titleLabel.text = titleText
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        titleLabel.textColor = UIColor.chsSlateGrey
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 3
        
        contentView.addSubview(titleLabel)
        titleLabel <- [
            Top().to(contentView, .top),
            Left(60).to(contentView, .left),
            Right(60).to(contentView, .right)
        ]
        
        addButton.setBackgroundImage(#imageLiteral(resourceName: "buttonBg"), for: .normal)
        addButton.setTitle(buttonText, for: .normal)
        
        contentView.addSubview(addButton)
        
        addButton <- [
            Top(20).to(titleLabel),
            CenterX(),
            Bottom().to(contentView, .bottom)
        ]
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
