require 'rails_helper'

RSpec.describe IuDevOps::FcrepoCheck do
  subject { described_class.new(ActiveFedora.fedora_config.credentials[:url], 5,
                                [ActiveFedora.fedora_config.credentials[:user], ActiveFedora.fedora_config.credentials[:password]]) }

  describe '#check' do
    context 'Fedora is up' do
      it 'reports success' do
        subject.check
        expect(subject.success?).to eq(true)
      end
    end

    context 'Fedora is down' do
      before { subject.url = "#{subject.url}/badpath" }
      it 'reports failure' do
        subject.check
        expect(subject.success?).to eq(false)
      end
    end
  end
end
