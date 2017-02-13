# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'Chisto' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'Alamofire', '~> 4.0'
  pod 'RxSwift', '~> 3.0'
  pod 'RxCocoa', '~> 3.0'
  pod 'RxDataSources', '~> 1.0'
  pod 'FloatRatingView', '~> 2.0'
  pod 'IQKeyboardManagerSwift', '~> 4.0'
  pod 'ObjectMapper', '~> 2.2'
  pod 'ObjectMapper+Realm', '~> 0.2'
  pod 'RealmSwift', '~> 2.4'
  pod 'RxRealm', '~> 0.5'
  pod 'Kingfisher', '~> 3.0'
  pod 'TextFieldEffects', '~> 1.3'
  pod 'GoogleMaps', '~> 2.1'
  pod 'GooglePlaces', '~> 2.1'
  pod 'SwiftyJSON', '~> 3.1'
  pod 'UIColor_Hex_Swift', '~> 3.0'
  pod 'PhoneNumberKit', '~> 1.2'

  pod 'Fabric'
  pod 'Crashlytics'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |configuration|
        configuration.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
  end
end
