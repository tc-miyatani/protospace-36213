class PrototypesController < ApplicationController
  # ログインしていないユーザーがプロトタイプの投稿・編集・削除ページへのアクセス・実行しようとするとログインページへ飛ばす
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  # 他の投稿者のプロトタイプの編集・削除ページへのアクセス・実行しようとするとトップへ飛ばす
  before_action :poster!, only: [:edit, :update, :destroy]

  def index
    @prototypes = Prototype.includes(:user)
  end

  def new
    @prototype = Prototype.new
  end

  def create
    @prototype = Prototype.new(prototype_params)
    if @prototype.save
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @prototype = Prototype.find(params[:id])
    @comments = @prototype.comments
    @comment = Comment.new
  end

  def edit
  end

  def update
    if @prototype.update(prototype_params)
      redirect_to prototype_path(@prototype)
    else
      render :edit
    end
  end

  def destroy
    @prototype.destroy
    redirect_to root_path
  end

  private

  def prototype_params
    params.require(:prototype)
      .permit(:title, :catch_copy, :concept, :image)
      .merge(user_id: current_user.id)
  end

  def poster!
    @prototype = Prototype.find(params[:id])
    unless @prototype.user_id == current_user.id
      redirect_to root_path
    end
  end
end
