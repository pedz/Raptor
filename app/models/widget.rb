# -*- coding: utf-8 -*-

# A widget is a chunk of javascript code that can be added as an
# element into a view.  When the view is rendered, the javascript code
# is called to produce the text as well as the style.  Details of this
# interface will be worked out.
class Widget < ActiveRecord::Base
  ##
  # :attr: id
  # Integer key for the table

  ##
  # :attr: name
  # String name of the widget

  ##
  # :attr: owner_id
  # The id from the users table for the owner of this widget.

  ##
  # :attr: code
  # String javascript code snippet that implements the Widget.

  ##
  # :attr: created_at
  # Rails normal created_at timestamp that is when the db record was
  # created.

  ##
  # :attr: updated_at
  # Rails normal updated_at timestamp.  Each time the db record is
  # saved, this gets updated.

  ##
  # :attr: owner
  # belongs_to association to a User that owns the widget
  belongs_to :owner, :class_name => "User"

  validates_uniqueness_of :name

  # We save a copy of the code from the widget in the
  # public/javascripts/widgets directory as the name of the widget
  # with ".js" appended to it.  e.g. the foo widget will be saved as
  # public/javascripts/widgets/foo.js The view code or the javascript
  # code in the browser can then load the code for the widget and it
  # will be in its own separate file.  The big advantage to this is
  # for debugging, the stack will be the name of the widget with a
  # line number that will be valid and useful.
  def after_save
    File.open(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR + "/widgets/" + name + ".js", "w") do |f|
      f.write("Raptor.widgets.#{name} = #{code}")
    end
  end
end
