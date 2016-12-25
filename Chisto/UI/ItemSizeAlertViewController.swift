//
//  ItemSizeAlertViewController.swift
//  Chisto
//
//  Created by Алексей on 04.12.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import TextFieldEffects

class ItemSizeAlertViewController: UIViewController {
  let disposeBag = DisposeBag()
  var viewModel: ItemSizeAlertViewModel? = nil
  
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var lengthField: HoshiTextField!
  @IBOutlet weak var widthField: HoshiTextField!
  @IBOutlet weak var areaField: HoshiTextField!
  
  @IBOutlet weak var сontinueButton: GoButton!
  @IBOutlet weak var cancelButton: GoButton!
  
  // Constants
  let animationDuration = 0.2
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    hideKeyboardWhenTappedAround()
    view.backgroundColor = UIColor(white: 0, alpha: 0.5)

    lengthField.delegate = self
    widthField.delegate = self

    guard let viewModel = viewModel else { return }

    _ = lengthField.rx.text <-> viewModel.lengthText
    _ = widthField.rx.text <-> viewModel.widthText
    viewModel.areaText.asObservable().bindTo(areaField.rx.text).addDisposableTo(disposeBag)
    
    сontinueButton.rx.tap.bindTo(viewModel.continueButtonDidTap).addDisposableTo(disposeBag)
    cancelButton.rx.tap.bindTo(viewModel.cancelButtonDidTap).addDisposableTo(disposeBag)

    viewModel.dismissViewController.drive(onNext: { [weak self] success in
      UIView.animate(withDuration: self?.animationDuration ?? 0, animations: {
        self?.view.alpha = 0
      }, completion: { _ in
        self?.dismiss(animated: false, completion: { _ in success ? viewModel.didFinishAlertSuccess.onNext() : () })
      })
    }).addDisposableTo(disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIView.animate(withDuration: animationDuration) { [weak self] in
      self?.view.alpha = 0
      self?.view.alpha = 1
    }
  }

}

extension ItemSizeAlertViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let text = textField.text else { return true }
    guard let maxNumberLength = viewModel?.maxNumberLength else { return true }
    let newLength = text.characters.count + string.characters.count - range.length
    return newLength <= maxNumberLength
  }

  func textFieldDidBeginEditing(_ textField: UITextField) {
    textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)

  }
  
}
