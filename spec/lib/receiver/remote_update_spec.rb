require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe WoodhouseRemoteUpdate::Receiver::RemoteUpdateListener do

  subject { WoodhouseRemoteUpdate::Receiver::RemoteUpdateListener.new }
  let(:dummy_consumer) { double("consumer") }

  it "should accept notifications with a JSON payload" do
    WoodhouseRemoteUpdate::Receiver::RemoteUpdate.consumers[:foobar] = dummy_consumer
    dummy_consumer.should_receive(:call)

    job = Woodhouse::Job.new(subject.class.name, "notify", "type" => "foobar")
    job.payload = { "a" => "b" }.to_json

    subject.notify(job)
  end

end
