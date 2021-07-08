require 'rails_helper'


RSpec.describe "ユーザー新規登録", type: :system do
  before do
    @user = FactoryBot.build(:user)
  end

  context 'ユーザー新規登録ができるとき' do 
    it '正しい情報を入力すればユーザー新規登録ができてトップページに移動する' do
      # トップページに移動する
      visit root_path
      # こんにちはのメッセージがないことを確認
      expect(page).to have_no_content('こんにちは')
      # トップページにサインアップページへ遷移するボタンがあることを確認する
      expect(page).to have_content('新規登録')
      # 新規登録ページへ移動する
      visit new_user_registration_path
      # ユーザー情報を入力する
      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: @user.password
      fill_in 'user_password_confirmation', with: @user.password_confirmation
      fill_in 'user_name', with: @user.name
      fill_in 'user_profile', with: @user.profile
      fill_in 'user_occupation', with: @user.occupation
      fill_in 'user_position', with: @user.position
      # サインアップボタンを押すとユーザーモデルのカウントが1上がることを確認する
      expect{
        find('input[name="commit"]').click
      }.to change {User.count}.by(1)
      # トップページへ遷移したことを確認する
      expect(current_path).to eq(root_path)
      # こんにちは、〜さんが表示される
      expect(page).to have_content("こんにちは、")
      expect(page).to have_content(@user.name)
      expect(page).to have_content("さん")
      # ログアウトボタンやNew Protoボタンが表示されることを確認する
      expect(page).to have_content('ログアウト')
      expect(page).to have_content('New Proto')
      # 新規登録ボタンや、ログインボタンが表示されていないことを確認する
      expect(page).to have_no_content('新規登録')
      expect(page).to have_no_content('ログイン')
    end
  end
  context 'ユーザー新規登録ができないとき' do
    it '誤った情報ではユーザー新規登録ができずに新規登録ページへ戻ってくる' do
      # トップページに移動する
      visit root_path
      # トップページにサインアップページへ遷移するボタンがあることを確認する
      expect(page).to  have_content('新規登録')
      # 新規登録ページへ移動する
      visit new_user_registration_path
      # ユーザー情報を入力する
      fill_in 'user_email', with: ''
      fill_in 'user_password', with: ''
      fill_in 'user_password_confirmation', with: ''
      fill_in 'user_name', with: ''
      fill_in 'user_profile', with: ''
      fill_in 'user_occupation', with: ''
      fill_in 'user_position', with: ''
      # サインアップボタンを押してもユーザーモデルのカウントは上がらないことを確認する
      expect{
        find('input[name="commit"]').click
      }.not_to change {User.count}
      # 新規登録ページへ戻されることを確認する
      expect(current_path).to eq user_registration_path
    end
  end
end

RSpec.describe 'ログイン', type: :system do
  before do
    @user = FactoryBot.create(:user)
  end

  context 'ログインができるとき' do
    it '保存されているユーザーの情報と合致すればログインができる' do
      # トップページに移動する
      visit root_path
      # トップページにログインページへ遷移するボタンがあることを確認する
      expect(page).to have_content('ログイン')
      # ログインページへ遷移する
      visit new_user_session_path
      # 正しいユーザー情報を入力する
      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: @user.password
      # ログインボタンを押す
      find('input[name="commit"]').click
      # トップページへ遷移することを確認する
      expect(current_path).to eq(root_path)
      # ログアウトボタンやNew Protoボタンが表示されることを確認する
      expect(page).to have_content('ログアウト')
      expect(page).to have_content('New Proto')
      # 新規登録ボタンや、ログインボタンが表示されていないことを確認する
      expect(page).to have_no_content('新規登録')
      expect(page).to have_no_content('ログイン')
    end
  end
  context 'ログインができないとき' do
    it '保存されているユーザーの情報と合致しないとログインができない' do
    # トップページに移動する
    visit root_path
    # トップページにログインページへ遷移するボタンがあることを確認する
    expect(page).to have_content('ログイン')
    # ログインページへ遷移する
    visit new_user_session_path
    # ユーザー情報を入力する
    fill_in 'user_email', with: ''
    fill_in 'user_password', with: ''
    # ログインボタンを押す
    find('input[name="commit"]').click
    # ログインページへ戻されることを確認する
    expect(current_path).to eq(new_user_session_path)
    end
  end
end
