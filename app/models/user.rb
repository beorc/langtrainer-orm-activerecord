class User < ActiveRecord::Base
  has_many :unit_advances, dependent: :destroy
  has_many :snapshots, class_name: 'Unit::Snapshot', through: :unit_advances

  validates :token, presence: true, uniqueness: true
end

