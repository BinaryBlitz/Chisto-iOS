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

  let contactInfoHeaderView = ContactFormTableHeaderView.nibInstance()!
  let adressHeaderView = ContactFormTableHeaderView.nibInstance()!
  let commentHeaderView = ContactFormTableHeaderView.nibInstance()!

  let maskedPhoneInput = MaskedInput(formattingType: .phoneNumber)

  enum Sections: Int {
    case contactInfo = 0
    case adress
    case comment
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

  }

  func configureSections() {
    guard let viewModel = viewModel else { return }

    contactInfoHeaderView.configure(viewModel: viewModel.contactInfoHeaderModel)
    adressHeaderView.configure(viewModel: viewModel.adressHeaderModel)
    commentHeaderView.configure(viewModel: viewModel.commentHeaderModel)
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    switch section {
    case Sections.contactInfo.rawValue:
      return contactInfoHeaderView
    case Sections.adress.rawValue:
      return adressHeaderView
    case Sections.comment.rawValue:
      return commentHeaderView
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

  func selectNextField(currentIndex: Int) {
    let nextField = fields[currentIndex + 1]
    if !nextField.isEnabled { return selectNextField(currentIndex: currentIndex + 1) }
    nextField.becomeFirstResponder()
  }
}
