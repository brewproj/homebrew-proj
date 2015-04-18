class Hbp::Download
  attr_reader :project

  def initialize(project)
    @project = project
  end

  def perform(force=false)
    download_strategy = Hbp::DownloadStrategyDetector.detect(project.url.to_s, project.url.using)
    downloader.clear_cache if force
    begin
      downloaded_path = downloader.fetch
    rescue StandardError => e
      raise Hbp::ProjectError.new("Download failed on project '#{project}' with message: #{e}")
    end
    begin
      # this symlink helps track which downloads are ours
      File.symlink downloaded_path,
                   HOMEBREW_CACHE_PROJECTS.join(downloaded_path.basename)
    rescue StandardError => e
    end
    downloaded_path
  end
end
