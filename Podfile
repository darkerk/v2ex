platform :ios, '10.0'
use_frameworks!

target 'V2EX' do
    pod 'Fabric', '~> 1.7.5'
    pod 'Crashlytics', '~> 3.10.1'
    pod 'Kanna', '~> 4.0.0'
    pod 'RxCocoa', '~> 4.1.2'
    pod 'RxDataSources', '~> 3.0.2'
    pod 'Moya/RxSwift', '~> 11.0.1'
    pod 'Kingfisher', '~> 4.6.3'
    pod 'PKHUD', '~> 5.0.0'
    pod 'SKPhotoBrowser', '~> 5.0.5'
    pod '1PasswordExtension', '~> 1.8.5'
    pod 'MonkeyKing', '~> 1.5.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.0'
        end
    end
end
