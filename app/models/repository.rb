class Repository < ApplicationRecord
  has_many :languages

  def self.since
    if Repository.order("repo_id desc").first.nil?
      0.to_s
    else
      (Repository.order("repo_id desc").first.repo_id + 1).to_s
    end
  end
end
