module Nyaa
  module Utils

    def self.gem_libdir
      paths = [
        "#{File.dirname(File.expand_path($0))}/../lib/#{Nyaa::NAME}",
        "#{Gem.dir}/gems/#{Nyaa::NAME}-#{Nyaa::VERSION}/lib/#{Nyaa::NAME}"
      ]
      paths.each do |i|
        return i if File.readable?(i)
      end

      raise "Could not find 'lib' directory in: #{paths}"
    end

  end
end
