require 'forwardable'

module Leif
  module CollectionJson
    class Collection
      extend Forwardable
      def_delegators :@data, :fetch, :has_key?

      def initialize(body)
        @data = body.fetch('collection')
      end

      def href
        fetch('href')
      end

      def links
        return [] unless has_key?('links')
        fetch('links').map {|link| Leif::CollectionJson::Link.new(link) }
      end

      def link(relation)
        links.find {|link| link.relation == relation }
      end

      def template
        @template ||= Item.new(fetch('template'))
      end

      def fill_template_field(name, value)
        template[name] = value
      end

      def fill_template(item)
        item.to_hash.each do |name, value|
          fill_template_field name, value
        end
      end

      def items
        return [] unless has_key?('items')
        fetch('items').map {|item| Item.new(item) }
      end
    end
  end
end
