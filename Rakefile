
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
  p.clean_globs = ['test/actual', 'email.txt'] # Remove this directory on "rake clean"
  p.remote_rdoc_dir = '' # Release to root
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  # * extra_deps - An array of rubygem dependencies.
end

desc "Release and publish documentation"
task :repubdoc => [:release, :publish_docs]


desc "Simple require on packaged files to make sure they are all there"
task :verify => :package do
  # An error message will be displayed if files are missing
  if system %(ruby -e "require 'pkg/sparklines-#{Sparklines::VERSION}/lib/sparklines'")
    puts "\nThe library files are present"
  end
end

task :release => :verify
