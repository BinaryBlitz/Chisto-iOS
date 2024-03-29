//
//  ProfileManager.swift
//  Chisto
//
//  Created by Алексей on 09.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import ObjectMapper

/// A class that manages current user profile
class ProfileManager {

  let disposeBag = DisposeBag()

  static let instance = ProfileManager()
  private let profileKey = "profileId"

  let userProfile: Variable<Profile>

  /// Updates current profile
  ///
  /// - Parameter closure: a function that modifies current profile object
  func updateProfile(closure: ((Profile) -> Void)) {
    let profile = userProfile.value
    let realm = try! Realm()
    try! realm.write {
      closure(profile)
    }
    userProfile.value = profile
  }

  /// Deletes current profile and all its data
  func logout() {
    OrderManager.instance.clearOrderItems()
    let realm = try! Realm()
    try! realm.write {
      realm.delete(realm.objects(Profile.self))
      realm.delete(realm.objects(Order.self))
      let newProfile = Profile()
      realm.add(newProfile)
      userProfile.value = newProfile
      UserDefaults.standard.set(newProfile.id, forKey: profileKey)
    }
  }

  /// Instantiates a singletone, creates profile if needed
  init() {
    var profile: Profile

    let realm = RealmManager.instance.uiRealm

    if let profileId = UserDefaults.standard.value(forKey: profileKey),
       let savedProfile = realm.object(ofType: Profile.self, forPrimaryKey: profileId) {
      profile = savedProfile
    } else {
      profile = Profile()
      try! realm.write {
        realm.add(profile)
      }
      UserDefaults.standard.set(profile.id, forKey: profileKey)
    }

    self.userProfile = Variable(profile)
  }
}
