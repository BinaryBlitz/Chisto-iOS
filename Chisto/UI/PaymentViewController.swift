//
//  PaymentViewController.swift
//  Chisto
//
//  Created by Алексей on 25.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import RxSwift
import RxCocoa

class PaymentViewController: UIViewController, WKNavigationDelegate {
  let disposeBag = DisposeBag()
  var viewModel: PaymentViewModel? = nil

  let webView = WKWebView()

  override func viewDidLoad() {
    view = webView
    webView.navigationDelegate = self
    guard let viewModel = viewModel else { return }

    viewModel.dismissViewController.drive(onNext: { [weak self] in
        self?.dismiss(animated: true, completion: nil)
      }).addDisposableTo(disposeBag)

    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: #imageLiteral(resourceName:"iconNavbarClose"),
      style: .plain,
      target: nil,
      action: nil
    )

    navigationItem.leftBarButtonItem?.rx
      .tap
      .bind(to: viewModel.didPressCloseButton)
      .addDisposableTo(disposeBag)

    guard let url = viewModel.url else { return }

    let request = URLRequest(url: url)
    webView.load(request)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    AnalyticsManager.logScreen(.payment)
  }

  func finishPayment() {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
    guard let viewModel = viewModel else { return }

    self.dismiss(animated: true, completion: {
      viewModel.didFinishPayment.onNext(viewModel.order)
    })
  }

  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    guard let viewModel = viewModel else { return }
    guard let query = webView.url?.query else { return }
    if query.contains(viewModel.successString) {
      finishPayment()
    }
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
}
