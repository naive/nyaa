module Nyaa
  class API
    attr_accessor :query, :results

    def initialize(opts)
      @opts    = opts
      @results = []
    end

    def search(query = nil)
      search = Search.new(@opts[:query],@opts[:category],@opts[:filter])
      @results = search.next.results
    end

    def get(file)
      file.is_a?(Nyaa::Torrent) ? target = file.link : target = file
      dl = Download.new(target, @opts[:outdir])
      dl.save
    end

  end
end
