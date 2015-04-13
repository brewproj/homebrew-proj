require 'bundler'
require 'bundler/setup'
require 'coveralls'

Coveralls.wear_merged!

# just in case
if RUBY_VERSION.to_i < 2
  raise 'brew-proj: Ruby 2.0 or greater is required.'
end

# force some environment variables
ENV['HOMEBREW_NO_EMOJI']='1'

# add homebrew-proj lib to load path
brew_proj_path = Pathname.new(File.expand_path(__FILE__+'/../../'))
projs_path = brew_proj_path.join('Projects')
lib_path = brew_proj_path.join('lib')
$:.push(lib_path)

# require homebrew testing env
# todo: removeme, this is transitional
require 'vendor/homebrew-fork/testing_env'

# todo temporary, copied from old Homebrew, this method is now moved inside a class
def shutup
  if ENV.has_key?('VERBOSE_TESTS')
    yield
  else
    begin
      tmperr = $stderr.clone
      tmpout = $stdout.clone
      $stderr.reopen '/dev/null', 'w'
      $stdout.reopen '/dev/null', 'w'
      yield
    ensure
      $stderr.reopen tmperr
      $stdout.reopen tmpout
    end
  end
end

# making homebrew's cache dir allows us to actually download Projects in tests
HOMEBREW_CACHE.mkpath
HOMEBREW_CACHE.join('Projects').mkpath

# must be called after testing_env so at_exit hooks are in proper order
require 'minitest/autorun'
# todo, re-enable minitest-colorize, broken under current test environment for unknown reasons
require "minitest/reporters"
if (reporter = ENV['MINITEST_REPORTER']) != nil
  Minitest::Reporters.use! Minitest::Reporters.const_get(reporter + 'Reporter').new
else
  Minitest::Reporters.use!
end
# require 'minitest-colorize'

# Force mocha to patch MiniTest since we have both loaded thanks to homebrew's testing_env
require 'mocha/api'
require 'mocha/integration/mini_test'
Mocha::Integration::MiniTest.activate

# our baby
require 'hbp'

# override Homebrew locations
Hbp.homebrew_prefix = Pathname.new(TEST_TMPDIR).join('prefix')
Hbp.homebrew_repository = Hbp.homebrew_prefix
Hbp.homebrew_tapspath = nil

# Look for Projects in testprojects by default.  It is elsewhere required that
# the string "test" appear in the directory name.
Hbp.default_tap = 'brewproj/homebrew-testprojects'

# our own testy project
Hbp.projects_dir = Hbp.homebrew_prefix.join('TestProject')

class TestHelper
  # helpers for test Projects to reference local files easily
  def self.local_binary_path(name)
    File.expand_path(File.join(File.dirname(__FILE__), 'support', 'binaries', name))
  end

  def self.local_binary_url(name)
    'file://' + local_binary_path(name)
  end

  def self.test_project
    Hbp.load('basic-project')
  end

  def self.fake_fetcher
    Hbp::FakeFetcher
  end

  def self.fake_response_for(*args)
    Hbp::FakeFetcher.fake_response_for(*args)
  end

  def self.must_output(test, lambda, expected)
    out, err = test.capture_subprocess_io do
      lambda.call
    end

    if expected.is_a? Regexp
      (out+err).chomp.must_match expected
    else
      (out+err).chomp.must_equal expected.gsub(/^ */, '')
    end
  end

  def self.valid_alias?(candidate)
    return false unless candidate.symlink?
    candidate.readlink.exist?
  end

  def self.install_without_artifacts(project)
    Hbp::Installer.new(project).tap do |i|
      shutup do
        i.download
        i.extract_primary_container
      end
    end
  end
end

require 'support/fake_fetcher'
require 'support/fake_dirs'
require 'support/fake_system_command'
require 'support/cleanup'
require 'support/never_sudo_system_command'
require 'tmpdir'
require 'tempfile'

# pretend like we installed the homebrew-project tap
project_root = Pathname.new(File.expand_path("#{File.dirname(__FILE__)}/../"))
taps_dest = Hbp.homebrew_prefix.join(*%w{Library Taps project})

# create directories
FileUtils.mkdir_p taps_dest
FileUtils.mkdir_p Hbp.homebrew_prefix.join('bin')

FileUtils.ln_s project_root, taps_dest.join('homebrew-project')

# Common superclass for test Projects for when we need to filter them out
module Hbp
  class TestProject < Project; end
end

# jack in some optional utilities
FileUtils.ln_s '/usr/local/bin/cabextract', Hbp.homebrew_prefix.join('bin/cabextract')
FileUtils.ln_s '/usr/local/bin/unar', Hbp.homebrew_prefix.join('bin/unar')
FileUtils.ln_s '/usr/local/bin/lsar', Hbp.homebrew_prefix.join('bin/lsar')

# also jack in some test Projects
FileUtils.ln_s project_root.join('test', 'support'), taps_dest.join('homebrew-testprojects')
