RSpec.configure do |config|
  config.before(:each) do
    messaging_client = instance_double(MessagingClient, publish: true)
    allow(Plum).to receive(:messaging_client).and_return(messaging_client)
  end
end
