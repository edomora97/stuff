require 'open-uri'
require 'json'
require 'ap'
require 'active_record'
require 'mysql2'

# connect to the database
ActiveRecord::Base.establish_connection(
  adapter:  'mysql2', 
  database: 'railscasts',
  username: 'root',
  password: 'password',
  host:     'localhost'
)

# models definitions
class Episode < ActiveRecord::Base
    has_many :tags, through: :assignments
    has_many :assignments
end
class Tag < ActiveRecord::Base
    has_many :episodes, through: :assignments
    has_many :assignments
end
class Assignment < ActiveRecord::Base
    belongs_to :episode
    belongs_to :tag
end

# extract the url of the episode from the given params
episode_url = "http://railscasts.com/episodes/#{ARGV[0]}.json"

# get the data and parse from JSON
data = open(episode_url).read
result = JSON.parse(data)

episode = {
    number: result["position"],
    name: result["name"],
    url: "http://railscasts.com/episodes/#{ARGV[0]}",
    description: result["description"],
    notes: result["notes"],
    duration: "00:#{result["duration"]}",
    file_size: result["file_sizes"]["mp4"],
    pro: result["pro"],
    revised: result["revised"]
}

begin
    ep = Episode.create episode
rescue # AcriveRecord::RecordNotFound
    ep = Episode.where(name: result["name"]).first
end

# extract the id and the name of the tags
tags = result["tags"].map { |t| { id: t["tag"]["id"], tag: t["tag"]["name"] } }
# add the tags to the episode
tags.each do |t|
    # get the tag or create it
    begin
        tag = Tag.find t[:id]
    rescue
        tag = Tag.create! t
    end
    # add the tag if not present
    begin
        ep.tags << tag
    rescue
        puts "Error adding tag: #{t[:tag]}" 
    end
end

# save
begin
    ep.save!
rescue
    puts "Error saving!"
end
