
require 'rubygems'
require 'hoe'
$:.unshift(File.dirname(__FILE__) + "/lib")
require 'sparklines'

Hoe.new('Sparklines', Sparklines::VERSION) do |p|
  p.name = "sparklines"
  p.author = "Geoffrey Grosenbach"
  p.description = "Tiny graphs."
  p.email = 'boss@topfunky.com'
  p.summary = "Tiny graphs."
  p.url = "http://nubyonrails.com/pages/sparklines"
  p.clean_globs = ['test/actual'] # Remove this directory on "rake clean"
  p.remote_rdoc_dir = '' # Release to root
  p.changes = p.paragraphs_of('CHANGELOG', 0..1).join("\n\n")
  # * extra_deps - An array of rubygem dependencies.
end


desc "Release and publish documentation"
task :repubdoc => [:release, :publish_docs]
