require 'rails_helper'

RSpec.describe "ユーザー権限の制限", type: :request do
  before do
    @prototype = FactoryBot.create(:prototype)
    @my_prototype = FactoryBot.create(:prototype)
    @change_prototype = FactoryBot.build(:prototype)
  end

  describe 'ログインしていれば自分のプロトタイプの編集・削除ができる' do
    before do
      # ログイン処理
      post user_session_path, params: {
          user: {
            email: @my_prototype.user.email,
            password: @my_prototype.user.password
          }
      }
      expect(response).to have_http_status(302)
      get root_path
      expect(response.body).to include('こんにちは')
    end

    it 'ログインしていれば自分のプロトタイプの編集ができる' do
      patch prototype_path(@my_prototype), params: {
        prototype: {
          title: @change_prototype.title,
          catch_copy: @change_prototype.catch_copy,
          concept: @change_prototype.concept
        }
      }
      get prototype_path(@my_prototype)
      expect(response.body).to include(@change_prototype.title)
      expect(response.body).to include(@change_prototype.catch_copy)
      expect(response.body).to include(@change_prototype.concept)
    end

    it 'ログインしていれば自分のプロトタイプの削除ができる' do
      expect {
        delete prototype_path(@my_prototype)
      }.to change{Prototype.count}.by(-1)
    end
  end

  describe 'ログアウト状態ではプロトタイプの編集・削除はできない' do
    it 'ログアウト状態ではプロトタイプの編集はできない' do
      patch prototype_path(@my_prototype), params: {
        prototype: {
          title: @change_prototype.title,
          catch_copy: @change_prototype.catch_copy,
          concept: @change_prototype.concept
        }
      }
      # ログアウト状態で編集をしようとするとログインページへ飛ばされる
      expect(response).to redirect_to(new_user_session_path)
      # 編集が失敗している
      get prototype_path(@my_prototype)
      expect(response.body).not_to include(@change_prototype.title)
      expect(response.body).not_to include(@change_prototype.catch_copy)
      expect(response.body).not_to include(@change_prototype.concept)
    end

    it 'ログアウト状態ではプロトタイプの削除はできない' do
      expect {
        delete prototype_path(@my_prototype)
      }.not_to change{Prototype.count}
      # ログアウト状態で削除をしようとするとログインページへ飛ばされる
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe 'ログイン状態でも他人のプロトタイプの編集・削除はできない' do
    before do
      # ログイン処理
      post user_session_path, params: {
          user: {
            email: @my_prototype.user.email,
            password: @my_prototype.user.password
          }
      }
      expect(response).to have_http_status(302)
      get root_path
      expect(response.body).to include('こんにちは')
    end

    it 'ログイン状態でも他人のプロトタイプの編集はできない' do
      patch prototype_path(@prototype), params: {
        prototype: {
          title: @change_prototype.title,
          catch_copy: @change_prototype.catch_copy,
          concept: @change_prototype.concept
        }
      }
      # 他人のプロトタイプを編集しようとするとトップへ飛ばされる
      expect(response).to redirect_to(root_path)
      get prototype_path(@prototype)
      expect(response.body).not_to include(@change_prototype.title)
      expect(response.body).not_to include(@change_prototype.catch_copy)
      expect(response.body).not_to include(@change_prototype.concept)
    end

    it 'ログイン状態でも他人のプロトタイプの削除はできない' do
      expect {
        delete prototype_path(@prototype)
      }.not_to change{Prototype.count}
      # 他人のプロトタイプを削除しようとするとトップへ飛ばされる
      expect(response).to redirect_to(root_path)
    end
  end
end
