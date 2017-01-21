//
//  ContactDataViewController.swift
//  Chisto
//
//  Created by Алексей on 08.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import TextFieldEffects

class ContactFormViewController: UITableViewController {

  let disposeBag = DisposeBag()

  var viewModel: ContactFormViewModel? = nil

  var fields: [UITextField] = []

  @IBOutlet weak var firstNameField: HoshiTextField!
  @IBOutlet weak var lastNameField: HoshiTextField!
  @IBOutlet weak var phoneField: HoshiTextField!
  @IBOutlet weak var emailField: HoshiTextField!
  @IBOutlet weak var cityField: HoshiTextField!
  @IBOutlet weak var streetField: HoshiTextField!
  @IBOutlet weak var buildingField: HoshiTextField!
  @IBOutlet weak var apartmentField: HoshiTextField!
  @IBOutlet weak var commentField: HoshiTextField!
  @IBOutlet weak var cityButton: UIButton!

  @IBOutlet weak var payWithCardLabel: UILabel!
  @IBOutlet weak var payByCashLabel: UILabel!
  @IBOutlet weak var payWithCardCheckImageView: UIImageView!
  @IBOutlet weak var payByCashCheckImageView: UIImageView!
  
  let contactInfoHeaderView = ContactFormTableHeaderView.nibInstance()!
  let adressHeaderView = ContactFormTableHeaderView.nibInstance()!
  let commentHeaderView = ContactFormTableHeaderView.nibInstance()!
  let paymentHeaderView = ContactFormTableHeaderView.nibInstance()!

  let maskedPhoneInput = MaskedInput(formattingType: .phoneNumber)

  enum Sections: Int {
    case contactInfo = 0
    case adress
    case comment
    case paymentType

    static let count = 4
  }
  
  override func viewDidLoad() {
    hideKeyboardWhenTappedAround()
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    configureFields()
    configureSections()
  }

  func configureFields() {
    guard let viewModel = viewModel else { return }
    (firstNameField.rx.text <-> viewModel.firstName).addDisposableTo(disposeBag)
    (lastNameField.rx.text <-> viewModel.lastName).addDisposableTo(disposeBag)
    (phoneField.rx.text <-> viewModel.phone).addDisposableTo(disposeBag)
    (emailField.rx.text <-> viewModel.email).addDisposableTo(disposeBag)
    (cityField.rx.text <-> viewModel.city).addDisposableTo(disposeBag)
    (streetField.rx.text <-> viewModel.street).addDisposableTo(disposeBag)
    (buildingField.rx.text <-> viewModel.building).addDisposableTo(disposeBag)
    (apartmentField.rx.text <-> viewModel.apartment).addDisposableTo(disposeBag)
    (commentField.rx.text <-> viewModel.comment).addDisposableTo(disposeBag)

    maskedPhoneInput.configure(textField: phoneField)
    maskedPhoneInput.isValid.asObservable().bindTo(viewModel.phoneIsValid).addDisposableTo(disposeBag)

    fields = [firstNameField, lastNameField, phoneField, emailField,
              cityField, streetField, buildingField, apartmentField, commentField]

    for field in fields {
      field.delegate = self
      field.returnKeyType = .continue
    }
    commentField.returnKeyType = .done

    cityButton.rx.tap.bindTo(viewModel.cityFieldDidTap).addDisposableTo(disposeBag)

    viewModel.paymentMethod.asDriver().drive(onNext: { [weak self] paymentMethod in
      switch paymentMethod {
      case .card:
        self?.payWithCardLabel.textColor = .black
        self?.payWithCardCheckImageView.image = #imageLiteral(resourceName: "iconCheckOn")
        self?.payByCashLabel.textColor = .chsCoolGrey
        self?.payByCashCheckImageView.image = #imageLiteral(resourceName: "iconCheckOff")
      case .cash:
        self?.payByCashLabel.textColor = .black
        self?.payByCashCheckImageView.image = #imageLiteral(resourceName: "iconCheckOn")
        self?.payWithCardLabel.textColor = .chsCoolGrey
        self?.payWithCardCheckImageView.image = #imageLiteral(resourceName: "iconCheckOff")
      default:
        break
      }
    }).addDisposableTo(disposeBag)

  }

  func configureSections() {
    guard let viewModel = viewModel else { return }

    contactInfoHeaderView.configure(viewModel: viewModel.contactInfoHeaderModel)
    adressHeaderView.configure(viewModel: viewModel.adressHeaderModel)
    commentHeaderView.configure(viewModel: viewModel.commentHeaderModel)
    paymentHeaderView.configure(viewModel: viewModel.paymentHeaderModel)
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    guard let viewModel = viewModel, viewModel.currentScreen == .profile else { return Sections.count }
    return Sections.count - 1
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    switch section {
    case Sections.contactInfo.rawValue:
      return contactInfoHeaderView
    case Sections.adress.rawValue:
      return adressHeaderView
    case Sections.comment.rawValue:
      return commentHeaderView
    case Sections.paymentType.rawValue:
      return paymentHeaderView
    default:
      return nil
    }
  }
  
  @IBAction func streetFieldDidTap(_ sender: Any) {
    viewModel?.streetNameFieldDidTap.onNext()
  }

  override func viewWillDisappear(_ animated: Bool) {
    tableView.endEditing(true)
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }

  @IBAction func payByCashDidTap(_ sender: Any) {
    viewModel?.paymentMethod.value = .cash
  }

  @IBAction func payWithCardDidTap(_ sender: Any) {
    viewModel?.paymentMethod.value = .card
  }
  

}

extension ContactFormViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    for (index, field) in fields.enumerated() {
      if field == textField {
        guard index < fields.count - 1 else { return true }
        selectNextField(currentIndex: index)
      }
    }
    return false
  }

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let text = textField.text, textField == phoneField else { return true }
    return maskedPhoneInput.shouldContinueEditing(text: text, range: range, replacementStirng: string)

  }

  func selectNextField(currentIndex: Int) {
    let nextField = fields[currentIndex + 1]
    if !nextField.isEnabled { return selectNextField(currentIndex: currentIndex + 1) }
    nextField.becomeFirstResponder()
  }
}
