#
# note: we use the user login for the discussion id.
#

class Me::PostsController < Me::BaseController

  include_controllers 'common/posts'

  prepend_before_filter :fetch_data
  guard :may_ALIAS_post?

  # /me/discussions/green/posts
  def index
    @other_user = @recipient
    @discussion.mark!(:read, current_user)
    @posts = @discussion.posts.paginate(post_pagination_params)
  end

  def create
    in_reply_to = Post.find_by_id(params[:in_reply_to_id])
    current_user.send_message_to!(@recipient, params[:post][:body], in_reply_to)
    render_posts_refresh(@discussion.posts.paginate(post_pagination_params))
  end

  protected

  def fetch_data
    if params[:discussion_id]
      @recipient = User.find_by_login(params[:discussion_id])
      @discussion = current_user.discussions.from_user(@recipient).first
    end
    if @recipient.blank?
      redirect_to me_discussions_url
    end
    if params[:id] && @discussion
      @post = @discussion.posts.find(params[:id])
    end
  end

  private

  def post_pagination_params
    #default_page = params[:page].blank? ? @discussion.last_page : params[:page]
    #pagination_params(:page => default_page)
    pagination_params
  end

  #
  # Define the path for editing posts. This is used by the post templates.
  #

  def edit_post_path(post, *args)
    edit_me_discussion_post_path(@recipient, post, *args)
  end
  helper_method :edit_post_path

  def post_path(post, *args)
    me_discussion_post_path(@recipient, post, *args)
  end
  helper_method :post_path

  def posts_path(*args)
    me_discussion_posts_path(@recipient, *args)
  end
  helper_method :posts_path

end
