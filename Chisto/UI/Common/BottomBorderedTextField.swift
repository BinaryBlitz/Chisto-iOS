//
//  BottomBorderedTextField.swift
//  Chisto
//
//  Created by Алексей on 13.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import EasyPeasy

class BottomBorderedTextField: UITextField {

    init() {
        super.init(frame: CGRect.null)
        borderStyle = .none
        
        let border = UIView()
        border.backgroundColor = UIColor.chsSilver
        
        addSubview(border)
        
        border <- [
            Left(),
            Right(),
            Bottom(),
            Height(1)
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
