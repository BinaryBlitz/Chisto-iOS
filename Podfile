# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'Chisto' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'Alamofire', '~> 4.0'
  pod 'RxSwift', '~> 4.3.0'
  pod 'RxCocoa', '~> 4.3.0'
  pod 'RxDataSources', '~> 3.1'
  pod 'FloatRatingView', '~> 4.0'
  pod 'IQKeyboardManagerSwift', '~> 6.0.4'
  pod 'ObjectMapper', '~> 3.3.0'
  pod 'ObjectMapper+Realm', git: 'https://github.com/fernandomatal/ObjectMapper-Realm.git'
  pod 'RealmSwift', '~> 3.0'
  pod 'RxRealm', '~> 0.7.6'
  pod 'Kingfisher', '~> 4.10'
  pod 'TextFieldEffects', '~> 1.3'
  pod 'GoogleMaps', '~> 2.1'
  pod 'GooglePlaces', '~> 2.1'
  pod 'SwiftyJSON', '~> 3.1'
  pod 'UIColor_Hex_Swift', '~> 4.2'
  pod 'PhoneNumberKit', '~> 2.5'

  pod 'Fabric'
  pod 'Crashlytics'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |configuration|
        configuration.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end
  end
end
