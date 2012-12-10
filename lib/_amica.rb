# encoding: utf-8

class Amica
  def self.get_meals(data, meals)
    index = 0
    days_regexp = /maanantai|tiistai|keskiviikko|torstai|perjantai|lauantai|ruokahalua|monday|tuesday|wednesday|thursday|friday|saturday|enjoy/mi

    if data.at_css("#Ruokalista").present?
      data = data.at_css("#Ruokalista")
    else
      data = data.at_css("#Menu")
    end
    
    data.css(".ContentArea")[1].css("p").each do |day|
      if day.text.length > 100
        day.search("br").each { |br| br.replace("\n") }
        meals.first.last[index] = []

        day.text.gsub(/(.*?)(maanantai)/mi, '').split(/\n/).each do |meal|
          meal = meal.strip
                     .gsub(/(\S\))/, '\1, ')
                     .gsub(/, ,/, ", ")
                     .gsub(/, +$/, "")
                     .gsub(/,  $/, "")
                     .gsub(/,  $/, "")
                     .gsub(/ $/, "")
          meal.slice!("Hyvää ruokahalua!")

          if meal =~ days_regexp
            index += 1
            meals.first.last[index] = []
          else
            meals.first.last[index] << meal if meal.present?
          end

        end

        index += 1
      end
    end

    # Those few restaurants using a table, like Meccala
    if meals.first.last.length < 3
      index = 0
      data.css(".ContentArea")[1].search('//tr/td/p').each do |row|

        row = row.text.strip
                      .gsub(/(\S\))/, '\1, ')
                      .gsub(/, +$/, "")

        if row =~ days_regexp
          index += 1
          meals.first.last[index] = []
        else
          meals.first.last[index] = [] unless meals.first.last[index].present?
          meals.first.last[index] << row if row.present?
        end
        
      end
      meals[meals.first.first] = meals.first.last[1..5]
    end

    meals.first.last.reject!(&:empty?) if meals.first.last.present?

    return meals
  end
end