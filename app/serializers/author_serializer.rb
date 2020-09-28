class AuthorSerializer < ActiveModel::Serializer
  attributes :id, :name, :bio, :discount
  has_many :books
  has_many :published
end
