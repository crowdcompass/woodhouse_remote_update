module WoodhouseRemoteUpdate::Sender

  class ResponseListener
    include ::Woodhouse::Worker

    def accept_response(job)
      # ;)
    end
  end

end
