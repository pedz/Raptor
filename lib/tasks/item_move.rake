# -*- coding: utf-8 -*-

desc "Task to dump items, groups, etc to a file"
task :dump_items do
  puts NameTypes.all.to_json
end
