# -*- coding: utf-8 -*-
require 'spec_helper'

describe "StatusRubyStoredScript" do

  let(:network){ new_network("1000001").tap{|n| n.login.should == true } }
  let(:request){ network.new_action_request }

  describe :status_going do
    # ディレクトリを指定したフィクスチャのロード
    fixtures "simple"

    before do
      request.execute("StatusRubyStoredScript", "status_going", status: 'poison')
      request.get_by_game_data
      request.send_request
    end
    it do
      request.outputs.length.should eq(2)
      request.outputs.first.tap do |o|
        o["error"].should be_nil
        o["result"].should eq("You become a poison state")
      end
      request.outputs.last.tap do |o|
        o["error"].should be_nil
        o["result"].should_not be_nil
        o["result"]["status"].should be_instance_of(::Array)
        o["result"]["status"].first.should eq('poison')
      end
    end
  end

  describe :recovery_status do
    # ディレクトリを指定したフィクスチャのロード
    fixtures "simple"

    before do
      request.execute("StatusRubyStoredScript", "recovery_status", status: 'poison')
      request.send_request
    end
    it do
      request.outputs.length.should eq(1)
      request.outputs.first.tap do |o|
        o["error"].should be_nil
        o["result"].should eq("Recovery your poison state")
      end
    end
  end
end
