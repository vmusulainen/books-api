require 'json'
require 'json'
require 'sequel'

$db = Sequel.amalgalite
$db.create_table :books do
  primary_key :id
  String :title
  String :author
end

(1..1000).each { |each|
  $db[:books].insert([:title, :author], ["title-#{each}", "author-#{each}"])
}


class Controller
  def self.index
    return [200, $db.from(:books).all.to_json]
  end

  def self.create params
    #book = BOOK_DB<< Book.new(params[:title], params[:author])
    puts "params #{params}"
    id = $db[:books].insert([:title, :author], [params['title'], params['author']])
    book = $db.from(:books).first(id: id)
    [201, book.to_json]
  end

  def self.show id
    book =  $db.from(:books).first(id: id)
    if book
      [200, book.to_json]
    else
      [404, {message: "No Such Book!"}.to_json]
    end
  end

  def self.update id, params
    updated_book =  $db.from(:books).first(id: id)
    updated_book = BOOK_DB.update(id.to_s, {title: params[:title], author: params[:author]})
    unless updated_book.nil?
      [200, updated_book.to_h.to_json]
    else
      [404, {message: "No Such Book!"}.to_json]
    end
  end

  def self.delete id
    BOOK_DB.delete id
    [200, {message: "The book has been deleted!"}.to_json]
  end

end