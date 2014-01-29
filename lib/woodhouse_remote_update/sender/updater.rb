module WoodhouseRemoteUpdate::Sender

  class Updater
    attr_accessor :type
    attr_accessor :listener

    class NullUpdateListener
      def notify(job)
        # ;)
      end
    end

    def initialize(type, keyw = {})
      self.type = type
      self.listener ||= keyw[:listener] || NullUpdateListener
    end

    def update(data)
      send_update(type, data)
    end

    class Batched
      attr_accessor :updater

      def initialize(type, updater, keyw = {})
        self.updater = updater.send :new, type, keyw
      end

      def listener=(v)
        updater.listener = v
      end

      def in_batch
        @batch = []
        yield self
        updater.update(@batch) unless @batch.empty?
      ensure
        @batch = nil
      end

      def update(data)
        if @batch
          @batch << data
        else
          updater.update(data)
        end
      end

    end

    class << self
      attr_accessor :mutex

      def updater(type)
        type = type.to_sym
        updater = nil

        @mutex.synchronize do
          Thread.current[:hub_updaters] ||= {}
          updater = Thread.current[:hub_updaters][type] ||= Batched.new(type, self)
        end

        updater
      end

      def in_batch(type, &blk)
        updater(type).in_batch(&blk)
      end

      def update(type, data)
        updater(type).update(data)
      end

    end

    self.mutex = Mutex.new

    private

    def send_update(type, data)
      listener.async_notify(type: type, payload: data.to_json)
    end
  end

end
