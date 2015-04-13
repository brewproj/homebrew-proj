class Hbp::ProjectError < RuntimeError; end


class Hbp::CaskInvalidError < Hbp::ProjectError
  attr_reader :token, :submsg
  def initialize(token, *submsg)
    @token = token
    @submsg = submsg.join(' ')
  end

  def to_s
    "Project '#{token}' definition is invalid" + (submsg.length > 0 ? ": #{submsg}" : '')
  end
end