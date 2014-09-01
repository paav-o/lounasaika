# encoding: utf-8

class Amica
  def self.get_meals(data, meals)
    index = 0

    days = ["Maanantai", "Tiistai", "Keskiviikko", "Torstai", "Perjantai", "Lauantai", "Sunnuntai"]

    data["LunchMenus"].each do |day|
      menus = day["SetMenus"]

      menus.each do |menu|

        if day["DayOfWeek"].present?
          index = days.find_index(day["DayOfWeek"])

          if menu and not index.nil?
            meals.first.last[index] = [] if meals.first.last[index].nil?
            menu["Meals"].each do |meal|
              begin 
                meals.first.last[index] = [] unless meals.first.last[index].any?
                meals.first.last[index] <<  "#{meal['Name']} (#{meal['Diets'].join(', ')})" if meal["Name"].present?
              rescue Exception => e
                puts e.message
              end
            end
          end
        end
      end
    end
    
    meals.first.last.reject!(&:empty?) if meals.first.last.present?
    return meals
  end
end