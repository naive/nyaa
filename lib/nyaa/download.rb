module Nyaa
  class Download
    # common
    attr_accessor :target, :destination, :retries
    # derived
    attr_accessor :response, :filename

    def initialize(url, path, retries = 3)
      self.target      = url
      self.destination = sane_path(path)
      self.retries     = retries

      self.response = request
      self.filename = name

      @fail = nil
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
        @fail = true
      end
      @fail = false
      response
    end

    def name
      re = /\.torrent$/
      if re.match(self.target)
        filename = name_from_url
      else
        filename = name_from_disposition
      end

      # If we can't determine the remote filename, create one.
      unless filename
        file = Tempfile.new(['nyaa', '.torrent'], self.destination)
        filename = File.basename(file)
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

    def sane_path(path)
      if path.nil?
        path = File.expand_path('~')
      else
        newpath = File.expand_path(path)
        unless File.directory?(newpath) && File.writable?(newpath)
          path = '/tmp'
        end
      end
      path
    end

  end

end
