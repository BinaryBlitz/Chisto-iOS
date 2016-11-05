# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'Chisto' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for BinaryBlitzTest
  pod 'Alamofire', '~> 4.0'
  pod 'RxSwift', '~> 3.0.0-beta.1'
  pod 'RxCocoa', '~> 3.0.0-beta.1'
  pod 'RxDataSources', '~> 1.0.0-beta.3'
  pod 'Fabric'
  pod 'IQKeyboardManagerSwift'
  pod 'FloatRatingView', '~> 2.0.0'
  pod 'ObjectMapper', '~> 2.2'
  pod 'ObjectMapper+Realm', '~> 0.2'
  pod 'RealmSwift', '~> 2.0.3'
  pod 'RxRealm', '~> 0.3.1'
  pod 'Kingfisher', '~> 3.0'

  pod 'Crashlytics'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |configuration|
        configuration.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
  end
end
