require 'spec_helper'

describe "Spotlite::Movie" do
  
  describe "valid movie" do
    
    before(:each) do
      # The Matrix (1999)
      @movie = Spotlite::Movie.new("0133093")
    end
    
    it "should return title" do
      @movie.title.should eql("The Matrix")
    end
    
    describe "original title" do
      it "should return original title if it exists" do
        # City of God (2002)
        @movie = Spotlite::Movie.new("0317248")
        @movie.original_title.should eql("Cidade de Deus")
      end
      
      it "should return nil if it doesn't exist" do
        @movie.original_title.should be_nil
      end
    end
    
    it "should return original release year" do
      @movie.year.should eql(1999)
    end
    
    it "should return IMDb rating" do
      @movie.rating.should eql(8.7)
    end
    
    it "should return number of votes" do
      @movie.votes.should be_within(50000).of(700000)
    end
    
    it "should return description" do
      @movie.description.should match(/A computer hacker learns from mysterious rebels about the true nature of his reality and his role in the war against its controllers./)
    end
    
    it "should return genres" do
      @movie.genres.should be_an(Array)
      @movie.genres.size.should eql(3)
      @movie.genres.should include("Action")
      @movie.genres.should include("Adventure")
      @movie.genres.should include("Sci-Fi")
    end
    
    it "should return countries" do
      @movie.countries.should be_an(Array)
      @movie.countries.size.should eql(2)
      @movie.countries.should include({:code => "us", :name => "USA"})
      @movie.countries.should include({:code => "au", :name => "Australia"})
    end
    
    it "should return languages" do
      @movie.languages.should be_an(Array)
      @movie.languages.size.should eql(1)
      @movie.languages.should include({:code => "en", :name => "English"})
    end
    
    it "should return runtime in minutes" do
      @movie.runtime.should eql(136)
    end
    
    describe "poster URL" do
      it "should return old style poster URL" do
        @movie.poster_url.should eql("http://ia.media-imdb.com/images/M/MV5BMjEzNjg1NTg2NV5BMl5BanBnXkFtZTYwNjY3MzQ5.jpg")
      end
      
      it "should return new style poster URL" do
        # American Beauty (1999)
        @movie = Spotlite::Movie.new("0169547")
        @movie.poster_url.should eql("http://ia.media-imdb.com/images/M/MV5BOTU1MzExMDg3N15BMl5BanBnXkFtZTcwODExNDg3OA@@.jpg")
      end
      
      it "should return nil if poster doesn't exist" do
        # The Flying Circus (1912)
        @movie = Spotlite::Movie.new("0002186")
        @movie.poster_url.should be_nil
      end
    end
    
    it "should return plot keywords" do
      @movie.keywords.should be_an(Array)
      @movie.keywords.size.should be_within(50).of(250)
      @movie.keywords.should include("Computer")
      @movie.keywords.should include("Artificial Reality")
      @movie.keywords.should include("Hand To Hand Combat")
      @movie.keywords.should include("White Rabbit")
      @movie.keywords.should include("Chosen One")
    end
    
    it "should return trivia" do
      @movie.trivia.should be_an(Array)
      @movie.trivia.size.should be_within(10).of(100)
      @movie.trivia.should include("Nicolas Cage turned down the part of Neo because of family commitments. Other actors considered for the role included Tom Cruise and Leonardo DiCaprio.")
      @movie.trivia.should include("Carrie-Anne Moss twisted her ankle while shooting one of her scenes but decided not to tell anyone until after filming, so they wouldn't re-cast her.")
      @movie.trivia.should include("Gary Oldman was considered as Morpheus at one point, as well as Samuel L. Jackson.")
    end
    
    it "should return directors" do
      @movie.directors.should be_an(Array)
      @movie.directors.size.should eql(2)
      @movie.directors.should include({:imdb_id => "0905152", :name => "Andy Wachowski"})
      @movie.directors.should include({:imdb_id => "0905154", :name => "Lana Wachowski"})
    end
    
    it "should return writers" do
      @movie.writers.should be_an(Array)
      @movie.writers.size.should eql(2)
      @movie.writers.should include({:imdb_id => "0905152", :name => "Andy Wachowski"})
      @movie.writers.should include({:imdb_id => "0905154", :name => "Lana Wachowski"})
    end
    
    it "should return producers" do
      @movie.producers.should be_an(Array)
      @movie.producers.size.should eql(10)
      @movie.producers.should include({:imdb_id => "0075732", :name => "Bruce Berman"})
      @movie.producers.should include({:imdb_id => "0185621", :name => "Dan Cracchiolo"})
      @movie.producers.should include({:imdb_id => "0400492", :name => "Carol Hughes"})
      @movie.producers.should include({:imdb_id => "0905152", :name => "Andy Wachowski"})
      @movie.producers.should include({:imdb_id => "0905154", :name => "Lana Wachowski"})
    end
    
    it "should return cast members and characters" do
      @movie.cast.should be_an(Array)
      @movie.cast.size.should eql(37)
      @movie.cast.should include({:imdb_id => "0000206", :name => "Keanu Reeves", :character => "Neo"})
      @movie.cast.should include({:imdb_id => "0000401", :name => "Laurence Fishburne", :character => "Morpheus"})
      @movie.cast.should include({:imdb_id => "0005251", :name => "Carrie-Anne Moss", :character => "Trinity"})
      @movie.cast.should include({:imdb_id => "0915989", :name => "Hugo Weaving", :character => "Agent Smith"})
      @movie.cast.should include({:imdb_id => "3269395", :name => "Rana Morrison", :character => "Shaylae - Woman in Office (uncredited)"})
    end
    
    it "should return release dates" do
      # Rear Window (1954)
      @movie = Spotlite::Movie.new("0047396")
      @movie.release_dates.should be_an(Array)
      @movie.release_dates.size.should eql(42)
      @movie.release_dates.should include({:code => "jp", :region => "Japan", :date => Date.new(1955,1,14)})
      @movie.release_dates.should include({:code => "tr", :region => "Turkey", :date => Date.new(1956,4,1)})
      @movie.release_dates.should include({:code => "us", :region => "USA", :date => Date.new(1968,1,1)})
      @movie.release_dates.detect{ |r| r[:region] == "France" }.should eql({:code => "fr", :region => "France", :date => Date.new(1955,4,1)})
    end
    
  end
  
end
