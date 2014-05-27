Pod::Spec.new do |s|
  s.name         = 'GPDownloadProgressView'
  s.version      = '1.0.0'
  s.summary      = 'An iOS7-inspired download progress view.'
  s.homepage     = 'https://github.com/gpinigin/GPDownloadProgressView'
  s.author             = { "Gleb Pinigin" => "gpinigin@gmail.com" }
  s.social_media_url   = "http://twitter.com/gpinigin"

  s.source       = { :git => "https://github.com/gpinigin/GPDownloadProgressView.git", :tag => s.version.to_s }
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.platform     = :ios, '5.0'
  s.requires_arc = true

  s.source_files  = 'GPDownloadProgressView'
  s.public_header_files = 'GPDownloadProgressView/*.h'
  s.preserve_paths = 'LICENSE'

  s.frameworks  = 'CoreGraphics', 'QuartzCore'
end
