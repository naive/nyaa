# -*- encoding : utf-8 -*-
module Nyaa
  class Interface
    def initialize(opts)
      if opts[:script]
        nyaa = Nyaa::CLI.new(opts)
      else
        nyaa = Nyaa::Browser.new(opts)
      end
      nyaa.start
    end
  end
end
