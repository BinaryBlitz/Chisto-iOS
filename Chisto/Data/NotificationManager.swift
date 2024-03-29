//
//  NotificationManager.swift
//  Chisto
//
//  Created by Алексей on 19.12.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import SwiftyJSON
import UserNotifications

/// Manages push notifications
class NotificationManager: NSObject {
  static let instance = NotificationManager()
  let disposeBag = DisposeBag()
  private override init() {
    super.init()
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
  }

  func resetNotificationsCount() {
    UIApplication.shared.applicationIconBadgeNumber = 0
  }

  func enable() {
    guard ProfileManager.instance.userProfile.value.deviceToken == nil else { return }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
          if granted { UIApplication.shared.registerForRemoteNotifications() }
        }
    } else {
      let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      UIApplication.shared.registerUserNotificationSettings(settings)
      UIApplication.shared.registerForRemoteNotifications()
    }
  }

  func didRegisterForNotifications(token: Data) {
    let tokenString = token.hexadecimalString
    DataManager.instance.sendNotificationToken(tokenString: tokenString).subscribe(onNext: {
        ProfileManager.instance.updateProfile { $0.deviceToken = tokenString }
      }).addDisposableTo(disposeBag)
  }

  func didReceiveNotification(userInfo: [AnyHashable: Any]) {
    print(JSON(userInfo).rawString(options: .prettyPrinted) ?? "")

    guard let notificationData = userInfo["custom_data"] as? [String: Any] else { return }
    guard let orderId = notificationData["order_id"] as? Int else { return }
    guard let visibleViewController = RootViewController.instance?.visibleViewController else { return }

    let profileViewController = ProfileViewController.storyboardInstance()!
    profileViewController.navigationItem.backBarButtonItem = UIBarButtonItem(
      title: "",
      style: .plain,
      target: nil,
      action: nil
    )

    let myOrdersViewController = MyOrdersViewController.storyboardInstance()!
    myOrdersViewController.navigationItem.backBarButtonItem = UIBarButtonItem(
      title: "",
      style: .plain,
      target: nil,
      action: nil
    )

    let orderViewController = OrderInfoViewController.storyboardInstance()!
    orderViewController.viewModel = OrderInfoViewModel(orderId: orderId)

    let navigationViewController = ChistoNavigationController()

    navigationViewController.viewControllers = [
      profileViewController,
      myOrdersViewController,
      orderViewController
    ]

    visibleViewController.present(navigationViewController, animated: true, completion: nil)
  }
}

@available(iOS 10.0, *)
extension NotificationManager: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    self.didReceiveNotification(userInfo: userInfo)

  }
}
