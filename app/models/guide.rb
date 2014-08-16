class Guide
  include Mongoid::Document
  # For more info about search, see:
  # https://github.com/mauriciozaffari/mongoid_search
  include Mongoid::Search
  belongs_to :crop
  belongs_to :user

  has_many :stages
  has_many :requirements

  field :name
  field :overview

  # TODO: All the other fields
end
