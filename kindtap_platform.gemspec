require File.expand_path('lib/kindtap_platform/version', __dir__)

Gem::Specification.new do |spec|
  spec.name                  = 'kindtap-platform-ruby'
  spec.version               = KindTapPlatform::VERSION
  spec.authors               = ['Jeff Trudeau']
  spec.email                 = ['jeff@kindtap.com']
  spec.summary               = 'Facilitates integration with KindTap Platform'
  spec.description           = 'This library currently supports generating a signed authorization header which is required to make requests to KindTap Platform APIs.'
  spec.homepage              = 'https://github.com/KindTap/kindtap-platform-ruby'
  spec.license               = 'MIT'
  spec.platform              = Gem::Platform::RUBY
  #spec.required_ruby_version = '~> 2.7'
  spec.files = Dir[
    'Gemfile',
    'kindtap_platform.gemspec',
    'lib/**/*.rb',
    'LICENSE',
    'README.md',
  ]
  spec.extra_rdoc_files = [
    'README.md',
  ]
end
