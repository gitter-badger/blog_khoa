class Article < ActiveRecord::Base

  validates :title, presence: true
  validates :short_content, length: { maximum: 500 }

  include Tire::Model::Search
  include Tire::Model::Callbacks
  index_name "confession_#{Rails.env}"

  extend FriendlyId
  friendly_id :article_url_slug, use: [:slugged, :finders]

  def article_url_slug
    title.to_url
  end

  default_scope lambda { order(created_at: :desc) }

  def related_articles(number = 3)
    self.class.where.not(id: id).limit(number)
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  mapping do
    indexes :id, type: 'integer'
    indexes :title, type: 'string', analyzer: 'snowball', boost: 5
    indexes :title_latin, as: 'title.to_url', type: 'string', analyzer: 'snowball', boost: 5
    indexes :content, type: 'string', analyzer: 'snowball'
    indexes :content_latin, as: 'content.to_url', type: 'string', analyzer: 'snowball'
    indexes :short_content, type: 'string', analyzer: 'snowball'
    indexes :short_content_latin, as: 'short_content.to_url', type: 'string', analyzer: 'snowball'
    indexes :feature_image, as: 'feature_image.url(:medium)', type: 'string'
    indexes :created_at, type: 'date'
    indexes :slug, index: :not_analyzed
  end

  class << self
    def search(search_params = {})
      tire.search do
        query do
          if search_params[:query].present? && search_params[:query] != '-'
            string search_params[:query], fields: %W(title title_latin short_content short_content_latin content content_latin)
          else
            all
          end
        end

        sort do
          by :created_at, 'desc'
        end
      end
    end

    def decode(params)
      params.gsub('-', ' ')
    end
  end

  rails_admin do
    edit do
      field :title
      field :short_content
      field :content, :ck_editor
    end
  end
end
