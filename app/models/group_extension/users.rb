#
# Module that extends Group behavior.
#
# Handles all the group <> user relationships
#
module GroupExtension::Users

  def self.included(base)
    base.instance_eval do

      attr :users_before_destroy
      before_destroy :destroy_memberships
#      before_create :set_created_by

      has_many :memberships, :before_add => :check_duplicate_memberships

      has_many :users, :through => :memberships do
        def <<(*dummy)
          raise Exception.new("don't call << on group.users");
        end
        def delete(*records)
          raise Exception.new("don't call delete on group.users");
        end
        def most_recently_active(options={})
          find(:all, {:order => 'memberships.visited_at DESC', :limit => 10}.merge(options))
        end
      end

      # tmp hack until we have a better viewing system in place.
      named_scope :most_visits, {:order => 'count(memberships.total_visits) DESC', :group => 'groups.id', :joins => :memberships}

      named_scope :recent_visits, {:order => 'memberships.visited_at DESC', :group => 'groups.id', :joins => :memberships}

      named_scope :with_admin, lambda { |user|
        {:conditions => ["groups.id IN (?)", user.admin_for_group_ids]}
      }

    end
  end

  # commented out... removing a council member from a group is no big deal,
  # they can still just add themselves back. -e
  #
  #def users_allowed_to_vote_on_removing(user)
  #  # only council members can vote on removing council members
  #  if self.has_a_council? and user.may?(:admin, self)
  #    return self.council.users
  #  else
  #    return self.users
  #  end
  #end

  def user_ids
    @user_ids ||= memberships.collect{|m|m.user_id}
  end

  def all_users
    users
  end

  # association callback
  def check_duplicate_memberships(membership)
    membership.user.check_duplicate_memberships(membership)
  end

  def relationship_to(user)
    relationships_to(user).first
  end
  def relationships_to(user)
    return [:stranger] unless user
    return [:stranger] if user.is_a? UnauthenticatedUser

    @relationships_to_user_cache ||= {}
    @relationships_to_user_cache[user.login] ||= get_relationships_to(user)
    @relationships_to_user_cache[user.login].dup
  end

  def get_relationships_to(user)
    ret = []
#   ret << :admin    if ...
    ret << :member   if user.member_of?(self)
#   ret << :peer     if ...
    ret << :stranger
    ret
  end

  #
  # this is the ONLY way to add users to a group.
  # all other methods will not work.
  #
  def add_user!(user)
    self.memberships.create! :user => user
    user.update_membership_cache
    user.clear_peer_cache_of_my_peers
    clear_key_cache

    @user_ids = nil
    self.increment!(:version)
  end

  #
  # this is the ONLY way to remove users from a group.
  # all other methods will not work.
  #
  def remove_user!(user)
    membership = self.memberships.find_by_user_id(user.id)
    raise ErrorMessage.new('no such membership') unless membership

    user.clear_peer_cache_of_my_peers
    membership.destroy
    user.update_membership_cache
    clear_key_cache

    @user_ids = nil
    self.increment!(:version)

    # remove user from all the groups committees
    self.committees.each do |committe|
      committe.remove_user!(user) unless committe.users.find_by_id(user.id).blank?
    end
  end

  def open_membership?
    self.profiles.public.membership_policy_is? :open
  end

  def single_user?
    self.users.count == 1
  end

  protected

  def destroy_memberships
    # save users before destroying memberships
    # so that we still have them to create GroupDestroyedActivities for them
    @users_before_destroy = users.dup
    user_names = []
    self.memberships.each do |membership|
      user = membership.user
      user_names << user.name
      membership.skip_destroy_notification = true
      user.clear_peer_cache_of_my_peers
      membership.destroy
      user.update_membership_cache
    end
    self.increment!(:version)
  end

  def set_created_by
    self.created_by ||= User.current
  end

# maps a user <-> group relationship to user <-> language
#  def in_user_terms(relationship)
#    case relationship
#      when :member;   'friend'
#      when :ally;     'peer'
#      else; relationship.to_s
#    end
#  end

end

