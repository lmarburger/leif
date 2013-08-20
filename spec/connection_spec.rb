require 'leif/connection'
require 'uri'

describe Leif::Connection do
  describe '.to_url' do
    let(:url)     { 'http://getcloudapp.com/path' }
    let(:options) { {} }
    subject { Leif::Connection.to_url(url, options) }

    it 'creates a connection to the given url' do
      expect(subject.connection.host).to eq('getcloudapp.com')
    end

    it 'verifies certificates' do
      expect(subject.connection.ssl).to eq(verify: true)
    end

    context 'without certificate verification' do
      let(:options) {{ ssl_verify: false }}

      it 'does not verify certificates' do
        expect(subject.connection.ssl).to eq(verify: false)
      end
    end

    context 'with basic auth' do
      subject { Leif::Connection.to_url(url, username: 'u', password: 'p') }

      it 'sets authentication' do
        expect(subject.connection.headers).to have_key('Authorization')
        expect(subject.connection.headers['Authorization']).
          to eq('Basic dTpw')
      end
    end

    context 'with token auth' do
      subject { Leif::Connection.to_url(url, token: 'token') }

      it 'sets authentication' do
        expect(subject.connection.headers).to have_key('Authorization')
        expect(subject.connection.headers['Authorization']).
          to eq('Token token="token"')
      end
    end
  end

  describe '#request' do
    let(:connection)  { double(:connection, get: response) }
    let(:response)    { double(:response) }
    let(:path)        { double(:path) }
    let(:data)        { double(:data, empty?: false) }
    let(:http_method) { :woot }
    subject { Leif::Connection.new(connection) }

    context 'response' do
      let(:response) {
        double(:response, body: response_body,
                          headers: response_headers,
                          env: { url: URI.parse(url),
                                 method: 'get',
                                 request_headers: request_headers,
                                 body: request_body })
      }
      let(:url)              { 'http://getcloudapp.com/path?query=string' }
      let(:response_body)    { double(:response_body) }
      let(:response_headers) { double(:response_headers) }
      let(:request_headers)  { double(:request_headers) }
      let(:request_body)     { double(:request_body) }
      subject { Leif::Connection.new(connection).request(path) }

      it 'has a request uri' do
        expect(subject.uri).to eq('/path?query=string')
      end

      it 'has a request method' do
        expect(subject.method).to eq('GET')
      end

      it 'has request headers' do
        expect(subject.request_headers).to eq(request_headers)
      end

      it 'has a request body' do
        expect(subject.request_body).to eq(request_body)
      end

      it 'has response headers' do
        expect(subject.response_headers).to eq(response_headers)
      end

      it 'has a response body' do
        expect(subject.response_body).to eq(response_body)
      end
    end

    it 'sends a GET request' do
      expect(connection).to receive(:get).with(path, {})
      subject.request(path)
    end

    it 'sends a POST request' do
      expect(connection).to receive(:post).with(path, data)
      subject.request(path, data)
    end

    it 'sends a specific http method' do
      expect(connection).to receive(http_method).with(path, data)
      subject.request(path, data, http_method)
    end
  end
end
