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

class ProfileManager {
  
  let disposeBag = DisposeBag()

  static let instance = ProfileManager()
  private let profileKey = "profileId"

  let userProfile: Profile?
  
  let apiToken: Variable<String?>

  // TODO: refactor
  func updateProfile(closure: ((Profile) -> Void)) {
    guard let profile = userProfile else { return }
    
    let realm = try! Realm()
    
    try! realm.write {
      closure(profile)
    }
  }

  init() {
    var profile: Profile
    
    if let profileId = UserDefaults.standard.value(forKey: profileKey), let savedProfile = uiRealm.object(ofType: Profile.self, forPrimaryKey: profileId){
      
      profile = savedProfile
      
    } else {
      
      profile = Profile()
      try! uiRealm.write {
        uiRealm.add(profile)
      }
      UserDefaults.standard.set(profile.id, forKey: profileKey)

    }

    self.userProfile = profile
    
    self.apiToken = Variable<String?>(profile.apiToken)
    
    Observable.from(profile)
      .map { $0.apiToken }
      .bindTo(apiToken)
      .addDisposableTo(disposeBag)
    
    UserDefaults.standard.set(profile.id, forKey: profileKey)

  }

}
