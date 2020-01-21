# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'localhost' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for localhost
  def sharedPods
    pod 'RSKImageCropper'
    pod 'InitialsImageView'
    pod 'SDWebImage'
    pod 'SwiftHTTP'
    pod 'Alamofire'
    pod 'Cosmos'
    pod 'Firebase/Firestore'
    pod 'Firebase/Messaging'
    pod 'MessageKit'
    pod 'IQKeyboardManager'
    pod 'FBSDKLoginKit'
  end
  
  sharedPods

  target 'localhostTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'localhostUITests' do
    # Pods for testing
  end
  
  target 'NotificationViewController' do
    sharedPods
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
      end
    end
  end

end
