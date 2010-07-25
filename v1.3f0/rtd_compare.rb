#!/usr/bin/ruby
require 'rubygems'
require 'hpricot'
require 'open-uri'

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

def process_type_and_url(type,url)

  puts "Processing #{type}"
  line, direction, day_type = type.split("_")
  
  output_file = File.new("#{line}_#{direction}_#{day_type}.new","w")
  
  doc = open(url) {|f| Hpricot(f) }
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
	    #puts "In next day at #{stoptime} with previousTime: #{previousTime}"
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

lines_to_urls = Hash.new
#D Line
lines_to_urls["D_N_W"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SW&branch=D&&direction=N-Bound&serviceType=3"
lines_to_urls["D_N_S"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SW&branch=D&&direction=N-Bound&serviceType=1"
lines_to_urls["D_N_H"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SW&branch=D&&direction=N-Bound&serviceType=2"
lines_to_urls["D_S_W"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SW&branch=D&&direction=S-Bound&serviceType=3"
lines_to_urls["D_S_S"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SW&branch=D&&direction=S-Bound&serviceType=1"
lines_to_urls["D_S_H"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SW&branch=D&&direction=S-Bound&serviceType=2"

#C Line
lines_to_urls["C_N_W"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SW&branch=C&&direction=N-Bound&serviceType=3"
lines_to_urls["C_N_S"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SW&branch=C&&direction=N-Bound&serviceType=1"
lines_to_urls["C_N_H"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SW&branch=C&&direction=N-Bound&serviceType=2"
lines_to_urls["C_S_W"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SW&branch=C&&direction=S-Bound&serviceType=3"

#E Line
lines_to_urls["E_N_W"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SE&branch=E&&direction=N-Bound&serviceType=3"
lines_to_urls["E_N_S"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SE&branch=E&&direction=N-Bound&serviceType=1"
lines_to_urls["E_N_H"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SE&branch=E&&direction=N-Bound&serviceType=2"
lines_to_urls["E_S_W"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SE&branch=E&&direction=S-Bound&serviceType=3"
lines_to_urls["E_S_S"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SE&branch=E&&direction=S-Bound&serviceType=1"
lines_to_urls["E_S_H"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SE&branch=E&&direction=S-Bound&serviceType=2"

#F Line
lines_to_urls["F_N_W"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SE&branch=F&&direction=N-Bound&serviceType=3"
lines_to_urls["F_S_W"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SE&branch=F&&direction=S-Bound&serviceType=3"
lines_to_urls["F_S_S"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SE&branch=F&&direction=S-Bound&serviceType=1"
lines_to_urls["F_S_H"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SE&branch=F&&direction=S-Bound&serviceType=2"

#H Line
lines_to_urls["H_N_W"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SE&branch=H&&direction=N-Bound&serviceType=3"
lines_to_urls["H_N_S"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SE&branch=H&&direction=N-Bound&serviceType=1"
lines_to_urls["H_N_H"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SE&branch=H&&direction=N-Bound&serviceType=2"
lines_to_urls["H_S_W"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SE&branch=H&&direction=S-Bound&serviceType=3"
lines_to_urls["H_S_S"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SE&branch=H&&direction=S-Bound&serviceType=1"
lines_to_urls["H_S_H"] = "http://www3.rtd-denver.com/schedules/getSchedule.action?runboardId=101&routeId=101&routeType=2&lineName=SE&branch=H&&direction=S-Bound&serviceType=2"

lines_to_urls.each { |key,url| process_type_and_url(key,url)}

lines_to_urls.each_key do |key|
  system "diff #{key}.new #{key}.txt > #{key}.diff"
  file_contents = File.read("#{key}.diff")
  #puts file_contents[0..10]
  if file_contents.length > 0
    puts "#{key} has differences"
  end
end
  
