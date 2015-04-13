module Hbp::Scopes
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def all
      all_tokens.map { |c| self.load c }
    end

    def all_tapped_projects_dirs
      return @all_tapped_projects_dirs unless @all_tapped_projects_dirs.nil?
      fq_default_tap = Hbp.homebrew_tapspath.join(default_tap, 'Projects')
      @all_tapped_projects_dirs = Dir.glob(Hbp.homebrew_tapspath.join('*', '*', 'Projects')).map { |d| Pathname.new(d) }
      # optimization: place the default Tap first
      if @all_tapped_projects_dirs.include? fq_default_tap
        @all_tapped_projects_dirs = @all_tapped_projects_dirs - [ fq_default_tap ]
        @all_tapped_projects_dirs.unshift fq_default_tap
      end
      @all_tapped_projects_dirs
    end

    def reset_all_tapped_projects_dirs
      # The memoized value should be reset when a Tap is added/removed
      # (which is a rare event in our codebase).
      @all_tapped_projects_dirs = nil
    end

    def all_tokens
      project_tokens = all_tapped_projects_dirs.map { |d| Dir.glob d.join('*.rb') }.flatten
      project_tokens.map { |c|
        # => "/usr/local/Library/Taps/projects/example-tap/Projects/example.rb"
        c.sub!(/\.rb$/, '')
        # => ".../example"
        c = c.split('/').last 4
        # => ["projects", "example-tap", "Projects", "example"]
        c.delete_at(-2)
        # => ["example-tap", "example"]
        c = c.join '/'
      }
    end

    def installed
      installed_projects_dirs = Pathname.glob(projects_dir.join("*"))
      # Hbp.load has some DWIM which is slow.  Optimize here
      # by spoon-feeding Hbp.load fully-qualified paths.
      # todo: speed up Hbp::Source::Tapped (main perf drag is calling Hbp.all_tokens repeatedly)
      # todo: ability to specify expected source when calling Hbp.load (minor perf benefit)
      installed_projects_dirs.map do |install_dir|
        project_token = install_dir.basename.to_s
        path_to_project = all_tapped_projects_dirs.find do |tap_dir|
          tap_dir.join("#{project_token}.rb").exist?
        end
        if path_to_project
          Hbp.load(path_to_project.join("#{project_token}.rb"))
        else
          Hbp.load(project_token)
        end
      end
    end
  end
end
