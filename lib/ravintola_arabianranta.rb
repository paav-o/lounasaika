# encoding: utf-8

class RavintolaArabianranta
  def self.get_meals(data, meals)
    index = 0

    data.at_css("#mid-column").search('//table/tbody/tr/td[2]').each do |row|
      if row.text.eql? "\r\n \r\n"
        index += 1
        meals["fi"][index] = []
        meals["en"][index] = []
      else
        meals["fi"][index] = [] unless meals["fi"][index].present?
        meals["en"][index] = [] unless meals["en"][index].present?

        if row.text.strip.present?
          title = row.text.gsub("\r\n", "").strip
          meals["fi"][index] << title.split("/").first
          meals["en"][index] << title.split("/").last
        end
      end
    end
    meals["fi"] = meals["fi"].slice(2..6)
    meals["en"] = meals["en"].slice(2..6)
    return meals
  end
end