require 'fileutils'

module Pushover
  class ConfigBlob < Hash
    BaseDir = "#{Dir.home}/.config/pushover"

    def initialize(load = true)
      FileUtils.mkdir_p BaseDir if !Dir.exist? BaseDir
      self.load if load
    end

    def file
      "#{BaseDir}/config.json"
    end

    def save
      if any?
        # I do this the long way because I want an immediate sync.
        f = open(file, 'w')
        f.write Yajl.dump self
        f.sync
        f.close
      end
    end

    def save!
      FileUtils.rm file if File.file? file
      save
    end

    def load
      if File.exist?(self.file) && File.stat(self.file).size > 0
        h = Yajl.load open(file, 'r').read
        h.each { |k,v| self[k.to_sym] = v}
      end
    end
  end

  Config = ConfigBlob.new
end
