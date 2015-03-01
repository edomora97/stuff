#!/usr/bin/env ruby

require 'nokogiri'
require 'awesome_print'
require 'json'

courses = {}

if File.exist?('courses.json')
	data = File.read 'courses.json'
	courses = JSON.parse data
else
	data = `wget -q --load-cookies=cookies.txt -O - https://www.codeschool.com/courses | egrep -o '/courses/[^"]*|/paths/[^"]*' | sed -n -E 's/\\/(paths|courses)\\/(.*)/\\2/p' | egrep -o "^[a-zA-Z0-9\-]+$"`
	data = data.split(/\r?\n/)

	i = 0
	value = nil


	data.each do |elem|
		if i % 4 == 0
			value = elem
		elsif i % 4 == 1
			courses[elem] = {} unless courses[elem]
			courses[elem][value] = {}
		end
		i += 1
	end

	courses.each do |lang, c|
		puts ""
		puts "PROCESSING LANGUAGE #{lang}"
		puts ""
		c.each do |course, value|
			puts "COURSE=#{course}"

			page=`wget -q --load-cookies=cookies.txt -O - https://www.codeschool.com/courses/#{course}/videos`
			page = Nokogiri::HTML(page)

			courses[lang][course]['levels'] = []
			levels = page.css('.level')
			levels.each do |level|
				l = {
					'title' => level.css('.level-title').text.strip.gsub(/ - /, '-').gsub(/\s+/, "_"),
					'videos' => []
				}

				videos = level.css('li.video-title')
				videos.each do |video|
					l['videos'] << video.css('video.cs-video-player > source')[0]['src']
				end

				courses[lang][course]['levels'] << l
			end
		end
	end

	File.open('courses.json', 'w') { |file| file.write(courses.to_json) }
end

courses.each do |lang, crses|
	`mkdir -p videos/#{lang}`
	crses.each do |course, levels|
		levels = levels['levels']
		`mkdir -p videos/#{lang}/#{course}`
		levels.each do |level|
			title = level['title']
			if level['videos'].length == 1
				puts "aria2c -s16 -x16 -k1M #{level['videos'][0]} -o videos/#{lang}/#{course}/#{title}.mp4 --allow-overwrite=false --auto-file-renaming=false -q 2>/dev/null"
			else
				level['videos'].each_with_index do |url, index|
				puts "aria2c -s16 -x16 -k1M #{level['videos'][0]} -o videos/#{lang}/#{course}/#{title}-Part#{index+1}.mp4 --allow-overwrite=false --auto-file-renaming=false -q 2>/dev/null"
				end
			end
		end
	end
end
