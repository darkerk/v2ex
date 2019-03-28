platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!
target 'V2EX' do
    pod 'Kanna', '~> 4.0.3'
    pod 'RxCocoa', '~> 4.4.2'
    pod 'RxDataSources', '~> 3.1.0'
    pod 'Moya/RxSwift', '~> 12.0.1'
    pod 'Kingfisher', '~> 5.3.0'
    pod 'PKHUD', '~> 5.2.1'
    pod 'SKPhotoBrowser', '~> 6.0.0'
    pod '1PasswordExtension', '~> 1.8.5'
    pod 'MonkeyKing', '~> 1.13.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
        end
    end
end
