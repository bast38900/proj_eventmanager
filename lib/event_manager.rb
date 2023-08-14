puts "--- Event Manager 2.0 Initialized! ---\n\n"

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
  )

def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, '0')[0..4]
end

# method for claning numbers
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
  
#   contents.each do |row|
#     id = row[0]
#     name = row[:first_name]
#     zipcode = clean_zipcode(row[:zipcode])
#     legislators = legislators_by_zipcode(zipcode)
  
#     form_letter = erb_template.result(binding)
  
#     save_thank_you_letter(id,form_letter)
#   end

# ? Testing method
contents.each do |row|
    name = row[:first_name] # => show names
    zipcode = clean_zipcode(row[:zipcode])
    homephone = clean_homephone(row[:homephone]) 


    puts "#{name}, #{homephone}"
end