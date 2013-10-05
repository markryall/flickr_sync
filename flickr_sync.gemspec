Gem::Specification.new do |spec|
  spec.name = 'flickr_sync'
  spec.version = '0.0.4'
  spec.summary = 'command line utility to synch a folder with flickr'
  spec.description = <<-EOF
Flickr is a very effective way to backup lots of images but the upload tools are all pretty awful.

Hopefully this is marginally less painful
EOF
  spec.authors << 'Mark Ryall'
  spec.email = 'mark@ryall.name'
  spec.homepage = 'http://github.com/markryall/flickr_sync'
  spec.files = Dir['lib/**/*'] + Dir['spec/**/*'] + Dir['bin/*'] + ['README.rdoc', 'MIT-LICENSE', 'HISTORY.rdoc']
  spec.executables << 'flickr_sync'

  spec.add_dependency 'clamp', '~>0'
  spec.add_dependency 'flickraw', '~>0'
  spec.add_dependency 'splat', '~>0'

  spec.add_development_dependency 'rake', '~>0'
  spec.add_development_dependency 'rspec', '~>2'
end
