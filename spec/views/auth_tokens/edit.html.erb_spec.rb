require 'rails_helper'

RSpec.describe "auth_tokens/edit", type: :view do
  before(:each) do
    @auth_token = assign(:auth_token, AuthToken.create!)
  end

  it "renders the edit auth_token form" do
    render

    assert_select "form[action=?][method=?]", auth_token_path(@auth_token), "post" do
    end
  end
end
