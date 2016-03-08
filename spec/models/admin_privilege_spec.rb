# spec/models/admin_privilege.rb
require "rails_helper"

describe AdminPrivilege do
  it "has a valid factory" do
    FactoryGirl.create(:admin_privilege).should be_valid
  end

  it "is invalid without an location_id" do
    FactoryGirl.build(:admin_privilege, org_id: 1, owner_id: 1, location_id: nil).should be_invalid 
  end

  it "is invalid without an owner_id" do
    FactoryGirl.build(:admin_privilege, org_id: 1, location_id: 1, owner_id: nil).should be_invalid 
  end

  it "is invalid without an org_id" do
    FactoryGirl.build(:admin_privilege, owner_id: 1, location_id: 1, org_id: nil).should be_invalid 
  end

  it "has an automatically generated key_hash that is 48 character in length" do
    key = FactoryGirl.create(:admin_privilege, owner_id: 1, org_id: 1, location_id: 1)
    expect(key.master_key).to eq(nil)
    expect(key.parent_key).to eq(nil)
    expect(key.key_hash.length).to eq(48)
  end

  it "a key can be copied and the resulting key will have appropriate master/parent key id" do
    mkey = FactoryGirl.create(:admin_privilege, owner_id: 1, org_id: 1, location_id: 1)
    ckey = FactoryGirl.create(:admin_privilege, owner_id: 2, org_id: 1, location_id: 1)
    ckey.copy(mkey)
    expect(ckey.master_key).to eq(mkey.id)
    expect(ckey.parent_key).to eq(mkey.id)
  end

  it "after setting up master > parent > child keys, recall parent key should render the child key invalid" do
    master = FactoryGirl.create(:admin_privilege, owner_id: 1, org_id: 1, location_id: 1)
    parent = FactoryGirl.create(:admin_privilege, owner_id: 2, org_id: 1, location_id: 1)
    child = FactoryGirl.create(:admin_privilege, owner_id: 3, org_id: 1, location_id: 1)
    parent.copy(master)
    child.copy(parent)
    expect(child.parent_key).to eq(parent.id)
    expect(child.master_key).to eq(master.id)
    expect(child.is_valid).to eq(true)
    parent.parent_recall
    result = AdminPrivilege.find(child.id)
    expect(result.is_valid).to eq(false)
  end
end