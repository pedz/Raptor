# -*- coding: utf-8 -*-
#
# At start up, we need to make sure that a copy of the code of each
# widget is in the javascript/widgets directory.  It might be much
# better to have a controller with views and use page caching.  But
# that is fairly complex as well.
#
Widget.find(:all).each do |widget|
  name = ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR + "/widgets/" + widget.name + ".js"
  need_file = false
  begin
    stat = File::Stat.new(name)
    need_file = (widget.updated_at > stat.mtime)
    Rails.logger.debug stat.mtime
    Rails.logger.debug widget.updated_at
    Rails.logger.debug (widget.updated_at > stat.mtime).to_s
  rescue
    need_file = true
  end
  if need_file
    File.open(name, "w") do |f|
      f.write("Raptor.widgets.#{widget.name} = #{widget.code}")
    end
  end
end
