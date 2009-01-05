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

  def self.answer
    now             = Time.now.utc
    next_episode    = nil
    current_episode = episodes.detect do |episode|
      if episode.current?(now)
        true
      else
        next_episode = episode
        false
      end
    end
    {:answer => build_answer(current_episode, now), :reason => build_reason(current_episode, next_episode)}
  end

  class Episode < Struct.new(:code, :title, :air_date)
    class << self
      attr_accessor :episodes_path
    end
    self.episodes_path = File.join(File.dirname(__FILE__), '..', '..', 'episodes')

    def current?(now)
      now > air_date
    end

    def old?(now)
      now > (air_date + 1.month)
    end

    def self.load(filename)
      YAML.load_file(File.join(episodes_path, "#{filename}.yml")).map do |(code, data)|
        Episode.new(code, data['title'], data['air_date'])
      end.sort! { |x, y| y.air_date <=> x.air_date }
    end
  end

private
  def self.build_answer(current_episode, now)
    (current_episode.nil? || current_episode.old?(now)) ? :no : :yes
  end

  def self.build_reason(current_episode, next_episode)
    episode = next_episode || current_episode
    season, ep = episode.code.scan(/^s(\d+)e(\d+)$/).first
    "Season #{season}#{", episode #{ep}" if current_episode && ep != '1'} start#{next_episode ? :s : :ed} on #{episode.air_date.strftime("%b %d, %I %p")}"
  end
end