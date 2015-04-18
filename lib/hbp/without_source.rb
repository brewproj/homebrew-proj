class Hbp::WithoutSource < Hbp::Project
  def staged_path
    project_path.children.first
  end

  def initialize(sourcefile_path=nil)
    @sourcefile_path = sourcefile_path
    @token = sourcefile_path
  end

  def to_s
    "#{token} (!)"
  end

  def installed?
    project_path.exist?
  end
end
