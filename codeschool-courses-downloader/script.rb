#!/usr/bin/env ruby

# PREREQUISITES:
#  - some gems installed: nokogiri awesome_print
#  - the cookies.txt file. Please use 'cookie.txt export' chrome plugin

require 'nokogiri'
require 'awesome_print'
require 'json'

courses = {}
language_filter = nil
course_filter = nil

# if the index exists don't try to regenerate it!
if File.exist?('courses.json')
	data = File.read 'courses.json'
	courses = JSON.parse data
else
	# fetch the list of the courses
	data = `wget -q --load-cookies=cookies.txt -O - https://www.codeschool.com/courses`
	data = Nokogiri::HTML(data)

	# extract the courses title
	titles = data.css('.course-title')
	titles.each do |title|
		links = title.css('a')

		course = links[0]['href']
		lang = links[1]['href']

		course = course.slice(9..course.length)
		lang = lang.slice(7..lang.length)

		# apply filters if specified
		next if language_filter && lang != language_filter
		next if course_filter && course != course_filter

		courses[lang] = {} unless courses[lang]
		courses[lang][course] = {}
	end

	# process each language sequentially
	courses.each do |lang, c|
		puts "PROCESSING LANGUAGE #{lang}"
		# for each language process each course
		c.each do |course, value|
			puts "COURSE: #{course}"

			# fetch the course page
			page=`wget -q --load-cookies=cookies.txt -O - https://www.codeschool.com/courses/#{course}/videos`
			page = Nokogiri::HTML(page)

			courses[lang][course]['levels'] = []

			levels = page.css('.level')
			levels.each do |level|
				l = {
					# format the course title to a simpler format
					'title' => level.css('.level-title').text.strip.gsub(/ - /, '-').gsub(/\s+/, "_").gsub(/,/, ""),
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

	# save the list of courses in courses.json file
	File.open('courses.json', 'w') { |file| file.write(courses.to_json) }
end

lang_idx = 1
courses.each do |lang, crses|
	puts "[#{lang_idx}/#{courses.length}] Downloading language #{lang}"
	lang_idx += 1
	course_idx = 1

	crses.each do |course, levels|
		levels = levels['levels']
		puts "   [#{course_idx}/#{crses.length}] Downloading course #{course}"
		course_idx += 1
		video_idx = 1
		video_count = levels.inject(0) { |count, level| count + level['videos'].length }

		`mkdir -p videos/#{lang}/#{course}`
		levels.each do |level|
			title = level['title']

			# if the level has only one video, dont append the -PartX
			if level['videos'].length == 1
				puts "      [#{video_idx}/#{video_count}] Downloading video #{title}.mp4"
				video_idx += 1
				`aria2c -s16 -x16 -k1M #{level['videos'][0]} -o videos/#{lang}/#{course}/#{title}.mp4 --allow-overwrite=false --auto-file-renaming=false -q 2>/dev/null`
			else
				level['videos'].each_with_index do |url, index|
					puts "      [#{video_idx}/#{video_count}] Downloading video #{title}-Part#{index+1}.mp4"
					video_idx += 1
					`aria2c -s16 -x16 -k1M #{level['videos'][0]} -o videos/#{lang}/#{course}/#{title}-Part#{index+1}.mp4 --allow-overwrite=false --auto-file-renaming=false -q 2>/dev/null`
				end
			end
		end
	end
end
