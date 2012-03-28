require 'spec_helper'

describe 'an account' do
  it 'should be true' do
    account = FactoryGirl.create(:account)
    account.name.should == 'foo-account'
  end
end