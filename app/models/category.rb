class Category < ApplicationRecord
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :profiles

  validates :name, presence: true, uniqueness: true
end
