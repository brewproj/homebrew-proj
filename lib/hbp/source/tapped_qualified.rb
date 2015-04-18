require 'hbp/source/tapped'

class Hbp::Source::TappedQualified < Hbp::Source::Tapped
  def self.me?(query)
    !!Hbp::QualifiedToken::parse(query) and path_for_query(query).exist?
  end

  def self.path_for_query(query)
    user, repo, token = Hbp::QualifiedToken::parse(query)
    token.sub!(/\.rb$/i,'')
    tap = "#{user}/homebrew-#{repo}"
    Hbp.homebrew_tapspath.join(tap, 'Projects', "#{token}.rb")
  end
end
