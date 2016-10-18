//
//  RootViewController.swift
//  Chisto
//
//  Created by Алексей on 13.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//


import UIKit

protocol DefaultBarColoredViewController {}

class ChistoNavigationController: UINavigationController, UINavigationControllerDelegate {
  
  let defaultBarTintColor = UIColor.chsSkyBlue
  
  override func loadView() {
    super.loadView()    
    delegate = self
    
    navigationBar.isTranslucent = false
    view.backgroundColor = UIColor.chsCoolGrey
    navigationBar.barStyle = .black
    navigationBar.tintColor = .white
    navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationBar.shadowImage = UIImage()
    navigationBar.backgroundColor = UIColor.chsSkyBlue
    navigationBar.barTintColor = UIColor.chsSkyBlue
  }
  
  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    if viewController is DefaultBarColoredViewController {
      navigationBar.barTintColor = defaultBarTintColor
    }
  }
}
