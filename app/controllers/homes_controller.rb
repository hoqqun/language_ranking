class HomesController < ApplicationController
  def index
    @summaries = Language.group(:language).order("sum_size desc").sum(:size)
    @repo_count = Language.distinct.count(:repository_id)
  end
end
