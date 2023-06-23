class Bid < ApplicationRecord
  attr_accessor :current_actor_id

  belongs_to :user
  belongs_to :project

  after_save :send_notifications

  validates :bid_name, presence: true

  enum bid_status: { pending: 0, accepted: 1, rejected: 2, awarded: 3 }

  delegate :email, to: :user

  scope :recent_by_user, ->(user) { where(user_id: user.id).order(created_at: :desc).limit(5) }

  def accept
    update(bid_status: 'accepted')
  end

  def reject
    update(bid_status: 'rejected')
  end

  def hold
    update(bid_status: 'pending')
  end

  def award
    update(bid_status: 'awarded')
    project.bids.where.not(id:).find_each { |b| b.update(bid_status: :rejected) }
  end

  def modifiable?
    bid_status == 'pending' || bid_status == 'accepted'
  end

  private

  def send_notifications
    return unless bid_status_changed?

    bid_project_title = Project.find_by(id: project_id).title

    Notification.create!(
      recipient_id: user_id,
      actor_id: current_actor_id,
      project_id:,
      bid_id: id,
      message: "Your bid for #{bid_project_title} is #{bid_status}",
      read: false
    )
    ActionCable.server.broadcast 'bid_notifications_channel', { recipient_id: user_id }
  end

  def bid_status_changed?
    saved_change_to_attribute?(:bid_status)
  end
end
