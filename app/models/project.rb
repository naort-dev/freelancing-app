# frozen_string_literal: true

class Project < ApplicationRecord
  include Searchable

  def as_indexed_json(_options = {})
    as_json(
      include: { categories: { only: :name } }
    )
  end

  settings index: { number_of_shards: 1 } do
    mapping dynamic: 'false' do
      indexes :categories, type: :nested do
        indexes :name
      end
    end
  end

  paginates_per 12

  belongs_to :user

  has_many :bids, dependent: :destroy
  has_many :project_categories, dependent: :destroy
  has_many :categories, through: :project_categories
  has_many :notifications, dependent: :destroy

  has_one_attached :design_document
  has_one_attached :srs_document

  validates :categories, presence: true
  validates :title, presence: true, length: { maximum: 64 }
  validates :description, length: { maximum: 1024 }

  delegate :username, to: :user

  scope :editable_by, ->(user) { where(user:).or(where(user: User.where(role: 'admin'))) }

  default_scope { order(created_at: :desc) }

  def bid_awarded?
    bids.exists?(bid_status: 'accepted')
  end

  def accepted_bid_freelancer
    bids.where(bid_status: :accepted).first&.user
  end

  # rubocop:disable Metrics/MethodLength
  def self.search_projects(category_name)
    search_definition = {
      size: 1000,
      query: {
        bool: {
          must: [
            {
              nested: {
                path: 'categories',
                query: if category_name.present?
                         {
                           match_phrase: {
                             'categories.name': category_name
                           }
                         }
                       else
                         {
                           match_all: {}
                         }
                       end
              }
            }
          ]
        }
      }
    }

    __elasticsearch__.search(search_definition)
  end
  # rubocop:enable Metrics/MethodLength
end
