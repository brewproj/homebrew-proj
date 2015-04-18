require 'hbp/source/path_base'

class Hbp::Source::PathSlashOptional < Hbp::Source::PathBase
  def self.me?(query)
    path = self.path_for_query(query)
    path.exist?
  end
end
