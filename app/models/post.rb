class Post < ApplicationRecord
  belongs_to :account

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :plaintext_body, presence: true
  validates :html_body, presence: true
  validates :state, presence: true, inclusion: { in: %w[draft published deleted] }

  scope :published, -> { where(state: "published") }
  scope :draft, -> { where(state: "draft") }
  scope :newest_first, -> { order(published_at: :desc, created_at: :desc) }

  before_validation :generate_slug, on: :create
  before_validation :generate_html_body

  def published?
    state == "published"
  end

  def draft?
    state == "draft"
  end

  def publish!
    update!(
      state: "published",
      published_at: Time.current,
      activity_pub_object_uri: "#{Tsuzuri.base_url}/posts/#{id}",
      activity_pub_create_activity_uri: "#{Tsuzuri.base_url}/posts/#{id}#create"
    )
  end

  def mark_deleted!
    update!(
      state: "deleted",
      activity_pub_delete_activity_uri: "#{Tsuzuri.base_url}/posts/#{id}#delete-#{SecureRandom.hex(8)}"
    )
  end

  private

  def generate_slug
    return if slug.present?
    return unless title.present?

    base_slug = title.parameterize
    base_slug = "post-#{SecureRandom.hex(4)}" if base_slug.blank?

    candidate = base_slug
    counter = 2
    while Post.where(slug: candidate).where.not(id: id).exists?
      candidate = "#{base_slug}-#{counter}"
      counter += 1
    end
    self.slug = candidate
  end

  def generate_html_body
    return unless plaintext_body.present?
    return if html_body.present? && !plaintext_body_changed?

    self.html_body = plaintext_to_html(plaintext_body)
  end

  def plaintext_to_html(text)
    paragraphs = text.strip.split(/\n{2,}/)
    paragraphs.map { |p| "<p>#{ERB::Util.html_escape(p).gsub("\n", "<br>")}</p>" }.join("\n")
  end
end
