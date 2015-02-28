require 'open-uri'
require 'json'
require 'base64'

token = ARGV.shift
puts token
$authorization = Base64.encode64(token+":")

def getJSONfromAPI(path)
    url = "https://api.github.com#{path}"
    puts "REQUEST: #{url}"
    data = open(url,
        "Authorization" => "Basic " + $authorization
        ).read
    JSON.parse data
end


###
# Parse the ARGV
###
ARGV.each do |p|
	arg = p.split(':')
	case arg[0]
		when 'max_repo' then $max_repo = arg[1].to_i
		when 'per_page' then $per_page = arg[1].to_i
		when 'lang'     then $lang = arg[1]
		when 'data'     then $data = arg[1]
		when 'debug'	then $debug = true
	end
end

$max_repo ||= 1000
$per_page ||= 100
$lang ||= 'C'
$data ||= 'data.csv'
$debug ||= false

$max_repo = [ [ $max_repo, 1000 ].min, 1 ].max
$per_page = [ [ $per_page, 100, $max_repo ].min, 1 ].max
$pages = ($max_repo.to_f/$per_page).ceil

$logFile = "log-#{Time.now.to_i}-#{$lang}.txt"

repo_number = 1

def download(repo, branch, path)
	beginDownload = Time.new()
	`wget https://github.com/#{repo}/archive/#{branch}.zip -O #{path}/#{branch}.zip -q`
	zipSize = `du #{path}/#{branch}.zip -h`.split('	')[0]
	return Time.new() - beginDownload, zipSize
end

def unzip(path, branch)
	beginUnzip = Time.new()
	`unzip -o -qq #{path}/#{branch}.zip -d #{path}/extr 2>>#{$logFile}`
	extrSize = `du #{path}/extr -hs`.split('	')[0]
	return Time.new()-beginUnzip, extrSize
end

def compute(path)
	beginComputation = Time.new()
	res = `./compute "#{path}/extr" 2>>#{$logFile}`
	return Time.new()-beginComputation, res
end

puts "/!\\ You are in DEBUG mode!" if $debug
puts "The results are based on edomora97 repositories!" if $debug


###
# Begin the computation
###
start = Time.new()

puts "Process starts at #{start}"
$pages.times do |page|
	puts "======> LOADING PAGE #{page+1}/#{$pages}"

	# fetch the repositories names from GitHub API
	result = if $debug
		getJSONfromAPI("/search/repositories?q=user:edomora97&per_page=2&page=#{page+1}")
	else
		getJSONfromAPI("/search/repositories?q=language:#{$lang}&per_page=#{$per_page}&page=#{page+1}")
	end

	result["items"].each do |elem|
		repo = elem["full_name"]
		language = elem["language"]
		branch = elem["default_branch"]
		path = "repos/#{repo}"

		puts "------> Downloading branch #{branch} of #{repo}... #{repo_number}/#{$max_repo}"
		`echo "======> REPOSITORY: #{repo}" >> #{$logFile}`

		# Setup the download folder
		`mkdir -p #{path}`
		`mkdir -p #{path}/extr`

		# Download the zip file
		downloadTime, zipSize = download(repo, branch, path)
		puts "   Download completed in #{downloadTime} sec (#{zipSize})"

		# Extract the zip file
		unzipTime, extrSize = unzip(path, branch)
		puts "   Extraction completed in #{unzipTime} sec (#{extrSize})"

		# Begin the computation
		computationTime, res = compute(path)
		puts "   Computation completed in #{computationTime} sec"

		# Save the data
		data = "#{repo},#{language},#{res},#{downloadTime},#{unzipTime},#{computationTime}"
		open($data, "a") { |file| file.puts data }

		# Remove the downloaded files
		`rm -r #{path}`

		repo_number += 1
	end
end

`rm -r repos`

finish = Time.new()
puts "Process ends at #{finish}"
puts "It took #{finish-start} sec"
