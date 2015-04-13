module Hbp::CleanupHooks
  def after_teardown
    super
  end
end

class MiniTest::Spec
  include Hbp::CleanupHooks
end
