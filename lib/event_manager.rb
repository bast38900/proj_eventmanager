puts "--- Event Manager 2.0 Initialized! ---\n\n"

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
  )

def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, '0')[0..4]
end

# method for cleaning numbers
def clean_homephone(homephone)
    # remove all non-numeric characters
    homephone.gsub!(/[^\d]/,'')
    # prints out perfectly formmatted phone number
    if homephone.length == 10
        homephone
    # removes leading 1 if present phone numbers with 11 digits
    elsif homephone.length == 11 && homephone[0] == "1"
        homephone[1..-1]
    else
        'bad number'
    end
end

#method to count the frequency of element in an array
def count_frequency(array)
    array.max_by {|arr| array.count(arr)}
end

# method to convert wday to day names
def wday_to_day(wday)
    case wday
    when 0
        "Monday"
    when 1
        "Tuesday"
    when 2
        "Wednesday"
    when 3
        "Thursday"
    when 4
        "Friday"
    when 5
        "Saturday"
    when 6
        "Sunday"
    end
end

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials

  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
    Dir.mkdir('output') unless Dir.exist?('output')
  
    filename = "output/thanks_#{id}.html"
  
    File.open(filename, 'w') do |file|
      file.puts form_letter
    end
  end
  
  template_letter = File.read('form_letter.erb')
  erb_template = ERB.new template_letter

# # ? Testing method assignment 1
# contents.each do |row|
#     name = row[:first_name] # => show names
#     zipcode = clean_zipcode(row[:zipcode])
#     homephone = clean_homephone(row[:homephone]) 

#     puts "#{name}, #{homephone}"
# end

# ? Testing method assignment 2
# arrays for registration information
arr_hours = []
arr_days = []

contents.each do |row|
    name = row[:first_name]
    regdate = row[:regdate]

    # get registration information and convert to DateTime object
    reg_info = DateTime.strptime(regdate, '%m/%d/%y %H:%M')
    
    # get hours and add to array
    time_of_day = reg_info.hour
    arr_hours.push(time_of_day)
    
    # get weeks and add to array
    day_of_week = reg_info.wday
    arr_days.push(day_of_week)

    puts "#{name}, registration date: #{regdate}"
end

puts "\nmost active registration hour: #{count_frequency(arr_hours)}"
puts "most active registration day: #{wday_to_day(count_frequency(arr_days))}"