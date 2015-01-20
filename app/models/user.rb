class User < ActiveRecord::Base
  has_many :trainings, dependent: :destroy
  has_many :snapshots, class_name: 'Training::Snapshot', through: :trainings

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

