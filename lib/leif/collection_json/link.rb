module Leif
  module CollectionJson
    class Link
      attr_accessor :relation, :href

      def initialize(link)
        @relation = link.fetch('rel')
        @href     = link.fetch('href')
      end
    end
  end
end
