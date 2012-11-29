class Taffa
  def self.get_meals(data, meals)
    data.at_css("#mainContentNoLeft").at_css("#page").css("ul").each_with_index do |day,index|
      weekday = Time.now.wday + index
      meals.first.last[weekday] = []

      day.css("li").each do |meal|
        meals.first.last[weekday] << meal.text.strip
      end
    end

    meals[meals.first.first] = meals.first.last[1..5]

    return meals
  end
end