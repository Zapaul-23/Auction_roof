module Product::Images
  extend ActiveSupport::Concern

  IMAGE_CONTENT_TYPES = %w[ image/jpeg image/png image/webp ].freeze
  MAX_IMAGE_SIZE = 5.megabytes
  MAX_IMAGES = 10

  included do
    has_many_attached :images

    validate :images_are_acceptable
    validates :images, presence: { message: "must include at least one photo" }, on: :images
  end

  # Images in the order the seller arranged them; new uploads go last.
  def ordered_images
    positions = image_order.each_with_index.to_h
    images.attachments.select(&:persisted?).sort_by { |image| [ positions.fetch(image.id, Float::INFINITY), image.id ] }
  end

  def cover_image
    ordered_images.first
  end

  # direction: :up (earlier) or :down (later)
  def move_image(attachment_id, direction)
    ids = ordered_images.map(&:id)
    from = ids.index(attachment_id)
    return false if from.nil?

    to = direction.to_sym == :up ? from - 1 : from + 1
    return false unless to.between?(0, ids.size - 1)

    ids[from], ids[to] = ids[to], ids[from]
    update!(image_order: ids)
  end

  private
    def images_are_acceptable
      return unless images.attached?

      if images.attachments.size > MAX_IMAGES
        errors.add(:images, "can have at most #{MAX_IMAGES} photos")
      end

      images.attachments.each do |image|
        blob = image.blob
        unless IMAGE_CONTENT_TYPES.include?(blob.content_type)
          errors.add(:images, "#{blob.filename} must be a JPG, PNG or WebP image")
        end
        if blob.byte_size > MAX_IMAGE_SIZE
          errors.add(:images, "#{blob.filename} is larger than #{MAX_IMAGE_SIZE / 1.megabyte} MB")
        end
      end
    end
end
