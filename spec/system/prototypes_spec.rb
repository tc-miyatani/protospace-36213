require 'rails_helper'

RSpec.describe "プロトタイプ投稿機能", type: :system do
  before do
    @prototype = FactoryBot.build(:prototype)
    @prototype.user.save # ログインできる様にDBにユーザー情報を保存
  end

  it '投稿に必要な情報が入力されていない場合は、投稿できずにそのページに留まること' do
    sign_in(@prototype.user)
    visit new_prototype_path
    click_button '保存する'
    expect(current_path).to eq prototypes_path
    expect(page).to have_button('保存する')
  end

  it 'バリデーションによって投稿ができず、そのページに留まった場合でも、入力済みの項目（画像以外）は消えないこと' do
    sign_in(@prototype.user)
    visit new_prototype_path
    fill_in 'prototype_title', with: @prototype.title
    fill_in 'prototype_catch_copy', with: @prototype.catch_copy
    fill_in 'prototype_concept', with: @prototype.concept
    click_button '保存する'
    expect(current_path).to eq prototypes_path
    # expect(find_field('prototype_title').value).to eq @prototype.title
    expect(page).to have_field('prototype_title', with: @prototype.title)
    expect(page).to have_field('prototype_catch_copy', with: @prototype.catch_copy)
    expect(page).to have_field('prototype_concept', with: @prototype.concept)
  end

  it '必要な情報を入力すると、投稿ができること' do
    sign_in(@prototype.user)
    visit new_prototype_path
    fill_in 'prototype_title', with: @prototype.title
    fill_in 'prototype_catch_copy', with: @prototype.catch_copy
    fill_in 'prototype_concept', with: @prototype.concept
    image_path = Rails.root.join('public/images/test_image.png')
    attach_file('prototype[image]', image_path, make_visible: true) 
    expect{
      click_button '保存する'
    }.to change{Prototype.count}.by(1)
    # 正しく投稿できた場合は、トップページへ遷移すること
    expect(current_path).to eq root_path
    # 投稿した情報は、トップページに表示されること
    # トップページに表示される投稿情報は、プロトタイプ毎に、画像・プロトタイプ名・キャッチコピー・投稿者の名前の、4つの情報について表示できること    
    post_element = find('.card')
    expect(post_element).to have_content(@prototype.title)
    expect(post_element).to have_content(@prototype.catch_copy)
    expect(post_element).to have_link(@prototype.user.name)
    # 画像が表示されており、画像がリンク切れなどになっていないこと
    expect(post_element).to have_selector("img[src$='#{@prototype.image.filename}']")
  end
end

