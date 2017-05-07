//
//  DataManager+TokenManagerType.swift
//  Chisto
//
//  Created by Алексей on 16.03.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import RxSwift
import RxCocoa
import RxRealm
import SwiftyJSON
import ObjectMapper

protocol TokenManagerType {
  func createVerificationToken(phone: String) -> Observable<Void>
  func verifyToken(code: String) -> Observable<Void>
  func sendNotificationToken(tokenString: String) -> Observable<Void>
}

extension DataManager: TokenManagerType {
  func createVerificationToken(phone: String) -> Observable<Void> {
    return networkRequest(method: .post, .createVerificationToken, ["verification_token": ["phone_number": phone] as Any])
      .flatMap { response -> Observable<Void> in
        let json = JSON(object: response)
        let verificationToken = json["token"].string
        ProfileManager.instance.updateProfile { profile in
          profile.verificationToken = verificationToken
          profile.phone = json["phone_number"].stringValue
        }
        return Observable.just()
    }
  }

  func verifyToken(code: String) -> Observable<Void> {
    guard let verificationToken = ProfileManager.instance.userProfile.value.verificationToken else { return Observable.error(DataError.unknown(description: "")) }

    return networkRequest(
      method: .patch,
      .verifyToken,
      ["verification_token": ["code": code,
       "token": verificationToken] as Any]
      )
      .flatMap { response -> Observable<Void> in
        let json = JSON(object: response)
        print(json)
        ProfileManager.instance.updateProfile { profile in
          profile.apiToken = json["api_token"].string
          profile.isVerified = true
        }
        return Observable.just()
    }
  }

  func sendNotificationToken(tokenString: String) -> Observable<Void> {
    let userData: Dictionary = ["user": ["device_token": tokenString, "platform": "ios"]]
    return networkRequest(method: .patch, .updateUser, userData).map { _ in }
  }
  
}
