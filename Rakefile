# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

namespace :svn do
  task :add_all do
    require 'tempfile'
    
    tf = Tempfile.new("svn-rake")
    tf.open
    IO.popen("svn status") { |f| f.readlines }.grep(/^\?/).map do |line|
      tf.write(line.gsub(/^......./, ''))
    end
    tf.close
    sh("svn add --targets #{tf.path}")
  end
end
