class HomesController < ApplicationController
  def index
    @summaries = Language.ranking
    @repo_count = Language.distinct.count(:repository_id)
  end
end
