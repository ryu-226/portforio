require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller(ApplicationController) do
    def index = render(plain: 'ok')
  end

  around { |ex| travel_to(Time.zone.local(2025, 1, 15, 12)) { ex.run } }

  let(:user) { create(:user) }

  it 'stored_location があればそれを返す' do
    allow(controller).to receive(:stored_location_for).with(user).and_return('/foo')
    expect(controller.send(:post_login_path_for, user, created_now: false)).to eq '/foo'
  end

  it 'signup直後は new_budget_path?from_signup=1 を返す' do
    allow(controller).to receive(:stored_location_for).and_return(nil)
    expect(controller.send(:post_login_path_for, user, created_now: true)).to eq new_budget_path(from_signup: '1')
  end

  it '予算が既にあれば main_path を返す' do
    allow(controller).to receive(:stored_location_for).and_return(nil)
    create(:budget, user: user)
    expect(controller.send(:post_login_path_for, user, created_now: false)).to eq main_path
  end

  it '予算が無ければ new_budget_path?from_signup=1 を返す' do
    allow(controller).to receive(:stored_location_for).and_return(nil)
    expect(user.budget_for(Date.current.strftime('%Y-%m'))).to be_nil
    expect(controller.send(:post_login_path_for, user, created_now: false)).to eq new_budget_path(from_signup: '1')
  end
end
