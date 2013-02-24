module Spotlite

  # Represents a movie on IMDb.com
  class Person
    attr_accessor :imdb_id
    
    # Initialize a new movie object by its IMDb ID as a string
    #
    #   movie = Spotlite::Movie.new("0133093")
    #
    # Spotlite::Movie class objects are lazy loading. No HTTP request
    # will be performed upon object initialization. HTTP request will
    # be performed once when you use a method that needs remote data
    # Currently, all data is spead across 5 pages: main movie page,
    # /releaseinfo, /fullcredits, /keywords, and /trivia
    def initialize(imdb_id)
      @imdb_id = imdb_id
      @url     = "http://www.imdb.com/name/nm#{imdb_id}/"
    end
    
    # Returns title as a string
    def title
      @title ||= details.at("h1.header").text.strip rescue nil
    end
    
  end

end
