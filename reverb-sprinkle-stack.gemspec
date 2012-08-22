Gem::Specification.new do |s|
  s.name          = "reverb-sprinkle-stack"
  s.version       = "1.0.1"
  s.platform      = Gem::Platform::RUBY
  s.homepage      = "http://github.com/reverbhq/reverb-sprinkle-stack"
  s.authors       = ["Greg Bell", "REVERB"]
  s.email         = ["greg.bell@reverbhq.com"]
  s.description   = "A collection of Sprinkle packages"
  s.summary       = "A collection of Sprinkle packages"

  s.files         = `git ls-files`.split("\n").sort
  s.require_paths = ["lib"]

  s.add_dependency("sprinkle")

end
