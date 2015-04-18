class Hbp::Source::Tapped
  def self.me?(query)
    path_for_query(query).exist?
  end

  def self.path_for_query(query)
    # Repeating Hbp.all_tokens is very slow for operations such as
    # brew proj list, but memoizing the value might cause breakage
    # elsewhere, given that installation and tap status is permitted
    # to change during the course of an invocation.
    token_with_tap = Hbp.all_tokens.find { |t| t.split('/').last == query.sub(/\.rb$/i,'') }
    if token_with_tap
      user, repo, token = token_with_tap.split('/')
      Hbp.homebrew_tapspath.join(user, repo, 'Projects', "#{token}.rb")
    else
      Hbp.homebrew_tapspath.join(Hbp.default_tap, 'Projects', "#{query.sub(/\.rb$/i,'')}.rb")
    end
  end

  attr_reader :token

  def initialize(token)
    @token = token
  end

  def load
    path = self.class.path_for_query(token)
    Hbp::Source::PathSlashOptional.new(path).load
  end

  def to_s
    # stringify to fully-resolved location
    self.class.path_for_query(token).expand_path.to_s
  end
end
