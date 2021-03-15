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

class BadRequestError < StandardError; end;

class BookServer < WEBrick::HTTPServlet::AbstractServlet
  def do_GET request, response
    status, body = nil, nil
    if request.path_info.empty? then
      status, body = Controller.index
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
      status, body = nil, nil
      if request.path_info.empty? then
        status, body = Controller.create post_data
      else
        id = request.path_info.gsub('/', '').gsub('delete', '')
        if request.path_info.match /delete/
          status, body = Controller.delete id
        else
          status, body = Controller.update id, post_data
        end
      end
      response.status = status
      response['Content-Type'] = "application/json"
      response.body = body
    rescue BadRequestError => e
      response.status = 400
      response.body   = {message: "Please add correct url-encoded form data fields"}.to_json
    end
  end

  private

  def parse_post_data request_body
    raise BadRequestError if request_body.nil?
    JSON.parse(request_body)
  end
end

server = WEBrick::HTTPServer.new Port: 4000

server.mount '/books', BookServer

trap("INT"){ server.shutdown }

server.start