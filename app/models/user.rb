class User < ActiveRecord::Base
  has_many :unit_advances, dependent: :destroy
  has_many :snapshots, class_name: 'Unit::Snapshot', through: :unit_advances

  validates :token, presence: true, uniqueness: true

  before_validate :generate_token, on: :create

  private

  def generate_token
    self.token = loop do
      token = SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz')
      break token if User.where(token: token).empty?
    end
  end
end

