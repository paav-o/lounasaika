class Sodexo
  def self.get_meals(data, meals)
    json_path = data.css("div#action_links_wrapper").css("a.json")[0]["href"].gsub("daily_json", "weekly_json")
    data = JSON.parse(open("http://www.sodexo.fi"+json_path).read)

    meals.keys.each do |locale|
      data["menus"].each_with_index do |day,index|
        meals[locale][index] = []
        if day.last.first["title_#{locale}"].present?
          day.last.each do |meal|
            meal_with_allergy_info = [meal["title_#{locale}"], " (", meal["properties"], ")"].join.gsub(" ()", "")
            meals[locale][index] << meal_with_allergy_info.strip
          end
        end
      end
    end

    return meals
  end
end