RSpec.describe "プロトタイプ詳細・編集・削除機能", type: :system do
  before do
    @prototype = FactoryBot.create(:prototype)
  end

  context 'プロトタイプ詳細ページ機能' do
    it 'ログアウト状態でもトップページプロトタイプが一覧表示されていて詳細ページへ遷移できること' do
      # ログアウト状態でもトップページにプロトタイプの情報が表示されていること(コンセプトは無し)
      visit root_path
      post_element = find('.card')
      expect(post_element).to have_content(@prototype.title)
      expect(post_element).to have_content(@prototype.catch_copy)
      expect(post_element).to have_link(@prototype.user.name)
      expect(post_element).to have_selector("img[src$='#{@prototype.image.filename}']")
      # ログアウト状態でもトップページのプロトタイプの画像から詳細ページへ遷移できること
      find("img[src$='#{@prototype.image.filename}']").click
      expect(current_path).to eq prototype_path(@prototype)
      # ログアウト状態でもトップページのプロトタイプのタイトルから詳細ページへ遷移できること
      visit root_path
      click_link @prototype.title
      expect(current_path).to eq prototype_path(@prototype)
      # ログアウト状態でもプロトタイプ詳細ページにプロトタイプの情報が表示されていること
      expect(page).to have_content(@prototype.title)
      expect(page).to have_content(@prototype.catch_copy)
      expect(page).to have_content(@prototype.concept)
      expect(page).to have_link(@prototype.user.name)
      expect(page).to have_selector("img[src$='#{@prototype.image.filename}']")
    end

    it 'ログイン状態では自分のプロトタイプの「編集」「削除」のリンクが存在すること' do
      sign_in(@prototype.user)
      visit prototype_path(@prototype)
      expect(page).to have_link('編集する')
      expect(page).to have_link('削除する')
    end
  end

  context 'プロトタイプ編集機能' do
    it '投稿に必要な情報を入力すると、プロトタイプが編集できること' do
      sign_in(@prototype.user)
      visit edit_prototype_path(@prototype)
      # 編集画面に既に登録されている情報が入力済みになっていること
      expect(page).to have_field('prototype_title', with: @prototype.title)
      expect(page).to have_field('prototype_catch_copy', with: @prototype.catch_copy)
      expect(page).to have_field('prototype_concept', with: @prototype.concept)
      # 編集実行
      edit_prototype = FactoryBot.build(:prototype)
      fill_in 'prototype_title', with: edit_prototype.title
      fill_in 'prototype_catch_copy', with: edit_prototype.catch_copy
      fill_in 'prototype_concept', with: edit_prototype.concept
      image_path = Rails.root.join('public/images/test_image2.jpg')
      attach_file('prototype[image]', image_path, make_visible: true) 
      click_button '保存する'
      # 正しく編集できた場合は、詳細ページへ遷移すること
      expect(current_path).to eq prototype_path(@prototype)
      expect(page).to have_content(edit_prototype.title)
      expect(page).to have_content(edit_prototype.catch_copy)
      expect(page).to have_content(edit_prototype.concept)
      expect(page).to have_selector("img[src$='test_image2.jpg']")
    end

    it '何も編集せずに更新をしても、画像無しのプロトタイプにならないこと' do
      sign_in(@prototype.user)
      visit edit_prototype_path(@prototype)
      click_button '保存する'
      expect(page).to have_selector("img[src$='#{@prototype.image.filename}']")
    end

    it '編集画面のバリデーション' do
      sign_in(@prototype.user)
      visit edit_prototype_path(@prototype)
      # 空の入力欄がある場合は、編集できずにそのページに留まること
      edit_prototype = FactoryBot.build(:prototype)
      fill_in 'prototype_title', with: edit_prototype.title
      fill_in 'prototype_catch_copy', with: edit_prototype.catch_copy
      fill_in 'prototype_concept', with: ''
      click_button '保存する'
      expect(current_path).to eq prototype_path(@prototype)
      expect(page).to have_button('保存する')
      # 編集ができず、そのページに留まった場合でも、入力済みの項目（画像以外）は消えないこと
      expect(page).to have_field('prototype_title', with: edit_prototype.title)
      expect(page).to have_field('prototype_catch_copy', with: edit_prototype.catch_copy)
    end
  end

  context 'プロトタイプ削除機能' do
    it 'ログイン状態で自分の投稿したプロトタイプが削除できて、トップページへ遷移すること' do
      sign_in(@prototype.user)
      visit prototype_path(@prototype)
      expect{
        click_link '削除する'
      }.to change{Prototype.count}.by(-1)
      # 削除が完了すると、トップページへ遷移すること
      expect(current_path).to eq root_path
    end
  end
end

RSpec.describe "プロトタイプのアクセス範囲の制限", type: :system do
  before do
    @prototype = FactoryBot.create(:prototype)
  end

  it 'ログアウト状態' do
    # ログアウト状態でプロトタイプ投稿ページへ行くとログインページに飛ばされる
    visit new_prototype_path
    expect(current_path).to eq new_user_session_path
    # ログアウト状態では「編集」「削除」のリンクが存在しないこと
    visit prototype_path(@prototype)
    expect(page).to have_no_link('編集する')
    expect(page).to have_no_link('削除する')
  end

  it 'ログイン状態でも他人のプロトタイプの「編集」「削除」はできないこと' do
    prototype2 = FactoryBot.create(:prototype)
    sign_in(prototype2.user)
    # ログイン状態でも他人のプロトタイプの「編集」「削除」のリンクは存在しないこと
    visit prototype_path(@prototype)
    expect(page).to have_no_link('編集する')
    expect(page).to have_no_link('削除する')
    # 他人のプロトタイプの編集ページにアクセスするとトップページへ飛ばされること
    visit edit_prototype_path(@prototype)
    expect(current_path).to eq root_path
  end
end
