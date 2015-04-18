require 'spec_helper'

describe Hbp::Audit do
  describe "result" do
    it "is 'failed' if there are have been any errors added" do
      audit = Hbp::Audit.new(Hbp::Project.new)
      audit.add_error 'bad'
      audit.add_warning 'eh'
      expect(audit.result).to match(/failed/)
    end

    it "is 'warning' if there are no errors, but there are warnings" do
      audit = Hbp::Audit.new(Hbp::Project.new)
      audit.add_warning 'eh'
      expect(audit.result).to match(/warning/)
    end

    it "is 'passed' if there are no errors or warning" do
      audit = Hbp::Audit.new(Hbp::Project.new)
      expect(audit.result).to match(/passed/)
    end
  end

  describe "run!" do
    describe "required fields" do
      it "adds an error if url is missing" do
        audit = Hbp::Audit.new(Hbp.load('missing-url'))
        audit.run!
        expect(audit.errors).to include('a url stanza is required')
      end

      it "adds an error if homepage is missing" do
        audit = Hbp::Audit.new(Hbp.load('missing-homepage'))
        audit.run!
        expect(audit.errors).to include('a homepage stanza is required')
      end

    end

    describe "audit of downloads" do
      it "creates an error if the download fails" do
        error_message = "Download Failed"
        download = double()
        download.expects(:perform).raises(StandardError.new(error_message))

        audit = Hbp::Audit.new(Hbp::Project.new)
        audit.run!(download)
        expect(audit.errors).to include(/#{error_message}/)
      end
    end
  end
end
