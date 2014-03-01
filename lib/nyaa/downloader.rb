# -*- encoding : utf-8 -*-
module Nyaa
  class Downloader
    attr_accessor :target, :destination, :retries
    attr_accessor :response, :filename

    def initialize(url, path, retries = 3)
      self.target      = url
      self.destination = Nyaa::Utils.safe_path(path)
      self.retries     = retries
      self.response    = request
      self.filename    = name_from_disposition

      @fail = nil
    end

    def save
      unless @fail
		path = self.destination + '/' + filename;
        File.open("#{self.destination}/#{filename}", 'w') do |f|
          f.write(self.response.read)
        end
		return path;
      end
	  return nil;
    end

    def failed?
      @fail
    end

    private

    def request
      begin
        response = open(self.target)
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

    # Filename from Content Disposition Header Field
    # http://www.ietf.org/rfc/rfc2183.txt
    def name_from_disposition
      disp = self.response.meta['content-disposition']
      disp_filename = disp.split(/;\s+/).select { |v| v =~ /filename\s*=/ }[0]
      re = /([""'])(?:(?=(\\?))\2.)*?\1/
      if re.match(disp_filename)
        filename = re.match(disp_filename).to_s.gsub(/\A['"]+|['"]+\Z/, "")
      else
        nil
      end
    end

  end
end
