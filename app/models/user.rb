  class User < ActiveRecord::Base

  validates :email, :password, :full_name, presence: true
  validates_uniqueness_of :email

  has_secure_password validations: false

  has_many :queue_items, ->{order(:position)}
  has_many :reviews, -> {order('created_at DESC')}

  def normalize_queue_items_positions
    queue_items.each_with_index do |queue_item, index|
      queue_item.update_attributes(position: index + 1)
    end
  end

  def queue_video?(video)
    queue_items.map(&:video).include?(video)
  end
end