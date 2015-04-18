require 'hbp/source/tapped_qualified'

class Hbp::Source::UntappedQualified < Hbp::Source::TappedQualified
  def self.path_for_query(query)
    user, repo, token = Hbp::QualifiedToken::parse(query)
    token.sub!(/\.rb$/i,'')
    tap = "#{user}/homebrew-#{repo}"
    unless Hbp.homebrew_tapspath.join(tap).exist?
      ohai "Adding new tap '#{tap}'"
      result = Hbp::SystemCommand.run!(Hbp.homebrew_executable,
                                       :args => ['tap', "#{user}/#{repo}"])
              puts result.stdout
      $stderr.puts result.stderr
    end
    Hbp.homebrew_tapspath.join(tap, 'Projects', "#{token}.rb")
  end
end
