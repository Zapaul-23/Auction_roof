class Product < ApplicationRecord
  include Product::Images

  # Order of the "create product" wizard. Each step validates its own fields.
  STEPS = %w[ details images pricing ].freeze

  belongs_to :seller, class_name: "User", inverse_of: :products
  belongs_to :category

  enum :condition, { brand_new: "new", like_new: "like_new", used: "used", for_parts: "for_parts" }, validate: true

  # details step (always required)
  validates :title, presence: true, length: { maximum: 150 }
  validates :description, presence: true

  # pricing step: a price is optional while the seller is still on earlier
  # steps, but once given it must make sense.
  validates :starting_price, presence: true, on: :pricing
  validates :starting_price, numericality: { greater_than: 0 }, allow_nil: true
  validates :reserve_price, numericality: { greater_than_or_equal_to: :starting_price }, allow_nil: true,
            if: -> { starting_price.present? }

  def self.next_step(step)
    STEPS[STEPS.index(step.to_s) + 1]
  end

  def self.previous_step(step)
    index = STEPS.index(step.to_s)
    STEPS[index - 1] if index.positive?
  end

  def priced?
    starting_price.present?
  end
end
