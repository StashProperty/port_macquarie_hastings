require 'faraday'
require 'json'
require 'ScraperWiki'

data_url = 'https://datracker.pmhc.nsw.gov.au/Application/GetApplications'

start_date = (Date.today - 14).strftime("%d/%m/%Y")
end_date = Date.today.strftime("%d/%m/%Y")

puts start_date
puts end_date
resp = Faraday.post(data_url) do |req|
		req.headers['Accept'] = 'application/json'
		req.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
		req.headers['Cookie'] = 'User=accessAllowed-MasterView=True'
		req.headers['Host'] = 'datracker.pmhc.nsw.gov.au'
		#req.body = "{
        #start: 0,
        #length: 9999,
        #json: {'DateFrom': #{start_date}, 'DateTo': #{end_date}, 'RemoveUndeterminedApplications': False, 'IncludeDocuments': False}}"
		#puts req
		req.body = "draw=1&columns%5B0%5D%5Bdata%5D=0&columns%5B0%5D%5Bname%5D=&columns%5B0%5D%5Bsearchable%5D=true&columns%5B0%5D%5Borderable%5D=false&columns%5B0%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B0%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B1%5D%5Bdata%5D=1&columns%5B1%5D%5Bname%5D=&columns%5B1%5D%5Bsearchable%5D=true&columns%5B1%5D%5Borderable%5D=false&columns%5B1%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B1%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B2%5D%5Bdata%5D=2&columns%5B2%5D%5Bname%5D=&columns%5B2%5D%5Bsearchable%5D=true&columns%5B2%5D%5Borderable%5D=false&columns%5B2%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B2%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B3%5D%5Bdata%5D=3&columns%5B3%5D%5Bname%5D=&columns%5B3%5D%5Bsearchable%5D=true&columns%5B3%5D%5Borderable%5D=false&columns%5B3%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B3%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B4%5D%5Bdata%5D=4&columns%5B4%5D%5Bname%5D=&columns%5B4%5D%5Bsearchable%5D=true&columns%5B4%5D%5Borderable%5D=false&columns%5B4%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B4%5D%5Bsearch%5D%5Bregex%5D=false&start=0&length=10&search%5Bvalue%5D=&search%5Bregex%5D=false&json=%7B%22ApplicationNumber%22%3Anull%2C%22ApplicationYear%22%3Anull%2C%22DateFrom%22%3A%2211%2F04%2F2021%22%2C%22DateTo%22%3A%2217%2F04%2F2021%22%2C%22DateType%22%3A%221%22%2C%22RemoveUndeterminedApplications%22%3Afalse%2C%22ApplicationDescription%22%3Anull%2C%22ApplicationType%22%3Anull%2C%22UnitNumberFrom%22%3Anull%2C%22UnitNumberTo%22%3Anull%2C%22StreetNumberFrom%22%3Anull%2C%22StreetNumberTo%22%3Anull%2C%22StreetName%22%3Anull%2C%22SuburbName%22%3Anull%2C%22PostCode%22%3Anull%2C%22PropertyName%22%3Anull%2C%22LotNumber%22%3Anull%2C%22PlanNumber%22%3Anull%2C%22ShowOutstandingApplications%22%3Afalse%2C%22ShowExhibitedApplications%22%3Afalse%2C%22PropertyKeys%22%3Anull%2C%22PrecinctValue%22%3Anull%2C%22IncludeDocuments%22%3Afalse%7D"
end

data = JSON.parse(resp.body)['data']

data.each do |row|
	record = {}
	info_link_number = row[0]
	record['info_url'] = 'https://datracker.pmhc.nsw.gov.au/application/applicationdetails/'+ info_link_number + '/'
	record['council_reference'] = row[1]
	record['date_received'] = row[3]
	record['date_scraped'] = end_date
	raw_description = row[4].split("/<.{1,5}>/")
	record['address'] = raw_description[0].strip()
	record['description'] = raw_description[2]
	puts "Saving " + record['council_reference']
	ScraperWiki.save_sqlite(['council_reference'], record)
end