# vim: set ft=ruby

guard :rspec, :cmd => 'bundle exec rspec' do
  watch(%r{^spec/(.*)\/?(.*)_spec\.rb$})
  watch(%r{^lib/hbp/(.*/)?([^/]+)\.rb$}) do |m|
    "test/proj/#{m[1]}#{m[2]}_spec.rb"
  end
  watch(%r{^spec/spec_helper\.rb$})      { 'spec' }
end

guard :minitest do
  watch(%r{^test/(.*)\/?test_(.*)\.rb$})
  watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { |m| "test/#{m[1]}#{m[2]}_test.rb" }
  watch(%r{^test/test_helper\.rb$})      { 'test' }
end

guard :rubocop do
  watch(%r{.+\.rb$})
  watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
end
