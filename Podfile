# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'UPC' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for UPC

  pod 'UICircularProgressRing'
  pod 'SwiftyJSON'
  pod 'Alamofire', '~> 4.4'

  target 'UPCTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'UPCUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
