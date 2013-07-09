# -*- coding: utf-8 -*-
require 'spec_helper'

describe "RubyStoredScript" do

  context "何も課金アイテムを持っていない人" do

    fixtures "simple"

    let(:network){ new_network("1000007").tap(&:login) } # HPが1の人
    let(:request){ network.new_action_request }
    let(:receipt_data){ IO.read(File.expand_path("../ruby_stored_script_spec/receipt_stone1", __FILE__)) }

    describe "before_purchase" do
      before do
        request.get_by_game_data
        request.send_request
      end
      it do
        request.outputs.length.should == 1
        request.outputs.last.tap do |o|
          o["error"].should == nil
          o["result"].should_not == nil
          o["result"]["content"]["purchase_items"].should == nil
        end
      end
    end

    describe "stone1" do
      before do
        request.execute("RubyStoredScript", "process_receipt", receipt_data: receipt_data)
        request.get_by_game_data
        request.send_request
      end
      it do
        request.outputs.length.should == 2
        request.outputs.first.tap do |o|
          o["error"].should == nil
          o["result"].should == "OK"
        end
        request.outputs.last.tap do |o|
          o["error"].should == nil
          o["result"].should_not == nil
          o["result"]["content"].should == {}
          o["result"]["content"]["purchase_items"].should == {"jp.groovenauts.libgss.cocos2dx.sample1.stone1" => 1}
        end
      end
    end
  end

  context "既に課金アイテムを持っている人" do

    fixtures "simple"

    let(:network){ new_network("1000001").tap(&:login) }
    let(:request){ network.new_action_request }
    let(:receipt_data){ IO.read(File.expand_path("../ruby_stored_script_spec/receipt_stone1", __FILE__)) }

    describe "before_purchase" do
      before do
        request.get_by_game_data
        request.send_request
      end
      it do
        request.outputs.length.should == 1
        request.outputs.last.tap do |o|
          o["error"].should == nil
          o["result"].should_not == nil
          o["result"]["content"]["purchase_items"].should == {"jp.groovenauts.libgss.cocos2dx.sample1.stone1" => 10}
        end
      end
    end

    describe "stone1" do
      before do
        request.execute("RubyStoredScript", "process_receipt", receipt_data: receipt_data)
        request.get_by_game_data
        request.send_request
      end
      it do
        request.outputs.length.should == 2
        request.outputs.first.tap do |o|
          o["error"].should == nil
          o["result"].should == "OK"
        end
        request.outputs.last.tap do |o|
          o["error"].should == nil
          o["result"].should_not == nil
          o["result"]["content"]["purchase_items"].should == {"jp.groovenauts.libgss.cocos2dx.sample1.stone1" => 11}
        end
      end
    end
  end

end
