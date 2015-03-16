require 'response/response_handler'


class RequestRouter
  def initialize(request)
    @method = request["method"]
    @credentials = request["credentials"]
    @relative_path = request["uri"].path
    @protected_routes = { "logs" => "/logs"}
    @handler = ResponseHandler.new(request)
  end

  def authenticate_and_route
    if authentication_required?(@relative_path)
      authorized_user? ? route_request : raise_error(401, "You do not have authorization for this resource")
    else
      route_request
    end
  end

    def authorized_user?
      @credentials == "admin:hunter2"
    end

    def authentication_required?(path)
      @protected_routes.values.include?(path)
    end

    def route_request
      case @method
      when "GET"
        @handler.get
      when "HEAD"
        @handler.head
      when "POST"
        @handler.post
      when "PUT"
        @handler.put
      when "OPTIONS"
        @handler.options
      when "DELETE"
        @handler.delete
      else
        raise_error(404, "File not found")
      end
    end
end
