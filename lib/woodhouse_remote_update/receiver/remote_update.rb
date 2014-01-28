module WoodhouseRemoteUpdate::Receiver

  class RemoteUpdate

    class << self
      attr_accessor :consumers, :responders
    end

    attr_reader :type, :data, :remote_id

    class WoodhouseResponder

      def initialize(worker, job)
        @worker = worker
        @job = job
      end

      def call(update, response_data)
        @worker.send("async_#{@job}", 
                     { update_id: update.remote_id,
                       type: update.type,
                       time: Time.now,
                       payload: response_data.to_json })
      end

    end

    class NullResponseListener
      def bloop
        # ;)
      end
    end

    self.consumers = {}
    self.consumers.default = ->(data) { raise "got unexpected change notification}" }
    self.responders = {}
    self.responders.default = WoodhouseResponder.new(NullResponseListener, :bloop)

    def initialize(type, data)
      self.remote_id = data["id"]
      self.type = type
      self.data = data
    end

    def type=(value)
      @type = value.to_sym
    end

    def consume
      self.class.consumers[type].call(self)
    end

    def respond(rdata)
      if defined?(Rails)
        Rails.logger.info "[WoodhouseRemoteUpdate::Receiver::RemoteUpdate] responding to #{type}(#{remote_id}) with #{rdata.inspect}"
      end
      self.class.responders[type].call(self, rdata)
    end

    def self.consume(type, data)
      if data.kind_of?(Array)
        data.each do |each|
          new(type, each).consume
        end
      else
        new(type, data).consume
      end
    end


    private

    attr_writer :data, :remote_id

  end

end
