require 'rails_helper'

describe 'モデルのテスト' do
  describe 'since' do
    it 'リポジトリモデルが0件の場合、0を文字列で返す' do
      Repository.delete_all
      expect(Repository.since).to eq "0"
    end
    
    it "リポジトリモデルが1件以上の場合、もっとも値が高いrepo_idを返す" do
      FactoryBot.create(:repository)
      expect(Repository.since).to eq "5001"
    end
  end
  
end
