require 'set'

module Hbp::DSL; end


module Hbp::DSL
  def self.included(base)
    base.extend(ClassMethods)
  end

  def full_name; self.class.full_name; end

  def homepage; self.class.homepage; end

  def url; self.class.url; end

  def depends_on; self.class.depends_on; end

  def conflicts_with; self.class.conflicts_with; end

  module ClassMethods

    # A quite fragile shim to allow "full_name" be exposed as simply "name"
    # in the DSL.  We detect the difference with the already-existing "name"
    # method by arity, and use "full_name" exclusively in backend code.
    def name(*args)
      if args.empty?
        super
      else
        self.full_name(args)
      end
    end

    def full_name(_full_name=nil)
      @full_name ||= []
      if _full_name
        @full_name.concat(Array(*_full_name))
      end
      @full_name
    end

    def homepage(homepage=nil)
      if @homepage and !homepage.nil?
        raise Hbp::ProjectInvalidError.new(self.token, "'homepage' stanza may only appear once")
      end
      @homepage ||= homepage
    end

    def url(*args)
      return @url if args.empty?
      if @url and !args.empty?
        raise Hbp::ProjectInvalidError.new(self.token, "'url' stanza may only appear once")
      end
      @url ||= begin
        Hbp::URL.new(*args)
      rescue StandardError => e
        raise Hbp::ProjectInvalidError.new(self.token, "'url' stanza failed with: #{e}")
      end
    end

    # depends_on uses a load method so that multiple stanzas can be merged
    def depends_on(*args)
      return @depends_on if args.empty?
      @depends_on ||= Hbp::DSL::DependsOn.new()
      begin
        @depends_on.load(*args) unless args.empty?
      rescue RuntimeError => e
        raise Hbp::ProjectInvalidError.new(self.token, e)
      end
      @depends_on
    end

    def method_missing(method, *args)
      Hbp::Utils.method_missing_message(method, self.token)
      return nil
    end
  end
end
