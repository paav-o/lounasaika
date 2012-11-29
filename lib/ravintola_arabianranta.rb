# encoding: utf-8

class RavintolaArabianranta
  def self.get_meals(data)
    meals = []
    index = 0

    data.at_css("#mid-column").search('//table/tbody/tr/td[2]').each do |row|
      if row =~ / /
        index += 1
        meals[index] = []
      else
        meals[index] = [] unless meals[index].present?
        meals[index] << row.text.gsub("\r\n", "").strip if row.present?
      end
    end
    meals = meals.slice(2..6)
    return meals
  end
end