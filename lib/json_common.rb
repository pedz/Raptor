module JsonCommon
  # Sends the item, which may be an array, as json but also calls
  # async_fetch on either the item or (in the case item is an
  # array) each element of item.
  def json_send(item, cache_options = { }, json_options = { })
    if item.is_a?(Array) || item.is_a?(Combined::AssociationProxy)
      time_stamp = item.map do |c|
        get_time_stamp(c)
      end.max
    else
      time_stamp = get_time_stamp(item)
    end
    
    fresh_when(:last_modified => time_stamp, :etag => get_etag(item))
    unless request.fresh?(response)
      if cache_options.has_key?(:expires_in)
        expires_in(cache_options[:expires_in])
      end
      render :json => item.as_json(json_options)
    end
  end
  
  protected

  # Walks down a general URL and interprets what is being asked for.
  def walk_path
    next_path_element = 0
    # @path_elements = request.env["REQUEST_URI"].sub(/.*\/json\//, '').split('/')
    @path_elements = request.path.sub(/.*\/json\//, '').split('/')
    logger.debug("@path_elements = #{@path_elements}")
    @base_class = nil
    @options = params
    @controller = @options.delete(:controller)
    @action = @options.delete(:action)
    logger.debug(@options)

    # The 1st time, base_class will be nil.  Other times, it may be
    # just a module which indicates that we need to keep scanning
    # forward.
    while @base_class.class != Class && next_path_element < @path_elements.length
      @base_class = ('::' + (@path_elements[0 .. next_path_element].join('/').camelize.singularize)).constantize
      next_path_element += 1
      # A simple /foos call to index
      logger.debug("@base_class = #{@base_class}")
    end
    # Unless we are looking at something that parses as an id, we're
    # done and we send the request (with options) to the base class.
    unless (@path_elements[next_path_element] && @path_elements[next_path_element].match(/^[0-9]+$/))
      if @options.keys.length > 0
        return @base_class.scoped(:conditions => @options)
      else
        return @base_class.all
      end
    end
    
    # Otherwise, we pick up the id and find that element
    @base_element = @base_class.find(@path_elements[next_path_element])
    next_path_element += 1
    logger.debug("@base_element = #{@base_element}")
    # Return this element unless we still have more options.
    return @base_element if @path_elements[next_path_element].nil?
    
    # A has_many under the element e.g. /foos/845/nestings
    @has_many = @base_element.send(@path_elements[next_path_element].to_sym)
    next_path_element += 1
    logger.debug("@has_many = #{@has_many}")
    if @path_elements[next_path_element].nil?
      if @options.keys.length > 0
        return @has_many.scoped(:conditions => @options)
      else
        return @has_many.all
      end
    end
    
    # A specific has_many under the elements
    # e.g. /foos/845/nestings/84 -- I believe this never happens.  If
    # we are really serious about this, we should loop back around
    # since this may be keep going.
    return @has_many.find(@path_elements[next_path_element])
  end

  private
  
  def get_time_stamp(c)
    # if c.respond_to?(:last_fetched)
    #   c.last_fetched
    # else
    logger.debug("class is #{c.class}")
    c.updated_at
    # end
  end
  
  def get_etag(item)
    case
    when item.is_a?(Array)
      item.map { |i| get_etag(i) }
    when item.respond_to?(:etag)
      item.etag
    else
      item
    end
  end
end
