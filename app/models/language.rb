class Language < ApplicationRecord
  scope :ranking , -> {group(:language).order("sum_size desc").sum(:size)}
  
  belongs_to :repository

  def self.all_size
    ranking.inject(0) { |sum, (key,val)| sum = sum + val }
  end
end
