require 'rails_helper'

RSpec.describe BatchMailer do
  let(:users) { [FactoryGirl.create(:user, email: "rspec@test.org")] }
  let(:batch) { FactoryGirl.create :batch, title: ["RSpec Mock Test"] }
  let(:directories) { ["/dev/null", "/opt/test", "/mnt/rspec"] }

  before(:each) do 
    ActionMailer::Base.deliveries = []
  end

  it "notifies when a new batch ingest begins" do
    BatchMailer.batch_started_email(users, batch, directories).deliver_now

    deliveries = ActionMailer::Base.deliveries
    expect(deliveries.count).to eq 1
    expect(deliveries.first.from).to eq ["batches@archives.clevelandart.org"]
    expect(deliveries.first.to).to eq ["rspec@test.org"]
    expect(deliveries.first.subject).to include "RSpec Mock Test"
  end

  subject(:email) { BatchMailer.batch_started_email(users, batch, directories).deliver_now }
  it "includes a listing of processed directories" do
    expect(email.body.encoded).to include "RSpec Mock Test"
    expect(email.body.encoded).to include "/dev/null"
    expect(email.body.encoded).to include "/opt/test"
    expect(email.body.encoded).to include "/mnt/rspec"
  end
end
