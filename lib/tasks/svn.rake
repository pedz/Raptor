
namespace :svn do
  desc "Add all unknown files to svn"
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
