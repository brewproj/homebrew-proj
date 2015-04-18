require 'hbp/source/path_base'

class Hbp::Source::PathSlashRequired < Hbp::Source::PathBase
  def self.me?(query)
    path = self.path_for_query(query)
    path.to_s.include?('/') and path.exist?
  end
end
