class Data

  def self.final(url)
    @sum = 0
    @total_number = 0
    Data.information(url)
    puts "\nAverage budget for winning movie(in US Dollars): $#{(@sum / @total_number).round.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse}"
  end

  def self.information(url)
    get_data(url)["results"].each do |result|
      result["films"].each do |film|
        # It looks like the winners are always listed first, but just checking in case that changes later
        film["Winner"] ? winner_results = get_data(film["Detail URL"]) : next
        # Some movies do not have a budget
        winner_results["Budget"] ? get_budget(result, winner_results) : (puts "#{result["year"][0..8].gsub(/\[.+/, '').gsub(/\(.+/, '').strip}-#{winner_results["Title"]}-No Budget found")
      end
    end
  end

  # Get data from API
  def self.get_data(url)
    response = HTTParty.get(url)
    response.parsed_response
  end

  def self.get_budget(result, winner_results)
    get_combination(result, winner_results)
    us_currency
    brit_currency
    @sum += @budget
    @total_number += 1
  end

  # Create combination of Year-Title-Budget
  def self.get_combination(result, winner_results)
    # Keep both years if the year is a range. I am not sure if this might be important later on.  Remove any other information and trailing spaces
    year = result["year"][0..8].gsub(/\[.+/, '').gsub(/\(.+/, '').strip
    # Remove trailing spaces and brackets in titles
    title = winner_results["Title"].gsub(/\[.+/, '').strip
    # Remove brackets and parenthesis from budget, remove 'US' from the first movie budget, remove any spaces between '$' or '£' and the number, remove everything after 'or', as well as any trailing spaces
    if winner_results["Budget"].include?('$')
      @budget = "$#{winner_results["Budget"].gsub(/\s\[.+/, '').gsub(/\(.+/, '').gsub("US", '').gsub(/or.+/,'').sub(/\$/, '').strip}"
    elsif winner_results["Budget"].include?('£')
      @budget = "£#{winner_results["Budget"].gsub(/\s\[.+/, '').gsub(/\(.+/, '').gsub("US", '').gsub(/or.+/,'').sub(/\£/, '').strip}"
    end
    puts "#{year}-#{title}-#{@budget}"
  end

  # Change 'million' to be numerical and remove '$'
  def self.us_currency
    if @budget.class == String && @budget.include?("million") && @budget.include?('$')
      @budget = @budget.sub('million', '').sub('$', '').strip.to_f * 1000000
    elsif @budget.class == String && @budget.include?("$")
      @budget = @budget.gsub(',', '').sub('$', '').to_i
    end
  end

  # If British pounds are the currency, change 'million' to be numerical and remove '£'
  def self.brit_currency
    if @budget.class == String && @budget.include?("million") && @budget.include?('£')
      @budget = @budget.sub('million', '').sub('£', '').strip.to_f * 1000000 * 1.29
    elsif @budget.class == String && @budget.include?("£")
      @budget = @budget.gsub(',', '').sub('£', '').to_i * 1.29
    end
  end
end
