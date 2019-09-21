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
  @IBOutlet weak var phoneCheckImageView: UIImageView!

  // MARK: - Check labels
  
  @IBOutlet weak var firstNameCheckView: UIImageView!
  @IBOutlet weak var cityCheckView: UIImageView!
  @IBOutlet weak var streetCheckView: UIImageView!
  @IBOutlet weak var buildingCheckView: UIImageView!
  @IBOutlet weak var apartmentCheckView: UIImageView!
  
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
    }
  }

  let phoneNumberHeaderView = ContactFormTableHeaderView.nibInstance()!
  let contactDataHeaderView = ContactFormTableHeaderView.nibInstance()!
  let commentHeaderView = ContactFormTableHeaderView.nibInstance()!
  let paymentHeaderView = ContactFormTableHeaderView.nibInstance()!

  let maskedPhoneInput = MaskedInput(formattingType: .phoneNumber)
  let maskedCodeInput = MaskedInput(formattingType: .pattern("* ∙ * ∙ * ∙ * ∙ *"))

  enum Sections: Int {
    case phoneNumber
    case paymentMethod
    case contactData
    case comment

    static let count = 4
  }

  enum PhoneRows: Int {
    case phone = 0
    case code

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
    hideSectionsIfNeeded()
  }

  func configureFields() {
    guard let viewModel = viewModel else { return }

    (firstNameField.rx.text <-> viewModel.firstName).addDisposableTo(disposeBag)
    (phoneField.rx.text <-> viewModel.phone).addDisposableTo(disposeBag)
    (emailField.rx.text <-> viewModel.email).addDisposableTo(disposeBag)
    (cityField.rx.text <-> viewModel.city).addDisposableTo(disposeBag)
    (streetField.rx.text <-> viewModel.street).addDisposableTo(disposeBag)
    (buildingField.rx.text <-> viewModel.building).addDisposableTo(disposeBag)
    (apartmentField.rx.text <-> viewModel.apartment).addDisposableTo(disposeBag)
    (commentField.rx.text <-> viewModel.comment).addDisposableTo(disposeBag)
    (codeField.rx.text <-> viewModel.phoneViewModel.code).addDisposableTo(disposeBag)

    configureValidations()

    viewModel.codeSectionIsVisible.asObservable()
      .map { !$0 }
      .bind(to: sendCodeButton.rx.isHidden)
      .addDisposableTo(disposeBag)

    viewModel.phoneViewModel
      .sendButtonEnabled
      .asObservable()
      .subscribe(onNext: { [weak self] isEnabled in
        self?.sendCodeButton.backgroundColor = isEnabled ? UIColor.chsSkyBlue : UIColor.chsCoolGrey
        self?.sendCodeButton.defaultBackgroundColor = isEnabled ? UIColor.chsSkyBlue : UIColor.chsCoolGrey
      }).addDisposableTo(disposeBag)

    sendCodeButton.rx.tap.asObservable().subscribe(onNext: { [weak self] in
      self?.codeField.becomeFirstResponder()
    }).addDisposableTo(disposeBag)

    maskedPhoneInput.configure(textField: phoneField)
    maskedCodeInput.configure(textField: codeField)

    maskedCodeInput.isValid
      .asObservable()
      .bind(to: viewModel.phoneViewModel.codeIsValid)
      .addDisposableTo(disposeBag)

    fields = [phoneField, codeField, firstNameField,
              cityField, streetField, buildingField, apartmentField, commentField]

    for field in fields {
      field.delegate = self
      field.returnKeyType = .continue
    }

    commentField.returnKeyType = .done

    cityButton.rx.tap.bind(to: viewModel.cityFieldDidTap).addDisposableTo(disposeBag)

    viewModel.paymentMethod
      .asDriver()
      .distinctUntilChanged()
      .drive(onNext: { [weak self] paymentMethod in
      self?.payWithCardSelected = paymentMethod == .card
      self?.payByCashSelected = paymentMethod == .cash
      self?.applePaySelected = paymentMethod == .applePay
      self?.hideSectionsIfNeeded()
    }).addDisposableTo(disposeBag)

    viewModel.codeSectionIsVisible
      .asObservable()
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] _ in
      self?.hideSectionsIfNeeded()
    }).addDisposableTo(disposeBag)

  }

  func configureValidations() {

    guard let viewModel = viewModel else { return }

    viewModel.highlightPhoneField
      .subscribe(onNext: { [weak self] in
        self?.phoneField.setValidationState(true)
      }).addDisposableTo(disposeBag)

    viewModel.highlightFirstNameField
      .subscribe(onNext: { [weak self] in
        self?.firstNameField.setValidationState(true)
      }).addDisposableTo(disposeBag)

    viewModel.highlightCityField
      .subscribe(onNext: { [weak self] in
        self?.cityField.setValidationState(true)
      }).addDisposableTo(disposeBag)

    viewModel.highlightStreetField
      .subscribe(onNext: { [weak self] in
        self?.streetField.setValidationState(true)
      }).addDisposableTo(disposeBag)

    viewModel.highlightBuildingField
      .subscribe(onNext: { [weak self] in
        self?.buildingField.setValidationState(true)
      }).addDisposableTo(disposeBag)

    viewModel.highlightApartmentField
      .subscribe(onNext: { [weak self] in
        self?.apartmentField.setValidationState(true)
      }).addDisposableTo(disposeBag)

    viewModel.firstNameIsValid
      .asObservable()
      .map { !$0 }
      .bind(to: firstNameCheckView.rx.isHidden)
      .addDisposableTo(disposeBag)

    viewModel.streetIsValid.asObservable()
      .map { !$0 }
      .bind(to: streetCheckView.rx.isHidden)
      .addDisposableTo(disposeBag)

    viewModel.buildingIsValid.asObservable()
      .map { !$0 }
      .bind(to: buildingCheckView.rx.isHidden)
      .addDisposableTo(disposeBag)

    viewModel.apartmentIsValid.asObservable()
      .map { !$0 }
      .bind(to: apartmentCheckView.rx.isHidden)
      .addDisposableTo(disposeBag)

    sendCodeButton.rx.tap
      .bind(to: viewModel.phoneViewModel.sendButtonDidTap)
      .addDisposableTo(disposeBag)

    viewModel.phoneIsValid
      .asObservable()
      .map { !$0 }
      .bind(to: phoneCheckImageView.rx.isHidden)
      .addDisposableTo(disposeBag)

    viewModel.phoneViewModel
      .phoneIsValidated
      .asObservable()
      .map { !$0 }
      .bind(to: phoneField.rx.isEnabled)
      .addDisposableTo(disposeBag)
  }

  func hideSectionsIfNeeded() {
    let isAuthorized = viewModel?.isAuthorized.value ?? false
    contactDataHeaderView.isHidden = !isAuthorized || applePaySelected
    paymentHeaderView.isHidden = !isAuthorized
    commentHeaderView.isHidden = !isAuthorized
    tableView.beginUpdates()
    tableView.reloadData()
    tableView.endUpdates()
    tableView.setNeedsLayout()
    tableView.layoutIfNeeded()
  }

  func configureSections() {
    guard let viewModel = viewModel else { return }

    contactDataHeaderView.configure(viewModel: viewModel.contactDataHeaderModel)
    phoneNumberHeaderView.configure(viewModel: viewModel.phoneHeaderModel)
    commentHeaderView.configure(viewModel: viewModel.commentHeaderModel)
    paymentHeaderView.configure(viewModel: viewModel.paymentHeaderModel)

    viewModel.phoneViewModel
      .phoneIsValidated.asObservable()
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] _ in
        self?.hideSectionsIfNeeded()
      }).addDisposableTo(disposeBag)
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    switch section {
    case Sections.phoneNumber.rawValue:
      return phoneNumberHeaderView
    case Sections.paymentMethod.rawValue:
      return paymentHeaderView
    case Sections.contactData.rawValue:
      return contactDataHeaderView
    case Sections.comment.rawValue:
      return commentHeaderView
    default:
      return nil
    }
  }

  @IBAction func streetFieldDidTap(_ sender: Any) {
    viewModel?.streetNameFieldDidTap.onNext(())
  }

  override func viewWillDisappear(_ animated: Bool) {
    tableView.endEditing(true)
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard let viewModel = viewModel else { return super.tableView(tableView, heightForHeaderInSection: section) }
    if section == Sections.contactData.rawValue &&
      (!viewModel.isAuthorized.value ||
      viewModel.paymentMethod.value == .applePay) {
      return 0.1
    }
    if section == Sections.paymentMethod.rawValue &&
      !viewModel.isAuthorized.value {
      return 0.1
    }
    return 40
  }

  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if section == Sections.contactData.rawValue && viewModel?.paymentMethod.value == .applePay {
      return 0.1
    }
    return super.tableView(tableView, heightForFooterInSection: section)
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let emptyCell = UITableViewCell()
    emptyCell.backgroundColor = .clear
    guard let viewModel = viewModel else { return super.tableView(tableView, cellForRowAt: indexPath) }

    switch indexPath.section {
    case Sections.paymentMethod.rawValue:
      guard viewModel.phoneViewModel.phoneIsValidated.value else { return emptyCell }
      guard indexPath.row == PaymentRows.applePay.rawValue && !viewModel.canUseApplePay else {
        return super.tableView(tableView, cellForRowAt: indexPath)
      }
      return UITableViewCell()
    case Sections.phoneNumber.rawValue:
      if viewModel.phoneViewModel.phoneIsValidated.value && indexPath.row == PhoneRows.code.rawValue {
        return emptyCell
      }
      break
    case Sections.contactData.rawValue:
      guard viewModel.isAuthorized.value && viewModel.paymentMethod.value != .applePay else { return emptyCell }
      return super.tableView(tableView, cellForRowAt: indexPath)
    case Sections.comment.rawValue:
      guard viewModel.isAuthorized.value else { return emptyCell }
      return super.tableView(tableView, cellForRowAt: indexPath)
    default:
      break
    }
    return super.tableView(tableView, cellForRowAt: indexPath)
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    guard let viewModel = viewModel else { return super.tableView(tableView, heightForRowAt: indexPath) }

    switch indexPath.section {
    case Sections.paymentMethod.rawValue:
      guard viewModel.phoneViewModel.phoneIsValidated.value else { return 0 }
      guard indexPath.row == PaymentRows.applePay.rawValue && !viewModel.canUseApplePay else {
        return super.tableView(tableView, heightForRowAt: indexPath)
      }
      return 0
    case Sections.phoneNumber.rawValue:
      if viewModel.phoneViewModel.phoneIsValidated.value && indexPath.row == PhoneRows.code.rawValue {
        return 0
      }
      break
    case Sections.contactData.rawValue:
      guard viewModel.isAuthorized.value && viewModel.paymentMethod.value != .applePay else { return 0 }
      if viewModel.currentScreen == .orderRegistration && indexPath.row == 1 { return 0 }
      return super.tableView(tableView, heightForRowAt: indexPath)
    case Sections.comment.rawValue:
      guard viewModel.isAuthorized.value else { return 0 }
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

  func textFieldDidBeginEditing(_ textField: UITextField) {
    guard let textField = textField as? HoshiTextField else { return }
    textField.setValidationState(false)
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
