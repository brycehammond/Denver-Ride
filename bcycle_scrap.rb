#!/usr/bin/ruby

require 'open-uri'
require 'net/smtp'

class Dock
  attr_accessor :lattitude, :longitude, :name, :bikes_available, :docks_available
  
  def to_s
    "#{lattitude}\t#{longitude}\t#{name}\t#{bikes_available}\t#{docks_available}"
  end  
end

docks = Array.new

current_dock = nil

open("https://denver.bcycle.com/").each do |line|
  if line =~ /var point = new google.maps.LatLng\((.*?), (.*?)\)\;/
    current_dock = Dock.new
    current_dock.lattitude = $1
    current_dock.longitude = $2
  elsif line =~ /var marker = new createMarker\(point, "<div class='markerTitle'><h3>(.*?)<\/h3><\/div>.*?<div class='markerAvail'>.*?<h3>(.*?)<\/h3>.*?<h3>(.*?)<\/h3>Docks.*?"/
    current_dock.name = $1
    current_dock.bikes_available = $2
    current_dock.docks_available = $3
    puts current_dock
  end
end