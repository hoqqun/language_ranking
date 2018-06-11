require 'net/http'
require 'json'
require 'dotenv'
Dotenv.load

class Tasks::Github

  def self.fetch_repository
    
    1.times do |count|
      puts "Count: #{count}"

      uri = URI.parse(repo_url)
      results = request_to_github(uri)

      unless results.blank?
        results.each do |result|
          repo = add_repository result
          fetch_language2 repo
        end
      else
        #リポジトリは全取得状態なので、Languageレコードの更新時刻が古い順に取得しなおしていく。
        update_repository_id = Language.order("created_at desc").first.repository_id
        Language.where("repository_id = #{update_repository_id}").map(&:destroy)
        fetch_language2 Repository.find(update_repository_id)
      end
    end
  end

  def self.fetch_language2(repo)
    uri = URI.parse(repo.url + '/languages')
    results = request_to_github(uri)

    unless results.blank? || results.has_key?("block")
      results.each do |key,value|
        language = Language.new
        language.repository_id = repo.id
        language.language = key
        language.size = value.to_i
        language.save
      end
    end
  end
  
  def self.request_to_github (uri)
    req = request_with_token(uri)
    https = https_with_ssl(uri)
    json = https.request(req)

    JSON.parse(json.body)
  end

  def self.https_with_ssl(uri)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https
  end

  def self.request_with_token(uri)
    req = Net::HTTP::Get.new(uri.request_uri)
    req["Authorization"] = access_token
    req
  end

  def self.add_repository (new_repo)
    repository = Repository.new
    repository.repo_id = new_repo["id"].to_i
    repository.owner = new_repo["owner"]["login"]
    repository.url = new_repo["url"]
    repository.save
    repository
  end

  def self.repo_url
    repository_url = 'https://api.github.com/repositories'
    repository_url + '?since=' + Repository.since
  end

  def self.access_token
    github_key = ENV['GITHUB_KEY']
    'token ' + github_key
  end
end
