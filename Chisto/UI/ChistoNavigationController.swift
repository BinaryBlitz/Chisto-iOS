//
//  RootViewController.swift
//  Chisto
//
//  Created by Алексей on 13.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//


import UIKit

class ChistoNavigationController: UINavigationController {
    
  override func loadView() {
    super.loadView()
    
    navigationBar.isTranslucent = false
    view.backgroundColor = UIColor.chsCoolGrey
    navigationBar.barStyle = .black
    navigationBar.tintColor = .white
    navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationBar.shadowImage = UIImage()
    navigationBar.backgroundColor = UIColor.chsSkyBlue
    navigationBar.barTintColor = UIColor.chsSkyBlue
    
  }
  
}
