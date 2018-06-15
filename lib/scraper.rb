require 'nokogiri'
require 'open-uri'
require 'pry'

class Scraper
  attr_accessor :path

  def initialize(path = "https://en.wikipedia.org/wiki/Category:Surrealist_artists")
    @path = path
  end

  def find_artists
    doc = Nokogiri::HTML(open(@path))
    artists = doc.css('.mw-category li')
    artist_array = []
    artists.each do |artist|
      name = artist.text
      url = artist.css("[href]")[0].values
      if !(url[0].to_s.include?("CategoryTreeLabel"))
        artist_array.push({:name => name, :url => "https://en.wikipedia.org".concat((url[0].to_s))})
        # puts "#{name} #{"https://en.wikipedia.org".concat((url[0].to_s))}"
      end
    end
    artist_array
  end

  def add_info_to_artist(artist_hash)
    artist_hash.each do |artist|
    artist_url = artist[:url]
    doc = Nokogiri::HTML(open(artist_url))

    bio = doc.css('p').text
    artist[:biography] = bio

    birth_info_text = doc.css('tr')
    birth_info_text.each do |node|
      if node.text.include?("Born")
        text_node = node.text
        text_node = text_node.split(/\n/)
        artist[:birth_info] = text_node[2]
      end
      if node.text.include?("Known")
        text_node = node.text
        text_node = text_node.split(/\n/)
        artist[:known_for] = text_node[2]
      end

    end
    end
    artist_hash
  end
end

class Artist
  attr_accessor :name, :url, :biography, :birth_info, :known_for

  @@all = []

  def initialize(attributes)
    attributes.each do|key, value|
      self.send(("#{key}="), value)
    end

    @@all << self
  end

  def self.all
    @@all
  end
end

# class Genre
#   attr_accessor :name, :artist
# 
#   @@all = []
# 
#   def initialize(name)
#     @name = name
#     if @@all.find {|g| g.name == name}
#       new_genre = @@all.find {|g| g.name == name}
#       @@all << new_genre
#     end
#   end
# 
#   def self.all
#     @@all
#   end
# end

class CommandLineInterface

  def initialize
    scraper = Scraper.new
    artist_list = scraper.find_artists
    artists = scraper.add_info_to_artist(artist_list)

    artists.each do |artist|
      Artist.new(artist)
    end
  end

  def play
    input = 1
    while input.between?(1, Artist.all.length)
      puts "Enter a number between 1 and #{Artist.all.length} to learn about an artist"
      input = gets.strip.to_i
      artist = Artist.all[input-1]
      puts ''
      puts "Name: #{artist.name}" unless !artist.name
      puts "Biography: #{artist.biography}" unless !artist.biography
      puts "Born: #{artist.birth_info}" unless !artist.birth_info
      puts "Known for: #{artist.known_for}" unless !artist.known_for
    end
  end
end

cli = CommandLineInterface.new
cli.play

# performance_art = Genre.new("Performance art")
