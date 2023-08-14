puts "--- Event Manager Initialized! ---\n\n"

# TODO: Working with files

### Read all of the .csv file and put to screen
# contents = File.read('event_attendees.csv')
# puts contents

### Read the file, line by line, and print each line to screen
# lines = File.readlines('event_attendees.csv')
# lines.each do |line|
#     puts line
#   end

### Read the file, line by line, and print names, from second colum
# lines = File.readlines('event_attendees.csv')
# lines.each do |line|
#   columns = line.split(",")
#   name = columns[2]
#   puts name
# end

### same as above, but skipping the first column
# lines = File.readlines('event_attendees.csv')
# lines.each_with_index do |line,index|
#   next if index == 0
#   columns = line.split(",")
#   name = columns[2]
#   puts name
# end

require 'csv' # => loads the CSV library

### Method 1 to clean zipcode, not combined
# def clean_zipcode(zipcode)
#     # adds five zeros to zipcode if nil
#     if zipcode.nil? 
#       '00000'
#     # adds leading zeros to zipcode if less than 5 digits
#     elsif zipcode.length < 5 
#       zipcode.rjust(5, '0')
#     # reads only first 5 digits of zipcode, if more than 5 digits 7 c
#     elsif zipcode.length > 5 
#       zipcode[0..4]
#     # print perfect formatted zipcode
#     else
#       zipcode 
#     end
#   end

### Method 2 to clean zipcode, combined
def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, '0')[0..4]
end

### use the CSV library to read the file
contents = CSV.open(
    'event_attendees.csv',
    headers: true, # => read headers
    header_converters: :symbol # => convert header to symbols
  )
  
# contents.each do |row|
# name = row[:first_name] # => show names

# # show zipcodes without cleaning
# # zipcode = row[:zipcode] 

# # show zipcodes with cleaning method
# zipcode = clean_zipcode(row[:zipcode])

# puts "#{name} #{zipcode}"
# end

# TODO: Working with api (google)

require 'google/apis/civicinfo_v2' # => loads the Google APIs library

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

# find the associated legislators to event_attendes by zipcode
def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  #Exeption
  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
    # legislators = legislators.officials
    
    # # map through each legislator, and get their names => for iteration 3
    # legislator_names = legislators.map(&:name)
    # legislator_names.join(", ")

  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

# # method to print out names, zipcodes (from csv) and associated legislators (from Google API) => for iteration 3 assignment
# contents.each do |row|
#   name = row[:first_name]

#   zipcode = clean_zipcode(row[:zipcode])

#   legislators = legislators_by_zipcode(zipcode)

#   puts "#{name} #{zipcode} #{legislators}"
# end

# TODO: Working with ERB

# use ERB library, as a template system
require 'erb'

# method to create a letter, from a template
def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

# read from form_letter.erb
template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  # find id
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  # binding returns an object, that knows the state of variables and methods
  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
end