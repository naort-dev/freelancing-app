# frozen_string_literal: true

class AddHasAwardedBidToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :has_awarded_bid, :boolean, default: false, null: false
  end
end
