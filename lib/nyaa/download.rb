module Nyaa
  class Download
    # common
    attr_accessor :target, :destination, :retries
    # derived
    attr_accessor :filename

    def initialize(url, path, retries = 3)
      self.target      = url
      self.destination = File.expand_path(path)
      self.retries     = retries

      self.response    = request(url)
      self.filename    = name ||= nil

      @fail            = response.nil ? true : false
    end

    def save
      unless @fail
        File.open("#{self.destination}/#{self.filename}", 'w') do
          |f| f.write(self.response.body)
        end
      end
    end

    def failed?
      @fail
    end

    private

    def request
      begin
        response = RestClient.get(self.target)
      rescue StandardError => e
        if retries > 0
          retries -= 1
          sleep = 1
          retry
        end
        response = nil
      end
      response
    end

    def name
      re = /\.torrent$/
      if re.match(self.target)
        filename = name_from_url
      else
        filename = name_from_disposition
      end
      filename
    end

    def name_from_url
      re = /\.torrent$/
      filename = re.match(self.target).to_s.gsub(/.+\//, '')
      filename
    end

    def name_from_disposition
      disp = self.response.headers[:content_disposition]
      disp_filename = disp.split(/;\s+/).select { |v| v =~ /filename\s*=/ }[0]
      re = /([""'])(?:(?=(\\?))\2.)*?\1/
      if re.match(disp_filename)
        filename = re.match(disp_filename).to_s.gsub(/\A['"]+|['"]+\Z/, "")
        filename
      else
        nil
      end
    end

  end

end
