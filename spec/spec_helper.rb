require 'coveralls'
require 'rspec'

Coveralls.wear_merged!

# just in case
if RUBY_VERSION.to_i < 2
  raise 'brew-proj: Ruby 2.0 or greater is required.'
end

project_root = Pathname(File.expand_path("../..", __FILE__))

Dir["#{project_root}/spec/support/*.rb"].each { |f| require f }

include HomebrewTestingEnvironment
# from Homebrew. Provides expects method.
require 'mocha/api'

# add homebrew-proj lib to load path
$:.push(project_root.join('lib').to_s)

require 'hbp'

module Hbp
  class TestProject < Project; end
end

# override Homebrew locations
Hbp.homebrew_prefix = Pathname.new(TEST_TMPDIR).join('prefix')
Hbp.homebrew_repository = Hbp.homebrew_prefix
Hbp.homebrew_tapspath = nil

# making homebrew's cache dir allows us to actually download Projects in tests
HOMEBREW_CACHE.mkpath
HOMEBREW_CACHE.join('Projects').mkpath

# Look for Projects in testprojects by default.  It is elsewhere required that
# the string "test" appear in the directory name.
Hbp.default_tap = project_root.join('spec', 'support')

# our own testy projects_dir
Hbp.projects_dir = Hbp.homebrew_prefix.join('TestProjects')

RSpec.configure do |config|
  config.include ShutupHelper
end
