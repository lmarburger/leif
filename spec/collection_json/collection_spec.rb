require 'leif/collection_json/collection'

describe Leif::CollectionJson::Collection do
  let(:collection) { Leif::CollectionJson::Collection.new(body) }

  describe '#link_relations' do
    let(:body) {{
      "collection" => {
        "links" => [{ "rel" => one }, { "rel" => two }, { "rel" => three }]
      }
    }}
    let(:one)   { double(:relation_one) }
    let(:two)   { double(:relation_two) }
    let(:three) { double(:relation_three) }
    subject { collection.link_relations }

    it 'returns an array of relations' do
      expect(subject).to eq([ one, two, three ])
    end

    context 'with no links' do
      let(:body) {{ "collection" => {} }}
      it 'returns an empty array' do
        expect(subject).to be_empty
      end
    end
  end

  describe '#link_href' do
    let(:body) {{
      "collection" => {
        "links" => [{ "rel" => relation, "href" => href }]
      }
    }}
    let(:relation) { double(:relation) }
    let(:href)     { double(:href) }
    subject { collection.link_href(relation) }

    it "returns the link's href" do
      expect(subject).to eq(href)
    end
  end

  describe '#collection_template' do
    let(:body) {{
      "collection" => { 
        "href"     => href,
        "template" => template
      }
    }}
    let(:href) { double(:href) }
    let(:template) {{
      "data" => [
        { "name" => "email",    "value" => nil },
        { "name" => "password", "value" => nil }
      ]
    }}
    subject { collection.collection_template }

    it 'returns the template' do
      expect(subject).to eq(template)
    end

    it 'has an href' do
      expect(subject.href).to eq(href)
    end

    it 'has a method' do
      expect(subject.method).to eq(:post)
    end

    it 'can be converted to json' do
      expected_json = { 'email' => nil, 'password' => nil }
      expect(subject.convert_to_json).to eq(expected_json)
    end

    it 'can fill a file' do
      updated = subject.fill_field 'email', 'arthur@dent.com'
      expect(updated.fetch('data')).to include('name'  => 'email',
                                               'value' => 'arthur@dent.com')
      expect(subject.fetch('data')).to include('name'  => 'email',
                                               'value' => nil)
    end
  end

  describe '#item_template'
  describe '#items'
end
