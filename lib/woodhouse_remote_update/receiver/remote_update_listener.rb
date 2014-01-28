module WoodhouseRemoteUpdate::Receiver

  class RemoteUpdateListener
    include Woodhouse::Worker

    def notify(job)
      WoodhouseRemoteUpdate::Receiver::RemoteUpdate.consume(job[:type], JSON.parse(job.payload))
    end
  end

end
