//
//  RootViewController.swift
//  Chisto
//
//  Created by Алексей on 13.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//


import UIKit
import EasyPeasy

class RootViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    private(set) static var instance: RootViewController!
    
    let rootNavigationController = UINavigationController()
    
    override func loadView() {
        RootViewController.instance = self
        
        view = UIView()
        view.backgroundColor = UIColor.chsCoolGrey
        
        addChildViewController(rootNavigationController)
        view.addSubview(rootNavigationController.view)
        rootNavigationController.view <- Edges()
        rootNavigationController.didMove(toParentViewController: self)
        
        rootNavigationController.navigationBar.barTintColor = UIColor.chsSkyBlue
        rootNavigationController.navigationBar.barStyle = .black
        rootNavigationController.navigationBar.tintColor = .white
        rootNavigationController.navigationBar.isTranslucent = false
        
        rootNavigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        rootNavigationController.navigationBar.shadowImage = UIImage()
        rootNavigationController.navigationBar.backgroundColor = UIColor.chsSkyBlue
        
        rootNavigationController.delegate = self
        rootNavigationController.interactivePopGestureRecognizer?.delegate = self
        
        rootNavigationController.viewControllers = [OnBoardingViewController()]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
