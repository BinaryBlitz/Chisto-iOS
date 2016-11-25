//
//  BottomBorderedTextField.swift
//  Chisto
//
//  Created by Алексей on 13.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit

class BottomBorderedTextField: UITextField {

  init() {
    super.init(frame: CGRect.null)
    borderStyle = .none

    let border = UIView()

    addSubview(border)


  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
