module Combined
  class FavoriteQueue < Base
    set_expire_time :never

    def to_xml(options = {})
      options[:indent] ||= 2
      root = options[:root] || self.class.name.underscore
      xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
      xml.instruct! unless options[:skip_instruct]
      xml.tag! root do
        xml.tag!(:queue, queue.to_param)
        xml.tag!(:team, queue.owners.empty?)
        xml.tag!(:hits, queue.hits)
      end
    end

    def to_json(options = {})
      "{ queue: \"#{queue.to_param}\", team: #{queue.owners.empty?}, hits: #{queue.hits} }"
    end

    def to_param
      @cached.id.to_s
    end
    
    # Need to define this even though it doesn't do anything
    def load
    end
  end
end
