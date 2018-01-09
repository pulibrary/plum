# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "auth_tokens/new", type: :view do
  before do
    assign(:auth_token, AuthToken.new)
  end

  it "renders new auth_token form" do
    render

    assert_select "form[action=?][method=?]", auth_tokens_path, "post" do
    end
  end
end
