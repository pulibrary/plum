# frozen_string_literal: true
class DateValue
  def initialize(values)
    @values = values || []
  end

  def to_a
    Array(@values).map do |value|
      format_date(value)
    end
  end

  private

    def format_date(date)
      date.split("/").map do |d|
        if year_only(date.split("/"))
          Date.parse(d).strftime("%Y")
        else
          Date.parse(d).strftime("%m/%d/%Y")
        end
      end.join("-")
    end

    def year_only(dates)
      dates.length == 2 && dates.first.end_with?("-01-01T00:00:00Z") && dates.last.end_with?("-12-31T23:59:59Z")
    end
end
