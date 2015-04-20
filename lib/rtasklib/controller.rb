module Rtasklib

  module Controller

    def create
    end

    def update
    end

    def get
    end

    def get_version
      raw, ec = Execute.task(@create_new, "rc.data.location=#{data_location}",
                                       "_version")
      if ec == 0
        return to_gem_version(raw)
      else
        return nil
      end
    end

    # Convert "1.6.2 (adf342jsd)" to Gem::Version object
    def to_gem_version raw
      std_ver = raw.chomp.gsub(' ','.').delete('(').delete(')')
      p std_ver
      Gem::Version.new std_ver
    end
  end
end
