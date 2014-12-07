class Guide
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Slug
  searchkick

  is_impressionable counter_cache: true,
                    column_name:   :impressions_field,
                    unique:        :session_hash

  field :impressions_field, default: 0

  belongs_to :crop, counter_cache: true
  belongs_to :user
  has_many :stages
  has_many :requirements

  field :name
  field :location
  field :overview
  field :practices, type: Array

  validates [:user, :crop, :name], presence: true

  has_mongoid_attached_file :featured_image,
                            default_url: '/assets/leaf-grey.png'
  validates_attachment_size :featured_image, in: 1.byte..2.megabytes
  validates_attachment :featured_image,
                       content_type: { content_type:
                                                     ['image/jpg', 'image/jpeg', 'image/png', 'image/gif'] }
  handle_asynchronously :featured_image=

  def owned_by?(current_user)
    !!(current_user && user == current_user)
  end

  def search_data
    as_json only: [:name, :overview, :crop_id]
  end

  def compatibility_score
    # Make our random scores consistent based on the first character of the crop name
    # srand(name[0].ord)
    # rand(100);
    nil
  end

  def compatibility_label
    ''
    # TODO:
    # score = compatibility_score

    # if score.nil?
    #   return ''
    # elsif score > 75
    #   return 'high'
    # elsif score > 50
    #   return 'medium'
    # else
    #   return 'low'
    # end
  end

  slug :name
end
