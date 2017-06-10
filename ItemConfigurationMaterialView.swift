//
//  ItemConfigurationMaterialView.swift
//  Chisto
//
//  Created by Алексей on 10.06.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class ItemConfigurationMaterialView: UIView {
  @IBOutlet weak var materialLabel: UILabel!
  @IBOutlet weak var checkIconView: UIImageView!

  var itemDidTapHandler = PublishSubject<Void>()
  var isSelected = Variable<Bool>(false)
  let disposeBag = DisposeBag()

  override func awakeFromNib() {
    super.awakeFromNib()
    isSelected.asObservable().subscribe(onNext: { [weak self] isSelected in
      self?.materialLabel.isHighlighted = isSelected
      self?.checkIconView.isHighlighted = isSelected
    }).addDisposableTo(disposeBag)
  }

  @IBAction func itemDidTap(_ sender: Any) {
    itemDidTapHandler.onNext()
  }
  
}
