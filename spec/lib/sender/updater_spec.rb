require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe WoodhouseRemoteUpdate::Sender::Updater do

  context "the global interface" do

    let(:mock_listener) { double("listener") }

    it "should share one updater instance per type" do
      WoodhouseRemoteUpdate::Sender::Updater.updater(:vux).should be WoodhouseRemoteUpdate::Sender::Updater.updater(:vux)
    end

    it "should allow updates outside a batch" do
      WoodhouseRemoteUpdate::Sender::Updater.updater(:vux).listener = mock_listener
      mock_listener.should_receive(:async_notify).with({ type: :vux, payload: {"spathi" => "fwiffo"}.to_json })

      WoodhouseRemoteUpdate::Sender::Updater.update :vux, "spathi" => "fwiffo"
    end

    it "should batch updates inside an .in_batch block" do
      WoodhouseRemoteUpdate::Sender::Updater.updater(:vux).listener = mock_listener
      mock_listener.should_receive(:async_notify).with({
        type: :vux,
        payload: [ { "spathi" => "fwiffo" }, { "orz" => "*camper*" } ].to_json
      })

      WoodhouseRemoteUpdate::Sender::Updater.in_batch(:vux) do |updater|
        updater.update "spathi" => "fwiffo"
        WoodhouseRemoteUpdate::Sender::Updater.update :vux, "orz" => "*camper*"
      end
    end

  end

end
