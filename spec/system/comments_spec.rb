require 'rails_helper'

RSpec.describe "コメント機能", type: :system do
  before do
    # プロトタイプの投稿を用意
    @prototype = FactoryBot.create(:prototype)
    # プロトタイプの投稿者とは別のコメント投稿者用アカウントを用意
    @comment = FactoryBot.build(:comment)
    @comment.user.save
  end

  #コメント投稿欄は、ログイン状態のユーザーへのみ、詳細ページに表示されていること
  it 'コメントが投稿できること' do
    # ログアウト状態では詳細ページにコメント「送信する」ボタンが表示されないこと
    visit prototype_path(@prototype)
    expect(page).to have_no_button('送信する')
    # ログイン状態では詳細ページにコメント「送信する」ボタンが表示されること
    sign_in(@comment.user)
    visit prototype_path(@prototype)
    expect(page).to have_button('送信する')
    # 正しくフォームを入力すると、コメントが投稿できること
    fill_in 'comment_text', with: @comment.text
    click_button '送信する'
    # コメントを投稿すると、詳細ページに戻ってくること
    expect(current_path).to eq prototype_path(@prototype)
    # コメントを投稿すると、投稿したコメントとその投稿者名が、対象プロトタイプの詳細ページにのみ表示されること
    # 詳細ページに表示されること
    expect(page).to have_content(@comment.text)
    expect(page).to have_link(@comment.user.name)
    # トップページには表示されないこと
    visit root_path
    prototype_element = find('.card')
    expect(prototype_element).to have_no_content(@comment.text)
    expect(prototype_element).to have_no_link(@comment.user.name)
  end

  it 'フォームを空のまま投稿しようとすると、投稿できずにそのページに留まること' do
    sign_in(@comment.user)
    visit prototype_path(@prototype)
    fill_in 'comment_text', with: ''
    click_button '送信する'
    expect(current_path).to eq prototype_comments_path(@prototype)
    expect(page).to have_no_link(@comment.user.name)
  end

end
