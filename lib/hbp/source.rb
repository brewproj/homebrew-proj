module Hbp::Source; end

require 'hbp/source/gone'
require 'hbp/source/path_slash_required'
require 'hbp/source/path_slash_optional'
require 'hbp/source/tapped_qualified'
require 'hbp/source/untapped_qualified'
require 'hbp/source/tapped'
require 'hbp/source/uri'

module Hbp::Source
  def self.sources
    [
      Hbp::Source::URI,
      Hbp::Source::PathSlashRequired,
      Hbp::Source::TappedQualified,
      Hbp::Source::UntappedQualified,
      Hbp::Source::Tapped,
      Hbp::Source::PathSlashOptional,
      Hbp::Source::Gone,
    ]
  end

  def self.for_query(query)
    odebug "Translating '#{query}' into a valid Project source"
    source = sources.find do |s|
      odebug "Testing source class #{s}"
      s.me?(query)
    end
    raise Hbp::ProjectUnavailableError.new(query) unless source
    odebug "Success! Using source class #{source}"
    resolved_project_source = source.new(query)
    odebug "Resolved Project URI or file source to '#{resolved_project_source}'"
    resolved_project_source
  end
end
