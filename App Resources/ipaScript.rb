require 'fileutils.rb'
require 'rubygems'
require 'plist'
require 'zip/zip'
require 'optparse'



#USAGE: ruby ipaScript.rb Project_Name Relative_Path_to_iTunesArtwork

# Before use, you must install the following gems:
#   plist ("sudo gem install plist" from Terminal)

class ExecutablesMaker

BUILD_FOLDER_PATH = ENV['CONFIGURATION_BUILD_DIR']
BINARY_EXTENSION = "app"
DSYM_EXTENSION = "app.dSYM"

def initialize(application_name, plist_path, original_itunes_artwork_path, provisioning_profile)

  @application_name = application_name
  @plist_path = plist_path
  @original_itunes_artwork_path = original_itunes_artwork_path || "App Resources/Icons/iTunesArtwork"
  @provisioning_profile = provisioning_profile
  
  ### Pull the plist into a Hash ###
  
  # Modify this path if you move Info.plist from the root project folder
  plist_hash = Plist::parse_xml(@plist_path)
  
  # Pull the current version number from the plist hash. It will be used to name the ipa #
  @current_version = plist_hash["CFBundleVersion"] # Example: v1.0b20
  
  # Pull the current bundle identifier. It will be used to create a folder w/in the Executables. 
  @bundle_identifier = plist_hash["CFBundleIdentifier"] # Example: "com.fluidvisiondesign.app"
  
  # Clear out old directory (if necessary)
  FileUtils.remove_dir "Executables/#{@bundle_identifier}", :force => true
  
end

### Make sure build configuration is set correctly ###
def verifyBuildConfig
  # Make sure you're building with the "Distribution" configuration
  if (ENV['BUILD_STYLE'] != "Distribution") then
    abort("Build style is #{ENV['BUILD_STYLE']}, not Distribution. Aborting.")
  # Make sure you're building to the Device, not the Simulator
  elsif (ENV['PLATFORM_NAME'] != "iphoneos") then
    abort("Platform name is #{ENV['PLATFORM_NAME']}, not iphoneos. Aborting.")
  end
end

### Create the .ipa ###
def createIPA
  root_folder_path = "Executables/#{@bundle_identifier}"

  # The folder that will eventually be zipped into an ipa
  ipa_folder_path = "#{root_folder_path}/#{@application_name}_#{@current_version}"
  
  # Make the payload folder
  payload_folder_path = "#{ipa_folder_path}/Payload"
  FileUtils.mkdir_p payload_folder_path
  
  # Move the binary to the payload folder
  binary_name = "#{@application_name}.#{BINARY_EXTENSION}"
  FileUtils.cp_r "#{BUILD_FOLDER_PATH}/#{binary_name}", "#{payload_folder_path}/#{binary_name}"
  
  # Create a copy of the icon image with the iTunesArtwork name
  ipa_itunes_artwork_path = "#{ipa_folder_path}/iTunesArtwork"
  FileUtils.cp @original_itunes_artwork_path, ipa_itunes_artwork_path
  
  # compress the ipa folder
  system("cd '#{ipa_folder_path}'; /usr/bin/zip -r \"../#{@application_name}_#{@current_version}_no_embedded_provision.ipa\" Payload iTunesArtwork")
  
  #embed the provisioning profile if we have one
  if nil != @provisioning_profile
    FileUtils.cp @provisioning_profile, "#{ipa_folder_path}/Payload/embedded.mobileprovision"
    FileUtils.cp @provisioning_profile, "#{ipa_folder_path}/../#{File.basename(@provisioning_profile)}"
    system("cd '#{ipa_folder_path}'; /usr/bin/zip -r \"../#{@application_name}_#{@current_version}_embedded_provision.ipa\" Payload iTunesArtwork")
  end
  
  #remove the directory we zipped contents from
  FileUtils.rmtree(ipa_folder_path)
  
end

### Create the zipped .dSYM ###
def createZippedDSYM
  root_folder_path = "Executables/#{@bundle_identifier}"
  
  # Copy the original
  dsym_name = "#{@application_name}.#{DSYM_EXTENSION}"
  FileUtils.cp_r "#{BUILD_FOLDER_PATH}/#{dsym_name}",  "Executables/#{@bundle_identifier}/#{dsym_name}"
  
  # compress the dsym file
  system("cd '#{root_folder_path}'; tar -cvzpf '#{dsym_name}.tgz' '#{dsym_name}'")

  #remove the old dsym dir
  FileUtils.rmtree("#{root_folder_path}/#{dsym_name}")
    
end

def cleanUp
  
end

end

# Be sure to change the application name to match the original target's PRODUCT_NAME.
em = ExecutablesMaker.new(ARGV[0], ARGV[1], ARGV[2], ARGV[3])
em.verifyBuildConfig
em.createIPA
em.createZippedDSYM




