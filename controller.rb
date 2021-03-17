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
  def self.index params
    # sort by id by default
    # param :page
    # param :per_page
    puts params
    per_page = params[:per_page].to_i
    page = params[:page].to_i
    offset = (page - 1) * per_page
    items = $db.from(:books).order(:id).limit(per_page, offset).all
    total_item_count = $db.from(:books).count
    page_count = (total_item_count.to_f / per_page).ceil
    json = {items: items, page: page, per_page: per_page, page_count: page_count, total_item_count: total_item_count}.to_json
    return [200, json]
  end

  def self.create params
    id = $db[:books].insert([:title, :author], [params[:title], params[:author]])
    book = $db.from(:books).first(id: id)
    [201, book.to_json]
  end

  def self.show id
    book = $db.from(:books).first(id: id)
    if book
      [200, book.to_json]
    else
      [404, { message: "No Such Book!" }.to_json]
    end
  end

  def self.update id, params
    $db.from(:books).where(id: id).update({ title: params[:title], author: params[:author] })
    [200, { message: "The book has been updated!" }.to_json]
  end

  def self.delete id
    $db.from(:books).where(id: id).delete
    [200, { message: "The book has been deleted!" }.to_json]
  end

end