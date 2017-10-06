Pod::Spec.new do |spec|
    spec.name               = 'Tiles'
    spec.version            = '1.0.0'
    spec.license            = { :type => 'Apache 2.0', :file => 'LICENSE' }
    spec.homepage           = 'https://github.com/HanSolo/tiles/wiki'
    spec.social_media_url   = 'https://twitter.com/hansolo_'
    spec.authors            = { 'Gerrit Grunwald' => 'han.solo@mac.com' }
    spec.summary            = 'A library that contains some Tiles to create Dashboards'
    spec.source             = { :git => 'https://github.com/HanSolo/tiles.git', :tag => spec.version.to_s }
    spec.module_name        = 'Tiles'
    spec.documentation_url  = 'https://github.com/HanSolo/tiles/wiki'

    spec.ios.deployment_target      = '8.0'
    spec.osx.deployment_target      = '11.00'
    spec.watchos.deployment_target  = '2.0'
    spec.tvos.deployment_target     = '9.0'

    spec.source_files   = 'Source/**/*.swift'
    spec.framework      = 'Foundation', 'CoreLocation'
end