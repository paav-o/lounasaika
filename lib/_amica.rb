# encoding: utf-8

class Amica
  def self.get_meals(data, meals)
    index = 0

    data["LunchMenus"].each do |day|
      menu = day["SetMenus"][0]
      meals.first.last[index] = []

      if menu
        menu["Meals"].each do |meal|
          begin 
            meals.first.last[index] = [] unless meals.first.last[index].any?
            meals.first.last[index] << meal["Name"] if meal["Name"].present?
          rescue Exception => e
            puts e.message
          end
        end
      end
      index += 1
    end

    meals.first.last.reject!(&:empty?) if meals.first.last.present?
    return meals
  end
end