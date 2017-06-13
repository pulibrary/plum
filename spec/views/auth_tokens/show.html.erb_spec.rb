require 'rails_helper'

RSpec.describe "auth_tokens/show", type: :view do
  before(:each) do
    @auth_token = assign(:auth_token, AuthToken.create!)
  end

  it "renders attributes in <p>" do
    render
  end
end
