PKG_FILES = ["MIT-LICENSE", "Rakefile", "README.textile", "lib/castronaut.rb", "lib/version.rb", "doc/jamis.rb"]

Gem::Specification.new do |s|
  s.name = 'castronaut'
  s.version = "0.1.0"
  s.summary = 'CAS Server'
  s.description = "CAS Server"
  s.files = PKG_FILES
  s.require_path = 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.textile', 'MIT-LICENSE', 'CHANGELOG']
  s.rdoc_options = ['--line-numbers', '--inline-source', '--main', 'README.textile', '--title', 'Castronaut']
  s.author = 'Relevance Inc'
  s.email = 'opensource@thinkrelevance.com'
  s.homepage = 'http://github.com/relevance/castronaut'
  
  s.add_runtime_dependency 'activerecord'
  s.add_development_dependency 'rspec'
end