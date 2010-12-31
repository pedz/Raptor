
class AsyncRequest

  include AsyncObserver::Extensions

  def self.perform(job)
    Rails.logger.debug("Bob: #{job.to_yaml}")
  end
  
  def initialize(id, obj)
    Rails.logger.debug("initialize: id = #{id}, obj.class=#{obj.class}, obj.id=#{obj.id}")
    @retuser_id = id
    @obj_class = obj.class
    @obj_id = obj.id
  end

  def rrepr
    "{ retuser_id => #{@retuser_id} }"
  end
end
