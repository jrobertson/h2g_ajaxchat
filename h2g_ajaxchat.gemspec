Gem::Specification.new do |s|
  s.name = 'h2g_ajaxchat'
  s.version = '0.3.2'
  s.summary = 'This gem makes it easier to build an AJAX chat project. ' + 
      'Designed for Rack-rscript'
  s.authors = ['James Robertson']
  s.files = Dir['lib/h2g_ajaxchat.rb']
  s.add_runtime_dependency('simple-config', '~> 0.7', '>=0.7.0')
  s.signing_key = '../privatekeys/h2g_ajaxchat.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/h2g_ajaxchat'
end
