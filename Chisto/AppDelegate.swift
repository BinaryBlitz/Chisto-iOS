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

    // Status bar style
    UIApplication.shared.statusBarStyle = .lightContent

    // Fabric
    Fabric.with([Crashlytics.self])

    // Google Maps & Google Places
    GMSServices.provideAPIKey(googleMapsApiKey)
    GMSPlacesClient.provideAPIKey(googlePlacesApiKey)
    
    // IQKeyboardManager
    IQKeyboardManager.sharedManager().enable = true

    // NotificationManager
    NotificationManager.instance.resetNotificationsCount()
    if let remoteNotification = launchOptions?[.remoteNotification] as? [AnyHashable : Any] {
      NotificationManager.instance.didReceiveNotification(userInfo: remoteNotification)
    }

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

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    NotificationManager.instance.didReceiveNotification(userInfo: userInfo)
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    NotificationManager.instance.didRegisterForNotifications(token: deviceToken)
  }

}
