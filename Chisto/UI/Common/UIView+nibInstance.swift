//
//  UIView+nibInstance.swift
//  Chisto
//
//  Created by Алексей on 20.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  private class func getNibInstance<T:UIView>() -> T? {
    return UINib(nibName: String(describing: self), bundle: nil).instantiate(withOwner: nil, options: nil).first as? T

  }

  class func nibInstance() -> Self? {
    return getNibInstance()
  }
}
