module Spotlite

  # Represents a movie on IMDb.com
  class Movie
    attr_accessor :imdb_id, :title, :year
    
    # Initialize a new movie object by its IMDb ID as a string
    #
    #   movie = Spotlite::Movie.new("0133093")
    #
    # Spotlite::Movie class objects are lazy loading. No HTTP request
    # will be performed upon object initialization. HTTP request will
    # be performed once when you use a method that needs remote data
    # Currently, all data is spead across 5 pages: main movie page,
    # /releaseinfo, /fullcredits, /keywords, and /trivia
    def initialize(imdb_id, title = nil, year = nil)
      @imdb_id = imdb_id
      @title   = title
      @year    = year
      @url     = "http://www.imdb.com/title/tt#{imdb_id}/"
    end
    
    # Returns title as a string
    def title
      @title ||= details.at("h1.header span.itemprop").text.strip rescue nil
    end
    
    # Returns original non-english title as a string
    def original_title
      details.at("h1.header span.title-extra").text.strip rescue nil
    end
    
    # Returns year of original release as an integer
    def year
      @year ||= details.at("h1.header a[href^='/year/']").text.parse_year rescue nil
    end
    
    # Returns IMDb rating as a float
    def rating
      details.at("div.star-box-details span[itemprop='ratingValue']").text.to_f rescue nil
    end
    
    # Returns number of votes as an integer
    def votes
      details.at("div.star-box-details span[itemprop='ratingCount']").text.gsub(/[^\d+]/, "").to_i rescue nil
    end
    
    # Returns short description as a string
    def description
      details.at("p[itemprop='description']").children.first.text.strip rescue nil
    end
    
    # Returns a list of genres as an array of strings
    def genres
      details.css("div.infobar a[href^='/genre/']").map { |genre| genre.text } rescue []
    end
    
    # Returns a list of countries as an array of hashes
    # with keys: +code+ (string) and +name+ (string)
    def countries
      array = []
      details.css("div.txt-block a[href^='/country/']").each do |node|
        array << {:code => node["href"].clean_href, :name => node.text.strip}
      end
      
      array
    end
    
    # Returns a list of languages as an array of hashes
    # with keys: +code+ (string) and +name+ (string)
    def languages
      array = []
      details.css("div.txt-block a[href^='/language/']").each do |node|
        array << {:code => node["href"].clean_href, :name => node.text.strip}
      end
      
      array
    end
    
    # Returns runtime (length) in minutes as an integer
    def runtime
      details.at("time[itemprop='duration']").text.to_i rescue nil ||
      details.at("#overview-top .infobar").text.strip[/\d{2,3} min/].to_i rescue nil
    end
    
    # Returns primary poster URL as a string
    def poster_url
      src = details.at("#img_primary img")["src"] rescue nil
      
      if src =~ /^(http:.+@@)/ || src =~ /^(http:.+?)\.[^\/]+$/
        $1 + ".jpg"
      end
    end
    
    # Returns a list of keywords as an array of strings
    def keywords
      plot_keywords.css("li b.keyword").map { |keyword| keyword.text.strip } rescue []
    end
    
    # Returns a list of trivia facts as an array of strings
    def trivia
      movie_trivia.css("div.sodatext").map { |node| node.text.strip } rescue []
    end
    
    # Returns a list of directors as an array of hashes
    # with keys: +imdb_id+ (string) and +name+ (string)
    def directors
      names = full_credits.at("a[name='directors']").parent.parent.parent.parent.css("a[href^='/name/nm']").map { |node| node.text } rescue []
      links = full_credits.at("a[name='directors']").parent.parent.parent.parent.css("a[href^='/name/nm']").map { |node| node["href"] } rescue []
      imdb_ids = links.map { |link| link.parse_imdb_id } unless links.empty?
      
      array = []
      0.upto(names.size - 1) do |i|
        array << {:imdb_id => imdb_ids[i], :name => names[i]}
      end
      
      array
    end
    
    # Returns a list of writers as an array of hashes
    # with keys: +imdb_id+ (string) and +name+ (string)
    def writers
      names = full_credits.at("a[name='writers']").parent.parent.parent.parent.css("a[href^='/name/nm']").map { |node| node.text } rescue []
      links = full_credits.at("a[name='writers']").parent.parent.parent.parent.css("a[href^='/name/nm']").map { |node| node["href"] } rescue []
      imdb_ids = links.map { |link| link.parse_imdb_id } unless links.empty?
      
      array = []
      0.upto(names.size - 1) do |i|
        array << {:imdb_id => imdb_ids[i], :name => names[i]}
      end
      
      array
    end
    
    # Returns a list of producers as an array of hashes
    # with keys: +imdb_id+ (string) and +name+ (string)
    def producers
      names = full_credits.at("a[name='producers']").parent.parent.parent.parent.css("a[href^='/name/nm']").map { |node| node.text } rescue []
      links = full_credits.at("a[name='producers']").parent.parent.parent.parent.css("a[href^='/name/nm']").map { |node| node["href"] } rescue []
      imdb_ids = links.map { |link| link.parse_imdb_id } unless links.empty?
      
      array = []
      0.upto(names.size - 1) do |i|
        array << {:imdb_id => imdb_ids[i], :name => names[i]}
      end
      
      array
    end
    
    # Returns a list of actors as an array of hashes
    # with keys: +imdb_id+ (string), +name+ (string), and +character+ (string)
    def cast
      table = full_credits.css("table.cast")
      names = table.css("td.nm").map { |node| node.text } rescue []
      links = table.css("td.nm a").map { |node| node["href"] } rescue []
      imdb_ids = links.map { |link| link.parse_imdb_id } unless links.empty?
      characters = table.css("td.char").map { |node| node.text }
      
      array = []
      0.upto(names.size - 1) do |i|
        array << {:imdb_id => imdb_ids[i], :name => names[i], :character => characters[i]}
      end
      
      array
    end
    
    # Returns a list of regions and corresponding release dates
    # as an array of hashes with keys:
    # region +code+ (string), +region+ name (string), and +date+ (date)
    # If day is unknown, 1st day of month is assigned
    # If day and month are unknown, 1st of January is assigned
    def release_dates
      table = release_info.at("a[href^='/calendar/?region']").parent.parent.parent.parent rescue nil
      regions = table.css("b a[href^='/calendar/?region']").map { |node| node.text } rescue []
      links = table.css("b a[href^='/calendar/?region']").map { |node| node["href"] } rescue []
      codes = links.map { |link| link.split("=").last.downcase } unless links.empty?
      dates = table.css("td[align='right']").map { |node| node.text.strip }
      
      array = []
      0.upto(regions.size - 1) do |i|
        array << {:code => codes[i], :region => regions[i], :date => dates[i].parse_date}
      end
      
      array
    end
    
    private
    
    def details # :nodoc:
      @details ||= open_page
    end
    
    def release_info # :nodoc:
      @release_info ||= open_page("releaseinfo")
    end
    
    def full_credits # :nodoc:
      @full_credits ||= open_page("fullcredits")
    end
    
    def plot_keywords # :nodoc:
      @plot_keywords ||= open_page("keywords")
    end
    
    def movie_trivia # :nodoc:
      @movie_trivia ||= open_page("trivia")
    end
    
    def open_page(page = nil) # :nodoc:
      Nokogiri::HTML(open("http://www.imdb.com/title/tt#{@imdb_id}/#{page}",
                          "Accept-Language" => "en-us"))
    end
  end

end
