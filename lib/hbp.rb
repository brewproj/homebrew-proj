HOMEBREW_CACHE_PROJECTS = HOMEBREW_CACHE.join('Projects')

module Hbp; end

require 'hbp/version'
require 'hbp/locations'
require 'hbp/scopes'
require 'hbp/options'
require 'hbp/utils'
require 'hbp/system_command'
require 'hbp/exceptions'
require 'hbp/project'

require 'vendor/plist'

module Hbp
  include Hbp::Locations
  include Hbp::Scopes
  include Hbp::Options
  include Hbp::Utils

  def self.init
    # todo: Creating directories should be deferred until needed.
    #       Currently this fire and even asks for sudo password
    #       if a first-time user simply runs "brew proj --help".
    odebug 'Creating directories'
    HOMEBREW_CACHE.mkpath unless HOMEBREW_CACHE.exist?
    HOMEBREW_CACHE_PROJECTS.mkpath unless HOMEBREW_CACHE_PROJECTS.exist?
    unless projects_dir.exist?
      ohai "We need to make Project for the first time at #{projects_dir}"
      ohai "We'll set permissions properly so we won't need sudo in the future"
      current_user = Etc.getpwuid(Process.euid).name
      if projects_dir.parent.writable?
        system '/bin/mkdir', '--', projects_dir
      else
        toplevel_dir = projects_dir
        toplevel_dir = toplevel_dir.parent until toplevel_dir.parent.root?
        unless toplevel_dir.directory?
          # If a toplevel dir such as '/opt' must be created, enforce standard permissions.
          # sudo in system is rude.
          system '/usr/bin/sudo', '--', '/bin/mkdir', '--',         toplevel_dir
          system '/usr/bin/sudo', '--', '/bin/chmod', '--', '0775', toplevel_dir
        end
        # sudo in system is rude.
        system '/usr/bin/sudo', '--', '/bin/mkdir', '-p', '--', projects_dir
        unless projects_dir.parent == toplevel_dir
          system '/usr/bin/sudo', '--', '/usr/sbin/chown', '-R', '--', "#{current_user}:staff", projects_dir.parent.to_s
        end
      end
    end
  end

  def self.load(query)
    odebug 'Loading Project definitions'
    proj = Hbp::Source.for_query(query).load
    proj.dumpproject
    proj
  end
end
