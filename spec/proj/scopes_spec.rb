require 'spec_helper'

describe Hbp::Scopes do
  describe 'installed' do
    let(:fake_projects_dir) { Pathname(Dir.mktmpdir) }

    before do
      allow(Hbp).to receive(:projects_dir) { fake_projects_dir }
    end
    after { fake_projects_dir.rmtree }

    it 'returns a list installed Casks by loading Casks for all the dirs that exist in the caskroom' do
      allow(Hbp).to receive(:load) { |token| "loaded-#{token}" }

      fake_projects_dir.join('proj-bar').mkdir
      fake_projects_dir.join('proj-foo').mkdir

      installed_projects = Hbp.installed

      expect(Hbp).to have_received(:load).with('proj-bar')
      expect(Hbp).to have_received(:load).with('proj-foo')
      expect(installed_projects).to eq(%w[
        loaded-proj-bar
        loaded-proj-foo
      ])
    end

    it 'optimizes performance by resolving to a fully qualified path before calling Hbp.load' do
      fake_tapped_projects_dir = Pathname(Dir.mktmpdir).join('Casks')
      absolute_path_to_project = fake_tapped_projects_dir.join('some-proj.rb')

      allow(Hbp).to receive(:load)
      allow(Hbp).to receive(:all_tapped_projects_dirs) { [fake_tapped_projects_dir] }

      fake_projects_dir.join('some-proj').mkdir
      fake_tapped_projects_dir.mkdir
      FileUtils.touch(absolute_path_to_project)

      Hbp.installed

      expect(Hbp).to have_received(:load).with(absolute_path_to_project)
    end

  end

end
