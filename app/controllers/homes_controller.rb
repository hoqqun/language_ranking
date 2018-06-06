class HomesController < ApplicationController
  def index
    @summaries = Language.group(:language).order("sum_size desc").sum(:size)
    @repo_count = Language.order("repository_id desc").first.repository_id
  end
end
