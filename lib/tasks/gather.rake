namespace :gather do

  require 'net/http'
  require 'json'
  require 'dotenv'
  Dotenv.load

  desc "Githubから情報収集する"

  task :fetch do
    puts "Start fetching data from Github."

    uri = URI.parse(repo_url)
    results = request_to_github(uri)

    unless results.blank?
      results.each do |result|
        repo = add_repository result
        fetch_language2 repo
      end
    else
      #リポジトリは全取得状態なので、Languageレコードの更新時刻が古い順に取得しなおしていく。
      Language.where("repository_id = #{update_repository_id}").map(&:destroy)
      fetch_language2 Repository.find(update_repository_id)
    end
  end

  def update_repository_id
    Language.order("created_at desc").first.repository_id
  end

  def fetch_language2(repo)
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

  def request_to_github (uri)
    req = request_with_token(uri)
    https = https_with_ssl(uri)
    json = https.request(req)

    JSON.parse(json.body)
  end

  def https_with_ssl(uri)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https
  end

  def request_with_token(uri)
    req = Net::HTTP::Get.new(uri.request_uri)
    req["Authorization"] = access_token
    req
  end

  def add_repository (new_repo)
    repository = Repository.new
    repository.repo_id = new_repo["id"].to_i
    repository.owner = new_repo["owner"]["login"]
    repository.url = new_repo["url"]
    repository.save
    repository
  end

  def since
    if Repository.order("repo_id desc").first.nil?
      0.to_s
    else
      (Repository.order("repo_id desc").first.repo_id + 1).to_s
    end
  end

  def start_repo_id
    if Repository.order("repository_id desc").first.nil?
      0
    else
      Repository.order("repository_id desc").first.repository_id + 1
    end
  end

  def repo_url
    repository_url = 'https://api.github.com/repositories'
    repository_url + '?since=' + since
  end

  def access_token
    github_key = ENV['GITHUB_KEY']
    'token ' + github_key
  end
end
