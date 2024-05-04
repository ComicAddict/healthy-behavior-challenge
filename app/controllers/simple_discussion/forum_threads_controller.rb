# frozen_string_literal: true

module SimpleDiscussion
  class ForumThreadsController < SimpleDiscussion::ApplicationController
    # before_action :authenticate_user!, only: [:mine, :participating, :new, :create]
    before_action :set_forum_thread, only: %i[show edit update]
    before_action :require_mod_or_author_for_thread!, only: %i[edit update]
    include ChallengesHelper
    before_action :require_user

    def index
      @forum_threads = ForumThread.pinned_first.sorted.includes(:user, :forum_category).paginate(page: page_number)
    end

    def answered
      @forum_threads = ForumThread.solved.sorted.includes(:user, :forum_category).paginate(page: page_number)
      render action: :index
    end

    def unanswered
      @forum_threads = ForumThread.unsolved.sorted.includes(:user, :forum_category).paginate(page: page_number)
      render action: :index
    end

    def mine
      @forum_threads = ForumThread.where(user: @user).sorted.includes(:user, :forum_category).paginate(page: page_number)
      render action: :index
    end

    def participating
      @forum_threads = ForumThread.includes(:user, :forum_category).joins(:forum_posts).where(forum_posts: { user_id: @user }).distinct(forum_posts: :id).sorted.paginate(page: page_number)
      render action: :index
    end

    def show
      @forum_post = ForumPost.new
      current_user = @user
      @forum_post.user = current_user
    end

    def new
      @forum_thread = ForumThread.new
      @forum_thread.forum_posts.new
    end

    def create
      @user = User.find(session[:user_id])
      @forum_thread = @user.forum_threads.new(forum_thread_params)
      @forum_thread.forum_posts.each { |post| post.user_id = @user.id }

      if @forum_thread.save
        SimpleDiscussion::ForumThreadNotificationJob.perform_later(@forum_thread)
        redirect_to simple_discussion.forum_thread_path(@forum_thread)
      else
        render action: :new
      end
    end

    def edit; end

    def update
      if @forum_thread.update(forum_thread_params)
        redirect_to simple_discussion.forum_thread_path(@forum_thread), notice: I18n.t('your_changes_were_saved')
      else
        render action: :edit
      end
    end

    private

    def set_forum_thread
      @forum_thread = ForumThread.friendly.find(params[:id])
    end

    def forum_thread_params
      params.require(:forum_thread).permit(:title, :forum_category_id, forum_posts_attributes: [:body])
    end

    def require_user
      return if user_signed_in?

      flash[:alert] = 'You must be signed in to access this page.'
      redirect_to login_path
    end
  end
end
