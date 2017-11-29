# frozen_string_literal: true
RSpec.configure do |config|
  config.before do
    messaging_client = instance_double(MessagingClient, publish: true)
    allow(Plum).to receive(:messaging_client).and_return(messaging_client)

    geo_messaging_client = instance_double(GeoblacklightMessagingClient, publish: true)
    allow(Plum).to receive(:geoblacklight_messaging_client).and_return(geo_messaging_client)
  end
end
