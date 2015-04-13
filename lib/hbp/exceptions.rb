class Hbp::ProjectError < RuntimeError; end

class Hbp::ProjectNotInstalledError < Hbp::ProjectError
  attr_reader :token
  def initialize(token)
    @token = token
  end

  def to_s
    "#{token} is not installed"
  end
end

class Hbp::ProjectUnavailableError < Hbp::ProjectError
  attr_reader :token
  def initialize(token)
    @token = token
  end

  def to_s
    "No available Project for #{token}"
  end
end

class Hbp::ProjectAlreadyCreatedError < Hbp::ProjectError
  attr_reader :token
  def initialize(token)
    @token = token
  end

  def to_s
    %Q{A Project for #{token} already exists. Run "brew proj cat #{token}" to see it.}
  end
end

class Hbp::ProjectAlreadyInstalledError < Hbp::ProjectError
  attr_reader :token
  def initialize(token)
    @token = token
  end

  def to_s
    %Q{A Project for #{token} is already installed. Add the "--force" option to force re-install.}
  end
end

class Hbp::ProjectCommandFailedError < Hbp::ProjectError
  def initialize(cmd, output, status)
    @cmd = cmd
    @output = output
    @status = status
  end

  def to_s;
    <<-EOS
Command failed to execute!

==> Failed command:
#{@cmd}

==> Output of failed command:
#{@output}

==> Exit status of failed command:
#{@status.inspect}
    EOS
  end
end

class Hbp::ProjectCyclicProjectDependencyError < Hbp::ProjectError
  attr_reader :token
  def initialize(token)
    @token = token
  end

  def to_s
    "Project '#{token}' includes cyclic dependencies on other Projects and could not be installed."
  end
end

class Hbp::ProjectUnspecifiedError < Hbp::ProjectError
  def to_s
    "This command requires a Project token"
  end
end

class Hbp::ProjectInvalidError < Hbp::ProjectError
  attr_reader :token, :submsg
  def initialize(token, *submsg)
    @token = token
    @submsg = submsg.join(' ')
  end

  def to_s
    "Project '#{token}' definition is invalid" + (submsg.length > 0 ? ": #{submsg}" : '')
  end
end

class Hbp::ProjectSha256MissingError < ArgumentError
end

class Hbp::ProjectSha256MismatchError < RuntimeError
  attr_reader :path, :expected, :actual
  def initialize(path, expected, actual)
    @path = path
    @expected = expected
    @actual = actual
  end

  def to_s
    <<-EOS.undent
      sha256 mismatch
      Expected: #{expected}
      Actual: #{actual}
      File: #{path}
      To retry an incomplete download, remove the file above.
      EOS
  end
end
