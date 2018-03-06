platform :ios, '9.0'
use_frameworks!

target 'V2EX' do
    pod 'Fabric', '~> 1.6.13'
    pod 'Crashlytics', '~> 3.8.6'
    pod 'Kanna', '~> 2.2.1'
    pod 'RxCocoa', '~> 3.6.1'
    pod 'RxDataSources', '~> 2.0.2'
    pod 'Moya/RxSwift', '~> 9.0.0'
    pod 'Kingfisher', '~> 3.13.0'
    pod 'PKHUD', '~> 4.2.3'
    pod 'SKPhotoBrowser', '~> 4.1.0'
    pod '1PasswordExtension', '~> 1.8.4'
    pod 'MonkeyKing', '~> 1.3.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
        end
    end
end

