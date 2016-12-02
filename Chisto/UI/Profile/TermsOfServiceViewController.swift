//
//  TermsOfServiceViewController.swift
//  Chisto
//
//  Created by Алексей on 01.12.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class TermsOfServiceViewController: UIViewController, WKNavigationDelegate {
  let webView = WKWebView()
  let termsOfServiceURL = URL(string: "https://chis.to/legal/terms-of-service.pdf")!
  
  override func viewDidLoad() {
    navigationItem.title = "Пользовательское соглашение"
    self.view = webView
    webView.navigationDelegate = self
    webView.load(URLRequest(url: termsOfServiceURL))
  }
  
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
}
