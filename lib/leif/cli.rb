require 'faraday'
require 'faraday_middleware'
require 'highline/import'
require 'json'
require 'logger'
require 'stringio'

module Leif
  class Cli
    def conn
      @conn ||= Faraday.new(url: 'https://api.getcloudapp.com') do |config|
        config.request  :url_encoded
        config.response :logger, logger
        config.response :json, :content_type => /\bjson$/
        config.adapter  Faraday.default_adapter
      end
    end

    def logger
      @logger ||= Logger.new(debug_output)
    end

    def debug_output
      @debug_output ||= StringIO.new
    end

    def banner(banner, &message)
      puts
      Section.banner(banner, &message)
    end

    def reset_debug_output
      debug_output.rewind
      debug_output.truncate 0
    end

    def make_request(uri, data = {}, method = :unset)
      method = data.empty? ? :get : :post if method == :unset
      reset_debug_output
      @response = conn.send(method, uri, data)
    end

    def collection
      Leif::CollectionJson::Collection.new(@response.body)
    end

    def get_root
      make_request '/'
    end

    def retry_request
      make_request @response.env[:url].request_uri
    end

    def print_response
      banner 'Request' do |out|
        out.print "#{@response.env[:method].upcase} #{@response.env[:url]}"
        out.print @response.env[:request_headers].map {|header, value|
          "#{header}: #{value}"
        }
      end

      banner 'Response' do |out|
        out.print @response.headers.map {|header, value|
          "#{header}: #{value}"
        }
      end

      banner 'Body' do |out|
        out.print JSON.pretty_generate(@response.body).lines
      end

      banner 'Links' do |out|
        unless collection.link_relations.empty?
          out.print collection.link_relations.join(', ')
        end
      end
    end

    def request_basic_authentication(username = :ask, password = :ask)
      username = ask('Username: ')                     if username == :ask
      password = ask('Password: ') {|q| q.echo = '*' } if password == :ask
      conn.basic_auth username, password
      retry_request
    end

    def request_token_authentication(token = '2x033S09401z300E')
      conn.headers['Authorization'] = "Token token=#{token.inspect}"
      retry_request
    end

    def follow_link(relation = :ask)
      relation = ask('Relation: ') if relation == :ask
      make_request collection.link_href(relation)
    end

    def create_item
      template = collection.template

      loop do
        banner 'Create Item' do |out|
          out.print JSON.pretty_generate(template).lines
        end

        puts
        puts 'Fill the template to create a new item.'
        name = ask('Name (empty to submit): ')
        break if name.empty?
        value = ask_for_primitive('Value: ')

        template = template.fill_field name, value
      end

      make_request template.href, template.convert_to_json, template.method
    end

    def update_item
      item = collection.items.find do |item|
        banner 'Item' do |out|
          out.print JSON.pretty_generate(item).lines
        end

        puts
        response = ask('Select this item to update [y,n]? ') do |q|
          q.character = true
          q.validate  = /\A[yn]\Z/
        end

        response == 'y'
      end

      template = collection.item_template item

      loop do
        banner 'Update Item' do |out|
          out.print JSON.pretty_generate(template).lines
        end

        puts
        puts 'Fill the template to update the item.'
        name = ask('Name (empty to submit): ')
        break if name.empty?
        value = ask_for_primitive('Value: ')

        template = template.fill_field name, value
      end

      make_request template.href, template.convert_to_json, template.method
    end

    def print_debug
      banner 'Debug' do |out|
        debug_output.rewind
        out.print debug_output.readlines
      end
    end

    def print_help
      puts <<EOS
    root:
      Go back to the root

    follow <rel>:
      Follow link with the given relation.

    template [<name>=<value>...]:
      Fill the template with the given name/value pairs and submit.

    basic [<username> [<password>]]:
      Authenticate with HTTP Basic and reload the current resource. Will be
      prompted for username and password if omitted.

    token <token>:
      Authenticate using the given token and reload the current resource.

    debug:
      Print debug output from the previous HTTP request and response.
EOS
    end

    def get_next_action
      command, args = ask_for_action
      case command
      when 'r', 'root'   then get_root
      when 'f', 'follow' then follow_link(*args)
      when      'create' then create_item
      when      'update' then update_item
      when 'b', 'basic'  then request_basic_authentication(*args)
      when 't', 'token'  then request_token_authentication(*args)
      when 'd', 'debug'  then print_debug; get_next_action
      when '?', 'help'   then print_help; get_next_action
      when 'q', 'quit'   then exit
      else puts 'Try again.'; get_next_action
      end
    end

    def ask_for_action
      puts
      input = ask('> ') {|q| q.readline = true }.split(/\s/)
      [ input.first, input[1..-1] ]
    end

    def ask_for_primitive(message)
      value = ask(message)
      case value
      when 'null', 'nil' then nil
      when '"null"'      then 'null'
      when '"nil"'       then 'nil'

      when 'true'    then true
      when 'false'   then false
      when '"true"'  then 'true'
      when '"false"' then 'false'

      when /\A\d+\Z/   then Integer(value)
      when /\A"\d+"\Z/ then value[1..-2]

      else value
      end
    end
  end
end