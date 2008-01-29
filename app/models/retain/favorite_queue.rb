module Retain
  class FavoriteQueue < ActiveRecord::Base
    belongs_to :user
    belongs_to :queue, :class_name => "Cached::Queue"
  end
end
