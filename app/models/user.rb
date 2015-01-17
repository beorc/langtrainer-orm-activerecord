class User < ActiveRecord::Base
  has_many :unit_advances, class_name: 'Unit::Advance', dependent: :destroy
  has_many :snapshots, class_name: 'Unit::AdvanceSnapshot', through: :unit_advances

  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create

  private

  def generate_token
    self.token ||= loop do
      token = SecureRandom.uuid
      break token if User.where(token: token).empty?
    end
  end
end

