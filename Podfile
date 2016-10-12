# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'Chisto' do
    # Comment this line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    
    # Pods for BinaryBlitzTest
    pod 'Alamofire', '~> 4.0'
    pod 'RxSwift', '~> 3.0.0-beta.1'
    pod 'RxCocoa', '~> 3.0.0-beta.1'
    pod 'EasyPeasy'
    pod 'ReusableKit', '~> 1.0'
    pod 'RxDataSources', '= 1.0.0-beta.3'
    
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |configuration|
                configuration.build_settings['SWIFT_VERSION'] = "3.0"
            end
        end
    end
    
end
