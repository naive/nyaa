module Nyaa
  class API
    attr_accessor :query, :results

    def initialize(opts)
      @opts    = opts
      @results = search
    end

    def search
      results  = []
      @search  = Search.new(@opts[:query], @opts[:category], @opts[:filter])
      @results = @search.next.results
    end

    def download(target, destination)
      @download = Download.new(target, destination)
      @download.save
    end

  end
end
