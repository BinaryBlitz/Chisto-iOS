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
import PassKit

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
  @IBOutlet weak var codeField: HoshiTextField!

  @IBOutlet weak var cityButton: UIButton!
  @IBOutlet weak var payWithApplePayView: UIView!
  @IBOutlet weak var payWithCardLabel: UILabel!
  @IBOutlet weak var payByCashLabel: UILabel!
  @IBOutlet weak var applePayLabel: UILabel!
  @IBOutlet weak var sendCodeButton: GoButton!
  @IBOutlet var payByCashIconViews: [UIImageView]!
  @IBOutlet var paymentMethodCardIconViews: [UIImageView]!
  @IBOutlet var payWithApplePayIconViews: [UIImageView]!

  var payWithCardSelected: Bool = true {
    didSet {
      payWithCardLabel.isHighlighted = payWithCardSelected
      paymentMethodCardIconViews.forEach { $0.isHighlighted = payWithCardSelected }
    }
  }

  var payByCashSelected: Bool = false {
    didSet {
      payByCashLabel.isHighlighted = payByCashSelected
      payByCashIconViews.forEach { $0.isHighlighted = payByCashSelected }
    }
  }

  var applePaySelected: Bool = false {
    didSet {
      applePayLabel.isHighlighted = applePaySelected
      payWithApplePayIconViews.forEach { $0.isHighlighted = applePaySelected }
      adressHeaderView.isHidden = applePaySelected
    }
  }

  let profileHeaderView = ContactFormTableHeaderView.nibInstance()!
  let contactsHeaderView = ContactFormTableHeaderView.nibInstance()!
  let adressHeaderView = ContactFormTableHeaderView.nibInstance()!
  let commentHeaderView = ContactFormTableHeaderView.nibInstance()!
  let paymentHeaderView = ContactFormTableHeaderView.nibInstance()!

  let maskedPhoneInput = MaskedInput(formattingType: .phoneNumber)
  let maskedCodeInput = MaskedInput(formattingType: .pattern("* ∙ * ∙ * ∙ * ∙ *"))

  enum Sections: Int {
    case profile = 0
    case contactData
    case paymentMethod
    case adress
    case comment

    static let count = 4
  }

  enum ContactDataRows: Int {
    case phone = 0
    case code
    case email

    static let count = 3
  }


  enum PaymentRows: Int {
    case card = 0
    case applePay
    case cash

    static let count = 3
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
    (codeField.rx.text <-> viewModel.phoneViewModel.code).addDisposableTo(disposeBag)

    sendCodeButton.rx.tap
      .bind(to: viewModel.phoneViewModel.sendButtonDidTap)
      .addDisposableTo(disposeBag)

    viewModel.phoneViewModel
      .sendButtonEnabled
      .asObservable()
      .bind(to: sendCodeButton.rx.isEnabled)
      .addDisposableTo(disposeBag)

    viewModel.codeSectionIsVisible.asObservable()
      .map { !$0 }
      .bind(to: sendCodeButton.rx.isHidden)
      .addDisposableTo(disposeBag)

    maskedPhoneInput.configure(textField: phoneField)
    maskedCodeInput.configure(textField: codeField)

    maskedCodeInput.isValid
      .asObservable()
      .bind(to: viewModel.phoneViewModel.codeIsValid)
      .addDisposableTo(disposeBag)

    fields = [firstNameField, lastNameField, phoneField, codeField, emailField,
              cityField, streetField, buildingField, apartmentField, commentField]

    for field in fields {
      field.delegate = self
      field.returnKeyType = .continue
    }

    commentField.returnKeyType = .done

    cityButton.rx.tap.bind(to: viewModel.cityFieldDidTap).addDisposableTo(disposeBag)

    viewModel.paymentMethod.asDriver().drive(onNext: { [weak self] paymentMethod in
      self?.payWithCardSelected = paymentMethod == .card
      self?.payByCashSelected = paymentMethod == .cash
      self?.applePaySelected = paymentMethod == .applePay
      self?.tableView.beginUpdates()
      self?.tableView.reloadData()
      self?.tableView.endUpdates()
    }).addDisposableTo(disposeBag)

    viewModel.codeSectionIsVisible.asObservable().subscribe(onNext: { [weak self] _ in
      self?.tableView.beginUpdates()
      self?.tableView.reloadData()
      self?.tableView.endUpdates()
    }).addDisposableTo(disposeBag)

  }

  func configureSections() {
    guard let viewModel = viewModel else { return }

    profileHeaderView.configure(viewModel: viewModel.userHeaderModel)
    contactsHeaderView.configure(viewModel: viewModel.contactsHeaderModel)
    adressHeaderView.configure(viewModel: viewModel.adressHeaderModel)
    commentHeaderView.configure(viewModel: viewModel.commentHeaderModel)
    paymentHeaderView.configure(viewModel: viewModel.paymentHeaderModel)
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    switch section {
    case Sections.profile.rawValue:
      return profileHeaderView
    case Sections.contactData.rawValue:
      return contactsHeaderView
    case Sections.adress.rawValue:
      return adressHeaderView
    case Sections.comment.rawValue:
      return commentHeaderView
    case Sections.paymentMethod.rawValue:
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
    if section == Sections.adress.rawValue,
      let method = viewModel?.paymentMethod.value,
      method == .applePay {
      return 0.1
    }
    return 40
  }

  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if section == Sections.adress.rawValue && viewModel?.paymentMethod.value == .applePay {
      return 0.1
    }
    return super.tableView(tableView, heightForFooterInSection: section)
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    guard let viewModel = viewModel else { return super.tableView(tableView, heightForRowAt: indexPath) }

    switch indexPath.section {
    case Sections.paymentMethod.rawValue where indexPath.row == PaymentRows.applePay.rawValue:
      guard !viewModel.canUseApplePay else {
        return super.tableView(tableView, heightForRowAt: indexPath)
      }
      return 0
    case Sections.contactData.rawValue:
      if viewModel.phoneViewModel.phoneIsValidated.value && indexPath.row == ContactDataRows.code.rawValue {
        return 0
      }
      break
    case Sections.adress.rawValue:
      guard viewModel.paymentMethod.value != .applePay else { return 0 }
      return super.tableView(tableView, heightForRowAt: indexPath)
    default:
      break
    }
    return super.tableView(tableView, heightForRowAt: indexPath)
  }

  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard indexPath.section == Sections.paymentMethod.rawValue && indexPath.row == PaymentRows.applePay.rawValue else { return }
    guard let viewModel = viewModel, !viewModel.canUseApplePay else { return }

    cell.isHidden = true
  }

  @IBAction func payByCashDidTap(_ sender: Any) {
    viewModel?.paymentMethod.value = .cash
  }

  @IBAction func payWithCardDidTap(_ sender: Any) {
    viewModel?.paymentMethod.value = .card
  }

  @IBAction func payWithApplePayDidTap(_ sender: Any) {
    guard let viewModel = viewModel else { return }
    if viewModel.canPayUsingPaymentMethods {
      viewModel.paymentMethod.value = .applePay
    } else {
      PKPassLibrary().openPaymentSetup()
    }
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

  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {

    guard let text = textField.text, textField == phoneField else { return true }
    return maskedPhoneInput.shouldContinueEditing(text: text, range: range, replacementStirng: string)
  }

  func selectNextField(currentIndex: Int) {
    let nextField = fields[currentIndex + 1]
    if !nextField.isEnabled { return selectNextField(currentIndex: currentIndex + 1) }
    nextField.becomeFirstResponder()
  }
}
