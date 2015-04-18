require 'hbp/checkable'
require 'hbp/download'

class Hbp::Audit
  attr_reader :project

  include Hbp::Checkable

  def initialize(project)
    @project = project
  end

  def run!(download = false)
    _check_required_stanzas
    _check_download(download) if download
    return !(errors? or warnings?)
  end

  def summary_header
    "audit for #{project}"
  end

  def _check_required_stanzas
    odebug "Auditing required stanzas"
    %i{url homepage}.each do |sym|
      add_error "a #{sym} stanza is required" unless project.send(sym)
    end
  end

  def _check_download(download)
    odebug "Auditing download"
    download.perform
  rescue => e
    add_error "download not possible: #{e.message}"
  end

end
