require 'rails_helper'

RSpec.describe "auth_tokens/index", type: :view do
  before(:each) do
    assign(:auth_tokens, [
      AuthToken.create!,
      AuthToken.create!
    ])
  end

  it "renders a list of auth_tokens" do
    render
  end
end
