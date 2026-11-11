class Product < ApplicationRecord
  belongs_to :seller, class_name: "User", inverse_of: :products

  enum :condition, { brand_new: "new", like_new: "like_new", used: "used", for_parts: "for_parts" }, validate: true

  validates :title, presence: true, length: { maximum: 150 }
  validates :description, presence: true
  validates :starting_price, presence: true, numericality: { greater_than: 0 }
  validates :reserve_price, numericality: { greater_than_or_equal_to: :starting_price }, allow_nil: true,
            if: -> { starting_price.present? }
end
