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

    def print_overview
      print_request
      print_response
      print_body
      print_links collection
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

    def follow_link(subject, relation = :ask)
      relation = ask('Relation: ') if relation == :ask
      make_request subject.link_href(relation)
    end

    def fill_and_submit_template(template, label)
      print_template template
      puts
      puts label
      template.each do |name, value|
        printed_value = value.inspect
        printed_value = 'null' if printed_value == 'nil'
        new_value = ask("#{name} [#{printed_value}]: ")
        new_value = new_value.empty? ? value : convert_to_primitive(new_value)
        template  = template.fill_field name, new_value
      end

      make_request template.href, template.convert_to_json, template.method
    end

    def create_item
      fill_and_submit_template collection.template,
                               'Fill the template to create a new item.'
    end

    def update(item)
      fill_and_submit_template collection.item_template(item),
                               'Fill the template to update the item.'
    end

    def print_request
      banner 'Request' do |out|
        out.print "#{@response.env[:method].upcase} #{@response.env[:url]}"
        out.print @response.env[:request_headers].map {|header, value|
          "#{header}: #{value}"
        }
      end
    end

    def print_response
      banner 'Response' do |out|
        out.print @response.headers.map {|header, value|
          "#{header}: #{value}"
        }
      end
    end

    def print_body
      banner 'Body' do |out|
        out.print JSON.pretty_generate(@response.body).lines
      end
    end

    def print_links(subject)
      banner 'Links' do |out|
        unless subject.link_relations.empty?
          out.print subject.link_relations.join(', ')
        end
      end
    end

    def print_collection
      banner 'Collection' do |out|
        out.print JSON.pretty_generate(collection).lines
      end
    end

    def print_template(template = collection.template)
      banner 'Template' do |out|
        out.print JSON.pretty_generate(template).lines
      end
    end

    def print_items
      item = select_item
      print_links item
      get_next_item_action item
    rescue Interrupt
      print '^C'
    end

    def print_item(item)
      banner 'Item' do |out|
        out.print JSON.pretty_generate(item).lines
      end
    end

    def select_item
      collection.items.find do |item|
        print_item item
        puts
        response = ask('Select this item [y,n]? ') do |q|
          q.character = true
          q.validate  = /\A[yn]\Z/
        end

        response == 'y'
      end
    end

    def print_debug
      banner 'Debug' do |out|
        debug_output.rewind
        out.print debug_output.readlines
      end
    end

    def print_help
      banner 'Help' do |out|
        out.print <<EOS.lines
root:
  Go back to the root.

follow <rel>:
  Follow link with the relation <rel> on the collection.

create:
  Begin editing the template to create a new item.

request:
  Reprint the details of the last request.

response:
  Reprint the details of the last response.

template:
  Print the template from the last response.

items:
  Print each item from the last response one at a time in order to update,
  delete, or follow an item's link.

basic [<username> [<password>]]:
  Authenticate with HTTP Basic and reload the current resource. Will be
  prompted for username and password if omitted.

token <token>:
  Authenticate using the given token and reload the current resource.

debug:
  Print debug output from the previous HTTP request and response.

quit:
  Exit leif.
EOS
      end
    end

    def print_item_help
      banner 'Help' do |out|
        out.print <<EOS.lines
item:
  Print the selected item.

cancel:
  Cancel item selection and go back to the collection.

follow <rel>:
  Follow link with the relation <rel> on the selected item.

update:
  Begin editing the template to update the selected item.

quit:
  Exit leif.
EOS
      end
    end

    def get_next_item_action(item)
      command, args = ask_for_action
      case command
      when 'item'        then print_item(item); get_next_item_action(item)
      when 'update'      then update(item)
      when 'f', 'follow' then follow_link(item, *args)
      when 'cancel'
      when 'q', 'quit'   then exit
      when '?', 'help'   then print_item_help; get_next_item_action(item)
      else puts 'Try again.'; get_next_item_action(item)
      end
    rescue Interrupt
      print '^C'
    end

    def get_next_action
      command, args = ask_for_action
      case command
      when 'r', 'root'   then get_root
      when 'f', 'follow' then follow_link(collection, *args)
      when      'create' then create_item

      when 'request'     then print_request;    get_next_action
      when 'response'    then print_response;   get_next_action
      when 'body'        then print_body;       get_next_action
      when 'collection'  then print_collection; get_next_action
      when 'template'    then print_template;   get_next_action
      when 'items'       then print_items

      when 'b', 'basic'  then request_basic_authentication(*args)
      when 't', 'token'  then request_token_authentication(*args)

      when 'd', 'debug'  then print_debug; get_next_action
      when '?', 'help'   then print_help; get_next_action
      when 'q', 'quit'   then exit
      else puts 'Try again.'; get_next_action
      end
    rescue Interrupt
      print '^C'
      get_next_action
    rescue EOFError
      puts
      exit
    end

    def ask_for_action
      puts
      input = ask('> ') {|q| q.readline = true }.split(/\s/)
      [ input.first, input[1..-1] ]
    end

    def convert_to_primitive(value)
      case value
      when 'null', 'nil', '' then nil
      when '"null"' then 'null'
      when '"nil"'  then 'nil'
      when '""'     then ''

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
