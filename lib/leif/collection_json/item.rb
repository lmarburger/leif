module Leif
  module CollectionJson
    class Item
      attr_accessor :item

      def initialize(item)
        @item = item
      end

      def href
        @item.fetch('href')
      end

      def data
        @item.fetch('data')
      end

      def []=(name, value)
        datum = data.find {|datum| datum['name'] == name }
        return unless datum
        datum['value'] = value
      end

      def to_hash
        data.each_with_object({}) do |datum, data|
          data[datum['name']] = datum['value']
        end
      end
    end
  end
end
