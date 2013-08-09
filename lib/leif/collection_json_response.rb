require 'delegate'
require 'forwardable'
require 'leif/collection_json/collection'

module Leif
  module CollectionJson
    class FaradayResponse < SimpleDelegator
      extend Forwardable
      def_delegators :collection, :href, :links, :link, :items,
                     :template, :fill_template_field, :fill_template, :submit_template

      def collection
        @collection ||= Collection.new(body)
      end
    end
  end
end
