require 'spec_helper'

describe Micropost do

  let(:user) { FactoryGirl.create(:user) }
  before { @micropost = user.microposts.build(content: "Lorem ipsum") }

  subject { @micropost }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:in_reply_to) }
  it { should respond_to(:private) }
  its(:user) { should == user }

  it { should be_valid }
 
  describe "when user_id is not present" do
    before { @micropost.user_id = nil }
    it { should_not be_valid }
  end

  describe "accessible attributes" do
    it "should not allow access to user_id" do
      expect do
        Micropost.new(user_id: user.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "with blank content" do
    before { @micropost.content = " " }
    it { should_not be_valid }
  end

  describe "with content that is too long" do
    before { @micropost.content = "a" * 141 }
    it { should_not be_valid }
  end

  describe "#self.from_users_followed_by_including_replies" do
    let(:recipient){ FactoryGirl.create(:user, username: "recipient") }
    let(:sender) { FactoryGirl.create(:user, username: "sender") }
    before { @mp = sender.microposts.create(content: "@recipient something", in_reply_to: recipient.id)}

    it "for 'recipient', microposts should include the 'sender's micropost" do
      Micropost.from_users_followed_by_including_replies(recipient).should include(@mp)
    end
  end

  # good info about testing callbacks:
  # https://makandracards.com/makandra/725-test-activerecord-callbacks-with-rspec
  
  let!(:mentioned_user) { FactoryGirl.create(:user, username: "test_user") }
  
  describe "#extract_in_reply_to" do
    context "when a user is mentioned" do
      before { @micropost.content = "@test_user hey ho hey" }
      it "should populate the in_reply_to field" do
        @micropost.send(:extract_in_reply_to)
        @micropost.in_reply_to.should == mentioned_user.id
      end
    end

    context "when a user is not mentioned" do
      before { @micropost.content = "hey ho hey" }
      it "should not populate the in_reply_to field" do
        @micropost.send(:extract_in_reply_to)
        @micropost.in_reply_to.should be nil
      end
    end
  end

  describe "before_save" do
    it "should run the proper callbacks" do
      @micropost.should_receive(:extract_in_reply_to)
      @micropost.run_callbacks(:save)
    end
  end

  describe "#extract_private" do
    context "when a micropost is private" do
      before { @micropost.content = "d @test_user what's up?" }
      it "should change the private field" do
        @micropost.send(:extract_private)
        @micropost.private.should == true
      end
    end
  
    context "when a micropost is not private" do
      before { @micropost.content = "yo yo yo" }
      it "should not change the private field" do
        @micropost.send(:extract_private)
        @micropost.private.should be false
      end
    end
  end
end
