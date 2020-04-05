
Pod::Spec.new do |s|
  s.name         = 'Layers'
  s.version      = '1.0.0.LOCAL'
  s.summary      = 'Demo of custom modal management for Market.'
  s.homepage     = 'https://github.com/kyleve/Layers'
  s.license      = { type: 'Proprietary', text: "© 2020 Square, Inc." }
  s.author       = { 'iOS Team' => 'seller-ios@squareup.com' }
  s.source       = { git: 'Not Published', tag: "podify/#{s.version}" }

  s.ios.deployment_target = '10.0'

  s.swift_versions = ['5.1']

  s.source_files = 'Layers/Sources/**/*.{swift}'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Layers/Tests/**/*.{swift}'
    test_spec.ios.resource_bundle = { 'LayersTestsResources' => 'Layers/Tests/Resources/**/*.*' }

    test_spec.framework = 'XCTest'

    test_spec.requires_app_host = true
  end
end
