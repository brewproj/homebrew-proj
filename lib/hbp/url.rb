require 'forwardable'

class Hbp::URL

  attr_reader :using, :branch, :uri

  extend Forwardable
  def_delegators :uri, :path, :scheme, :to_s

  def initialize(uri, options={})
    if m = uri.match(%r{([^/]+)/([^/]+)(?:#(.+))?})
      options[:branch] = m[2]
      uri = "git://github.com/#{uri}"
    end
    @uri        = URI.parse(uri)
    @using      = options[:using]
    @revision   = options[:revision]
  end

  def to_s
    uri.to_s
  end

end
