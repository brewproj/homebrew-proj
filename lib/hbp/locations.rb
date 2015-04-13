module Hbp::Locations
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def projects_dir
      @@projects_dir ||= Pathname('/opt/homebrew-proj/Projects')
    end

    def projects_dir=(projects_dir)
      @@projects_dir = projects_dir
    end

    def default_tap
      @default_tap ||= 'projects/homebrew-proj'
    end

    def default_tap=(_tap)
      @default_tap = _tap
    end

    def homebrew_executable
      @homebrew_executable ||= Pathname(ENV['HOMEBREW_BREW_FILE'] || Hbc::Utils.which('brew') || '/usr/local/bin/brew')
    end

    def homebrew_prefix
      # where Homebrew links
      @homebrew_prefix ||= homebrew_executable.dirname.parent
    end

    def homebrew_prefix=(arg)
      @homebrew_prefix = arg ? Pathname(arg) : arg
    end

    def homebrew_repository
      # where Homebrew's .git dir is found
      @homebrew_repository ||= homebrew_executable.realpath.dirname.parent
    end

    def homebrew_repository=(arg)
      @homebrew_repository = arg ? Pathname(arg) : arg
    end

    def homebrew_tapspath
      @homebrew_tapspath ||= homebrew_repository.join *%w{Library Taps}
    end

    def homebrew_tapspath=(arg)
      @homebrew_tapspath = arg ? Pathname(arg) : arg
    end
  end
end
