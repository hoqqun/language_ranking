require 'net/http'
require 'json'
require 'dotenv'
Dotenv.load

class Tasks::Github


  def self.fetch_repository
    
    1000.times do |count|
      puts "Count: #{count}"

      uri = URI.parse(repo_url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      
      req = Net::HTTP::Get.new(uri.request_uri)
      req["Authorization"] = access_token

      json = https.request(req)
      results = JSON.parse(json.body)

      unless results.blank?
        results.each do |result|
          add_repository result
        end
      end
    end
  end

  def self.fetch_language
    
    1001.upto(2000) do |count|
      puts count
      repository = Repository.find(count)

      uri = URI.parse(repository.url + '/languages' )
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
    
      req = Net::HTTP::Get.new(uri.request_uri)
      req["Authorization"] = "token #{ACCESS_TOKEN}"

      json = https.request(req)
      results = JSON.parse(json.body)

      unless results.blank? || results.has_key?("block")
        results.each do |key,value|
          language = Language.new
          language.repository_id = repository.id
          language.language = key
          language.size = value.to_i
          language.save
        end
      end
    end
  end
  
  def self.add_repository (new_repo)
    repository = Repository.new
    repository.repo_id = new_repo["id"].to_i
    repository.owner = new_repo["owner"]["login"]
    repository.url = new_repo["url"]
    repository.save
  end

  def self.since
    if Repository.order("repo_id desc").first.nil?
      0.to_s
    else
      Repository.order("repo_id desc").first.repo_id.to_s
    end
  end

  def self.repo_url
    repository_url = 'https://api.github.com/repositories'
    repository_url + '?since=' + since
  end

  def self.access_token
    github_key = ENV['GITHUB_KEY']
    'token ' + github_key
  end
end
