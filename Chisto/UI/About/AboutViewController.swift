//
//  AboutViewController.swift
//  Chisto
//
//  Created by Алексей on 28.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController: UIViewController {
  
  struct URLs {
    static let supportEmail = "info@chis.to"
    static let instagram = "https://www.instagram.com/chistoapp/"
    static let facebook = "https://www.facebook.com/chistoapp"
    static let vk = "https://vk.com/chistoapp"
    static let partnershipEmail = "partner@chis.to"
    static let review = "https://itunes.apple.com/us/app/chisto/id1165430647?ls=1&mt=8"
    static let phoneNumber = "+7 495 766-78-49"
  }
  
  @IBAction func instagramButtonDidTap(_ sender: Any) {
    openURL(URLs.instagram)
  }
  
  @IBAction func facebookButtonDidTap(_ sender: Any) {
    openURL(URLs.facebook)
  }
  
  @IBAction func vkButtonDidTap(_ sender: Any) {
    openURL(URLs.vk)
  }
  
  @IBAction func reviewButtonDidTap(_ sender: Any) {
    openURL(URLs.review)
  }
  
  @IBAction func parntershipViewDidTap(_ sender: Any) {
    openURL("mailto:\(URLs.partnershipEmail)")
  }
  
  @IBAction func callUsViewDidTap(_ sender: Any) {
    let alertController = UIAlertController(title: nil, message: URLs.phoneNumber, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
    let callAction = UIAlertAction(title: "call".localized, style: .default, handler: { [weak self] _ in
      self?.openURL("tel://+\(URLs.phoneNumber.onlyDigits)")
    })
    alertController.addAction(cancelAction)
    alertController.addAction(callAction)
    present(alertController, animated: true, completion: nil)
  }

  @IBAction func mailViewDidTap(_ sender: Any) {
    openURL("mailto:\(URLs.supportEmail)")
  }
  
  func openURL(_ string: String) {
    guard let url = URL(string: string) else { return }
    UIApplication.shared.openURL(url)
  }
}
