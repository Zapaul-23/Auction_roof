class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :products, foreign_key: :seller_id, inverse_of: :seller, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
