#!/usr/bin/ruby
require 'rubygems'
require 'hpricot'

def timeInMinutes(time)
  amOrPm = time[-1,1]
  number = time[0..-2].to_i
  hours = number / 100
  minutes = number % 100
  
  if amOrPm == "A"
    #if the hours is 12 then we are in the morning hours
    if hours == 12 then
      hours = 0
    end
  elsif amOrPm == "P"
    if hours != 12
      hours += 12
    end
  end
  
  return hours * 60 + minutes
  
end

class Stop
  attr_accessor :timeInMinutes, :direction, :dayType, :line, :station, :run, :terminalStation, :startStation
  
  def to_s
    if(not timeInMinutes or not direction or not dayType or not line or not station or not run or not terminalStation or not startStation)
      raise "Invalid stop: #{timeInMinutes},#{direction},#{dayType},#{line},#{station},#{run},#{terminalStation},#{startStation}"
    end  
    "#{timeInMinutes},#{direction},#{dayType},#{line},#{station},#{run},#{terminalStation},#{startStation}"
  end
end

@station_translation = Hash[
           /^Littleton Mineral/ =>  35,
           /^Littleton Downtown/ => 34,
           /^Oxford/ => 33,
           /^Englewood/ => 32, 
						/^Evans/ => 31,
						/^I-25/ => 14,
						/^Alameda/ => 15,
						/^10th \& Osage/ => 16,
						/^Auraria West/ => 27,
						/^Invesco/ => 28,
						/^Pepsi/ => 29,
						/^Union Station/ => 30,
						/^Colfax at Auraria/ => 17,
						/.*Convention Center.*/ => 18,
						/^16th \& California/ => 19,
            /^18th \& California/ => 20, 
            /^20th \& Welton/ => 23, 
            /^25th \& Welton/ => 24, 
            /^27th \& Welton/ => 36,
            /^29th \& Welton/ => 25, 
            /^30th \& Downing/ => 26, 
            /^18th \& Stout/ => 21,
            /^16th \& Stout/ => 22, 
            /^Lincoln/ => 6,
            /^County Line/ => 5,
            /^Dry Creek/ => 4,
            /^Arapahoe/ => 3,
            /^Orchard/ => 2,
            /^Belleview/ => 1,
            /^Southmoor/ => 7,
            /^Yale/ => 10,
            /^Colorado/ => 11,
            /^University of Denver/ => 12,
            /^Louisiana/ => 13,
            /^Nine Mile/ => 9,
            /^Dayton/ => 8
  
						]

def number_for_station(station)
  @station_translation.each do |key,value|
    return value if station =~ key
  end
  
  return 0
end

def process_file(file)
  elements = file.gsub(".html","").split(" ")
  line = elements[0]
  direction = elements[2]
  day_type = elements[3]

  if(day_type == "Saturday") then
    day_type = "S"
  elsif day_type == "Sunday" then
    day_type = "H"
  elsif day_type == "Weekday" then
    day_type = "W"
  end
  
  output_file = File.new("#{line}_#{direction}_#{day_type}.txt","w")
  
  doc = open(file) {|f| Hpricot(f) }
  stations = doc.search("//div[@class='scheduleStations']").map {|station| station.inner_html }
  in_next_day = false
  
  doc.search("//tr[@class='row']").each do |row|
    previousTime = ""
    run = row['id'].gsub("row","")
    runStops = Array.new
    station_index = 0
    row.search("//div[@class='scheduleTimesGrey']").each do |stop|
      station = stations[station_index]
      station_index += 1
      stoptime = stop.inner_html.gsub(/\(.*?\)/,"")
      next if stoptime == "--"
      stop = Stop.new
      stop.timeInMinutes = timeInMinutes(stoptime)
	  
	  #if we are moving from PM to AM then we are moving to the next day
	  #so add a full day	
	  if(previousTime.length > 0 and previousTime[-1,1] == "P" and stoptime[-1,1] == "A")
	    puts "In next day at #{stoptime} with previousTime: #{previousTime}"
		  in_next_day = true
	  end
	  
	  if(in_next_day and stoptime[-1,1] == "A")
	    if stop.timeInMinutes == 0
	      stop.timeInMinutes = 1440
	    elsif stop.timeInMinutes < 1440
		    stop.timeInMinutes = stop.timeInMinutes + 1440
		  end
	  end
	  
	    previousTime = stoptime
      stop.direction = direction
      stop.dayType = day_type
      stop.line = line
      stop.station = number_for_station(station)
      stop.run = run
      runStops << stop
    end

    terminalStation = runStops[runStops.length - 1].station
    startStation = runStops[0].station
    runStops.each do |stop| 
      stop.terminalStation = terminalStation
      stop.startStation = startStation
      output_file.puts stop
    end
  end
  
  output_file.close
end
						
ARGV.each { |file| process_file(file) }
