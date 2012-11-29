# encoding: utf-8

class HysnOsakuntabaari
  def self.get_meals(data, meals)
    index = 0

    data = data.at_css("#content").search('//tr/td[3]').each_with_index do |day,index|
      weekday = Time.now.wday + index
      meals.first.last[weekday] = []

      day.text.split(/\r\n/).each do |meal|
        meal = meal.gsub(/Ã¤/, "ä").gsub(/Ã¶/, "ö").strip
        meals.first.last[weekday] << meal
      end
    end

    meals[meals.first.first] = meals.first.last[1..5]

    return meals
  end
end