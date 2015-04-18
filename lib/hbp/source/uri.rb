class Hbp::Source::URI
  def self.me?(query)
    !!(query.to_s =~ URI.regexp)
  end

  attr_reader :uri

  def initialize(uri)
    @uri = uri
  end

  def load
    HOMEBREW_CACHE_PROJECTS.mkpath
    path = HOMEBREW_CACHE_PROJECTS.join(File.basename(uri))
    ohai "Downloading #{uri}"
    odebug "Download target -> #{path.to_s}"
    begin
      curl(uri, '-o', path.to_s)
    rescue Hbp::ErrorDuringExecution
      raise Hbp::ProjectUnavailableError.new uri
    end
    Hbp::Source::PathSlashOptional.new(path).load
  end

  def to_s
    uri.to_s
  end
end
