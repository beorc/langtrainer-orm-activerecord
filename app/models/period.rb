class Period
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  attr_reader :id, :slug, :title

  OneDay = 0
  ThreeDays = 1
  OneWeek = 2
  OneMonth = 3
  OneYear = 4

  def self.all
    periods
  end

  def self.find(param)
    return nil if param.nil?
    periods.select { |lang| lang.slug.to_s == param.to_s }.first || periods[param.to_i]
  end

  def self.default
    find(OneWeek)
  end

  def initialize(hsh = {})
    @id = hsh[:id]
    @slug = hsh[:slug]
    @title = hsh[:title]
  end

  def to_param
    slug
  end

  def to_i
    id
  end

  def to_class_name
    'Period'
  end

  def persisted?
    true
  end

  def ==(obj)
    return obj == id if obj.is_a? Fixnum
    super
  end

  private

  def self.periods
    @periods ||= [
      Period.send(:new, id: OneDay, slug: :one_day, title: I18n.t('periods.one_day')),
      Period.send(:new, id: ThreeDays, slug: :three_day, title: I18n.t('periods.three_days')),
      Period.send(:new, id: OneWeek, slug: :one_week, title: I18n.t('periods.one_week')),
      Period.send(:new, id: OneMonth, slug: :one_month, title: I18n.t('periods.one_month')),
      Period.send(:new, id: OneYear, slug: :one_year, title: I18n.t('periods.one_year')),
    ]
  end
end
