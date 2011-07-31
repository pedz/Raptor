module Json
  class GeneralController < JsonController
    def index
      begin
        json_send(klass.all)
      rescue Exception => e
        logger.error("URL Error: #{request.env["REQUEST_URI"]}")
        logger.debug(e.message)
        logger.debug(e.backtrace.join("\n"))
        render :json => 'Not Found', :status => 404
      end
    end

    def show
      begin
        json_send(klass.find(params[:id]))
      rescue Exception => e
        logger.error("URL Error: #{request.env["REQUEST_URI"]}")
        logger.debug(e.message)
        logger.debug(e.backtrace.join("\n"))
        render :json => 'Not Found', :status => 404
      end
    end

    private

    def klass
      env = request.env
      logger.debug("env[\"REQUEST_URI\"] = #{env["REQUEST_URI"]}")
      temp = env["REQUEST_URI"].sub(/.*\/json\//, '').sub(/\/.*/, '')
      logger.debug("temp = #{temp}")
      temp = ('::' + (temp.singularize.camelize))
      logger.debug("temp = #{temp}")
      temp.constantize
    end
  end
end
