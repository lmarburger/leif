require 'leif/collection_json/link'

describe Leif::CollectionJson::Link do
  let(:link)     {{ 'rel' => relation, 'href' => href }}
  let(:relation) { double(:relation) }
  let(:href)     { double(:href) }
  subject { Leif::CollectionJson::Link.new(link) }

  it 'has a relation' do
    expect(subject.relation).to eq(relation)
  end

  it 'has an href' do
    expect(subject.href).to eq(href)
  end
end
