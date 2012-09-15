require 'fileutils'

module Pushover
  # This is an extended [Hash] that adds some saving features via yajl.
  class ConfigBlob < Hash
    # A the directory to save any needed files to.
    BaseDir = "#{Dir.home}/.config/pushover"
    # The file to save the default config to.
    SaveFile = "#{BaseDir}/config.json"

    def initialize(load = true)
      FileUtils.mkdir_p BaseDir if !Dir.exist? BaseDir
      self.load if load
    end

    # Save the config, will raise an exception if the file exists.
    def save
      if any?
        # I do this the long way because I want an immediate sync.
        f = open(file, 'w')
        f.write Yajl.dump self
        f.sync
        f.close
      end
    end

    # Save the config, removing the existing one if neccesary.
    def save!
      FileUtils.rm SaveFile if File.file? SaveFile
      save
    end

    # Load the config file if it is available.
    def load
      if File.exist?(SaveFile) && File.stat(SaveFile).size > 0
        h = Yajl.load open(SaveFile, 'r').read
        h.each { |k,v| self[k.to_sym] = v}
      end
    end
  end

  # A convience instance of config, provides Pushover.Config.
  Config = ConfigBlob.new
end
