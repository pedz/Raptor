# -*- coding: utf-8 -*-

module Json
  class GeneralController < JsonController
    def index
      begin
        json_send(walk_path)
      rescue Exception => e
        logger.error("URL Error: #{request.env["REQUEST_URI"]}")
        logger.debug(e.message)
        logger.debug(e.backtrace.join("\n"))
        render :json => 'Not Found', :status => 404
      end
    end

    def show
      begin
        json_send(walk_path)
      rescue Exception => e
        logger.error("URL Error: #{request.env["REQUEST_URI"]}")
        logger.debug(e.message)
        logger.debug(e.backtrace.join("\n"))
        render :json => 'Not Found', :status => 404
      end
    end

    private

    def walk_path
      @path_elements = request.env["REQUEST_URI"].sub(/.*\/json\//, '').split('/')
      logger.debug("@path_elements = #{@path_elements}")
      @base_class = ('::' + (@path_elements[0].singularize.camelize)).constantize
      # A simple /foos call to index
      logger.debug("@base_class = #{@base_class}")
      return @base_class.all unless @path_elements[1].match(/^[0-9]+$/)

      # A simple /foos/845 call to show
      @base_element = @base_class.find(@path_elements[1])
      logger.debug("@base_element = #{@base_element}")
      return @base_element if @path_elements[2].nil?

      # A has_many under the element e.g. /foos/845/nestings
      @has_many = @base_element.send(@path_elements[2].to_sym)
      logger.debug("@has_many = #{@has_many}")
      return @has_many if @path_elements[3].nil?

      # A specific has_many under the elements e.g. /foos/845/nestings/84
      return @has_many.find(@path_elements[3])
    end
  end
end
