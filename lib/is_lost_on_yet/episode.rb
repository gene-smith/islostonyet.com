require 'yaml'
module IsLOSTOnYet
  class << self
    attr_accessor :episodes_by_code
    attr_accessor :episodes
  end

  def self.load_episodes(filename)
    self.episodes_by_code = {}
    (self.episodes = Episode.load(filename)).each do |ep|
      episodes_by_code[ep.code.to_sym] = ep
    end
  end

  def self.episode(code)
    episodes_by_code[code]
  end

  class Episode < Struct.new(:code, :title, :air_date)
    class << self
      attr_accessor :episodes_path
    end
    self.episodes_path = File.join(File.dirname(__FILE__), '..', '..', 'episodes')

    def self.load(filename)
      YAML.load_file(File.join(episodes_path, "#{filename}.yml")).map do |(code, data)|
        Episode.new(code, data['title'], data['air_date'])
      end.sort! { |x, y| y.air_date <=> x.air_date }
    end
  end
end