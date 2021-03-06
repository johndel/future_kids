class Schedule < ActiveRecord::Base
  belongs_to :person, polymorphic: true

  validates_numericality_of :day, only_integer: true,
                                  greater_than_or_equal_to: 1, less_than_or_equal_to: 5
  validates_numericality_of :hour, only_integer: true,
                                   greater_than_or_equal_to: 0, less_than_or_equal_to: 23
  validates_numericality_of :minute, only_integer: true,
                                     greater_than_or_equal_to: 0, less_than_or_equal_to: 59

  validates_uniqueness_of :person_id, scope: [:person_type, :day, :hour, :minute]

  validates_presence_of :person

  # overwrite == to simplificate comparison of collections
  def ==(other)
    other.is_a?(Schedule) &&
      day == other.day && hour == other.hour && minute == other.minute
  end

  # builds schedule entries for one week ordered by time
  # returns an array containing arrays for each day
  # [ [schedule_day_1, another_schedule_day_1 ]
  #   [schedule_day_2, another_schedule_day_2 ] ]
  def self.build_week
    (1..5).map do |day|
      (13..19).map do |hour|
        minutes = (hour == 19) ? [0] : [0, 30] # 19:30 does not exist
        minutes.map do |minute|
          Schedule.new(day: day, hour: hour, minute: minute)
        end
      end.flatten
    end
  end

  def human_day
    return nil if day.nil?
    I18n.t('date.day_names')[day]
  end

  def human_hour
    return nil if hour.nil?
    '%02d' % hour
  end

  def human_minute
    return nil if minute.nil?
    '%02d' % minute
  end

  # an array to store a string for each mentor that is availabel at the given
  # day. used when displaying a kids schedule including selected mentor's
  # availability
  def mentor_tags
    @mentor_tags ||= []
  end
end
