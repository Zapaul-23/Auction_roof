# A product is created as a draft and becomes visible to buyers once the
# seller publishes it. Publishing requires every wizard step to be complete.
module Product::Publishing
  extend ActiveSupport::Concern

  included do
    enum :status, { draft: "draft", published: "published" }, default: :draft, validate: true

    scope :live, -> { published.order(published_at: :desc) }
  end

  # Messages explaining what is still missing before the product can go live.
  def publish_blockers
    valid?(:publish) ? [] : errors.full_messages
  end

  def publishable?
    draft? && publish_blockers.empty?
  end

  def publish
    return false unless draft?

    self.status = :published
    self.published_at = Time.current
    save(context: :publish).tap do |saved|
      unless saved
        self.status = :draft
        self.published_at = nil
      end
    end
  end

  def unpublish
    published? && update(status: :draft, published_at: nil)
  end
end
