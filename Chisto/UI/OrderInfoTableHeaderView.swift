//
//  OrderInfoTableHeaderView.swift
//  Chisto
//
//  Created by Алексей on 22.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OrderInfoTableHeaderView: UIView {
  let disposeBag = DisposeBag()
  @IBOutlet weak var laundryLogoView: UIImageView!
  @IBOutlet weak var laundryTitleLabel: UILabel!
  @IBOutlet weak var laundryDescriptionLabel: UILabel!
  @IBOutlet weak var orderStatusLabel: UILabel!
  @IBOutlet weak var orderStatusImageView: UIImageView!
  @IBOutlet weak var paymentMethodLabel: UILabel!
  @IBOutlet weak var paymentMethodImageView: UIImageView!
  @IBOutlet weak var orderDateLabel: UILabel!
  @IBOutlet weak var orderPromoCodeLabel: UILabel!
  @IBOutlet weak var orderPromoCodeDiscountLabel: UILabel!
  @IBOutlet weak var orderPriceLabel: UILabel!
  @IBOutlet weak var deliveryPriceLabel: UILabel!
  @IBOutlet weak var orderTotalCostLabel: UILabel!
  
  func configure(viewModel: OrderInfoTableHeaderViewModel) {
    viewModel.orderPrice.asObservable().bindTo(orderPriceLabel.rx.text).addDisposableTo(disposeBag)
    viewModel.deliveryPrice.asObservable().bindTo(deliveryPriceLabel.rx.text).addDisposableTo(disposeBag)
    viewModel.totalCost.asObservable().bindTo(orderTotalCostLabel.rx.text).addDisposableTo(disposeBag)
    viewModel.promoCode.asObservable().bindTo(orderPromoCodeLabel.rx.text).addDisposableTo(disposeBag)
    viewModel.promoCodeDiscount.asObservable().bindTo(orderPromoCodeDiscountLabel.rx.text).addDisposableTo(disposeBag)
    viewModel.paymentType.asObservable().bindTo(paymentMethodLabel.rx.text).addDisposableTo(disposeBag)

    bindLaundryData(viewModel: viewModel)
    bindLaundryStatusData(viewModel: viewModel)
  }

  func bindLaundryData(viewModel: OrderInfoTableHeaderViewModel) {
    viewModel.laundryIcon.asObservable().subscribe(onNext: { [weak self] icon in
      self?.laundryLogoView.kf.setImage(with: icon)
    }).addDisposableTo(disposeBag)

    viewModel.laundryTitle.asObservable().bindTo(laundryTitleLabel.rx.text).addDisposableTo(disposeBag)
    viewModel.laundryDescriprion.asObservable().bindTo(laundryDescriptionLabel.rx.text).addDisposableTo(disposeBag)

  }
  
  func bindLaundryStatusData(viewModel: OrderInfoTableHeaderViewModel) {
    viewModel.orderStatus.asObservable().bindTo(orderStatusLabel.rx.text).addDisposableTo(disposeBag)
    viewModel.orderDate.asObservable().bindTo(orderDateLabel.rx.text).addDisposableTo(disposeBag)

    viewModel.orderStatusIcon.asObservable().filter { $0 != nil }.map { $0! }
      .bindTo(orderStatusImageView.rx.image).addDisposableTo(disposeBag)

    viewModel.orderStatusColor.asObservable().subscribe(onNext: { [weak self] color in
      self?.orderStatusLabel.textColor = color
    }).addDisposableTo(disposeBag)
    
  }


}
