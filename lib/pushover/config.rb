require 'fileutils'

module Pushover
  # This is an extended [Hash] that adds some saving features via yajl.
  class ConfigBlob < Hash
    attr_accessor :save_file

    # @return [String] the dirname of the save file.
    def save_dir
      File.dirname save_file
    end

    def initialize(load = true)
      @save_file = "#{Dir.home}/.config/pushover/config.json"

      FileUtils.mkdir_p save_dir if !Dir.exist? save_dir
      self.load if load
    end

    # Save the config, will raise an exception if the file exists.
    def save
      if any?
        # I do this the long way because I want an immediate sync.
        f = open(save_file, 'w')
        f.write Yajl.dump self
        f.sync
        f.close
      end
    end

    # Save the config, removing the existing one if neccesary.
    def save!
      FileUtils.rm save_file if File.file? save_file
      save
    end

    # Load the config file if it is available.
    def load
      if File.exist?(save_file) && File.stat(save_file).size > 0
        h = Yajl.load open(save_file, 'r').read
        h.each { |k,v| self[k.to_sym] = v}
      end
    end
  end

  # A convience instance of config, provides Pushover.Config.
  Config = ConfigBlob.new
end
