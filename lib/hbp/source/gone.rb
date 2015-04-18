class Hbp::Source::Gone
  def self.me?(query)
    Hbp::WithoutSource.new(query).installed?
  end

  attr_reader :query

  def initialize(query)
    @query = query
  end

  def load
    Hbp::WithoutSource.new(query)
  end

  def to_s
    ''
  end
end
