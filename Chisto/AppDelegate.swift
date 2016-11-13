//
//  AppDelegate.swift
//  Chisto
//
//  Created by Алексей on 10.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import RealmSwift

let uiRealm = try! Realm()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  let googlePlacesApiKey = "AIzaSyCq77FZeOGLaYpUpuhHbD0_x_3PFlkURFo"
  let googleMapsApiKey = "AIzaSyAL0CZs1iU-NhOfNhKxaLhuCL2Dud1b1Ak"
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions
    launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    Fabric.with([Crashlytics.self])
    UIApplication.shared.statusBarStyle = .lightContent
    
    GMSServices.provideAPIKey(googleMapsApiKey)
    GMSPlacesClient.provideAPIKey(googlePlacesApiKey)
    IQKeyboardManager.sharedManager().enable = true
    return true
    
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
  }
  
  
}
