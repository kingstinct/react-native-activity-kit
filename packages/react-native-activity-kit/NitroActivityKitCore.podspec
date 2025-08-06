require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "NitroActivityKitCore"
  s.version      = package["version"]
  s.summary      = package["description"] + " - App Extension compatible core"
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://github.com/mrousavy/nitro.git", :tag => "#{s.version}" }

  # Only include the essential files for App Extensions
  s.source_files = [
    "ios/ActivityKitCore.swift"
  ]

  # No NitroModules dependency for App Extensions
  s.frameworks   = "ActivityKit"
  
  # Mark as App Extension safe
  s.pod_target_xcconfig = {
    'APPLICATION_EXTENSION_API_ONLY' => 'YES'
  }
end