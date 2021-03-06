  class User < ActiveRecord::Base
  include Tokenable  # this a concern taking care of generation of tokens

  validates :email, :password, :full_name, presence: true
  validates_uniqueness_of :email

  has_secure_password validations: false

  has_many :queue_items, ->{order(:position)}
  has_many :reviews, -> {order('created_at DESC')}

  # the current_user is the follower

  has_many :following_relationships, class_name: 'Relationship', foreign_key: :follower_id
  has_many :leading_relationships, class_name: 'Relationship', foreign_key: :leader_id

  #has_many :invitations


  def normalize_queue_items_positions
    queue_items.each_with_index do |queue_item, index|
      queue_item.update_attributes(position: index + 1)
    end
  end

  def queue_video?(video)
    queue_items.map(&:video).include?(video)
  end

  def follows?(other_obj)

    following_relationships.map(&:leader).include?(other_obj)

  end

  # we could use this method below, instead of unless current_user == @user || current_user.follows?(@user)
  #that u will find under user.rb || show.html.haml (user)

  def can_follow?(another_user)
    !( self.follows?(another_user) || self == another_user )
  end

  def follow(another_user)
    #using this method can_follow to check the obj itself
    following_relationships.create(leader: another_user) if can_follow?(another_user)
  end



end