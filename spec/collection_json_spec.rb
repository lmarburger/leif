require 'leif/collection_json'

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

  describe '#items' do
    let(:body) {{ "collection" => { "items" => items } }}
    let(:items) {[{
      "href" => "https://api.getcloudapp.com/drops/1",
      "links" => [{ "rel" => "collection",
                  "href"  => "https://api.getcloudapp.com/drops" }],
      "data" => [
        { "name" => "id",   "value" => 1 },
        { "name" => "name", "value" => "Hitchhiker's Guide" }
      ]
    }, {
      "href" => "https://api.getcloudapp.com/drops/2",
      "links" => [{ "rel" => "collection",
                  "href"  => "https://api.getcloudapp.com/drops" }],
      "data" => [
        { "name" => "id",   "value" => 2 },
        { "name" => "name", "value" => "The Restaurant" }
      ]
    }]}
    subject { collection.items }

    it 'returns the items' do
      expect(subject).to eq(items)
    end

    it "can retrieve the items's link relations" do
      expect(subject.first.link_relations).to eq(['collection'])
    end

    it "can retrieve the link's href" do
      expect(subject.first.link_href('collection')).
        to eq('https://api.getcloudapp.com/drops')
    end

    context 'with no items' do
      let(:body) {{ "collection" => {} }}

      it 'is empty' do
        expect(subject).to be_empty
      end
    end
  end

  describe '#template' do
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
    subject { collection.template }

    it 'returns the template' do
      expect(subject).to eq(template)
    end

    it "uses the collection's href" do
      expect(subject.href).to eq(href)
    end

    it 'has a method' do
      expect(subject.method).to eq(:post)
    end

    it 'can be converted to json' do
      expected_json = { 'email' => nil, 'password' => nil }
      expect(subject.convert_to_json).to eq(expected_json)
    end

    it 'can fill a field' do
      updated = subject.fill_field 'email', 'arthur@dent.com'
      expect(updated.fetch('data')).to include('name'  => 'email',
                                               'value' => 'arthur@dent.com')
      expect(subject.fetch('data')).to include('name'  => 'email',
                                               'value' => nil)
    end
  end

  describe '#item_template' do
    let(:body) {{
      "collection" => {
        "template" => template,
        "items"    => [ item ]
      }
    }}
    let(:template) {{ "data" => [{ "name" => "name", "value" => nil }] }}
    let(:item) {{
      "href" => href,
      "data" => [
        { "name" => "id",   "value" => 1 },
        { "name" => "name", "value" => "Hitchhiker's Guide" }
      ]
    }}
    let(:href) { double(:href) }
    subject { collection.item_template(item) }

    it 'returns the filled template' do
      expected = { "data" => [{ "name"  => "name",
                                "value" => "Hitchhiker's Guide" }] }
      expect(subject).to eq(expected)
    end

    it "uses the item's href" do
      expect(subject.href).to eq(href)
    end

    it 'has a method' do
      expect(subject.method).to eq(:put)
    end
  end
end
