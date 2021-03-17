require 'webrick'
require_relative './controller'

db = Sequel.amalgalite
db.create_table :items do
  primary_key :id
  String :title
  String :content
end

(1..1000).each { |each|
  db[:items].insert([:title, :content], ["my-title-#{each}", "my-content-#{each}"])
}

class BadRequestError < StandardError; end

;

class BookServer < WEBrick::HTTPServlet::AbstractServlet
  def do_GET request, response
    status, body = nil, nil
    if request.path_info.empty? then
      params = request.query.transform_keys(&:to_sym)
      status, body = Controller.index params
    else
      id = request.path_info.gsub('/', '')
      status, body = Controller.show id
    end
    response.status = status
    response['Content-Type'] = "application/json"
    response.body = body
  end

  def do_POST request, response
    begin
      post_data = parse_post_data request.body
      status, body = Controller.create post_data
      response.status = status
      response['Content-Type'] = "application/json"
      response.body = body
    rescue BadRequestError => e
      response.status = 400
      response.body = { message: "Please add correct url-encoded form data fields" }.to_json
    end
  end

  def do_DELETE request, response
    id = request.path_info.gsub('/', '')
    status, body = Controller.delete id
    response.status = status
    response['Content-Type'] = "application/json"
    response.body = body
  end

  def do_PUT request, response
    id = request.path_info.gsub('/', '')
    post_data = parse_post_data request.body
    id = request.path_info.gsub('/', '')
    status, body = Controller.update id, post_data
    response.status = status
    response['Content-Type'] = "application/json"
    response.body = body
  end

  private

  def parse_post_data request_body
    raise BadRequestError if request_body.nil?
    JSON.parse(request_body).transform_keys(&:to_sym)
  end
end

server = WEBrick::HTTPServer.new Port: 4000

server.mount '/books', BookServer

trap("INT") { server.shutdown }

server.start