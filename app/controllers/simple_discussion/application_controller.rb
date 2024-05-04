# frozen_string_literal: true

module SimpleDiscussion
  class ApplicationController < ::ApplicationController
    layout 'simple_discussion'

    def page_number
      page = params.fetch(:page, '').gsub(/[^0-9]/, '').to_i
      page = '1' if page.zero?
      page
    end

    def is_moderator_or_owner?(object)
      is_moderator? || object.user == @user
    end
    helper_method :is_moderator_or_owner?

    def is_moderator?
      @user.respond_to?(:moderator) && @user.moderator?
    end
    helper_method :is_moderator?

    def require_mod_or_author_for_post!
      return if is_moderator_or_owner?(@forum_post)

      redirect_to_root
    end

    def require_mod_or_author_for_thread!
      return if is_moderator_or_owner?(@forum_thread)

      redirect_to_root
    end

    private

    def redirect_to_root
      redirect_to simple_discussion.root_path, alert: "You aren't allowed to do that."
    end
  end
end
