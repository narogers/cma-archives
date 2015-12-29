require 'spec_helper'

RSpec.describe Collection do
  it "normalizes a lower case title" do
    c = Collection.new(title: "test title 123.45")
    expect(c.normalize_title).to eq "Test Title 123.45"
  end

  it "normalizes an upper case title" do
    c = Collection.new(title: "UPPER CASE TITLE")
    expect(c.normalize_title).to eq "Upper Case Title"
  end

  it "normalizes acronyms properly" do
    c = Collection.new(title: "Cma galleries on MlK Day 2015")
    expect(c.normalize_title).to eq "CMA Galleries On MLK Day 2015"
  end
end

