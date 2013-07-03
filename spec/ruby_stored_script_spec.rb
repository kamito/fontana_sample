# -*- coding: utf-8 -*-
require 'spec_helper'

describe "RubyStoredScript" do

  let(:network){ new_network("1000007").tap(&:login) } # HPが1の人
  let(:request){ network.new_action_request }

  describe :echo do
    let(:argh){ {"foo" => {"bar" => "baz"} } }
    before do
      request.execute("RubyStoredScript", "echo", argh)
      request.send_request
    end
    it do
      request.outputs.length.should == 1
      request.outputs.first["result"].should == {"echo" => argh}
    end
  end

  describe :use_item do

    # ディレクトリを指定したフィクスチャのロード
    fixtures "simple"

    # ファイルを単独で指定したフィクスチャのロード（v0.3.0では未サポート）
    # fixtures "simple/GameData.yml"

    before do
      request.execute("ItemRubyStoredScript", "use_item", item_cd: "20001")
      request.get_by_game_data
      request.send_request
    end
    it do
      request.outputs.length.should == 2
      request.outputs.first.tap do |o|
        o["error"].should == nil
        o["result"].should == "recovery hp 14points"
      end
      request.outputs.last.tap do |o|
        o["error"].should == nil
        o["result"].should_not == nil
        o["result"]["content"]["hp"].should == 15 # HPが回復している
        o["result"]["content"]["items"]["20001"].should == 2 # 一つ減っている
      end
    end

  end

  describe "love_potion" do
    fixtures "simple"

    before do
      request.execute("ItemRubyStoredScript", "love_potion", item_cd: "20001")
      request.send_request
    end
    it do
      request.outputs.length.should == 1
      request.outputs.first.tap do |o|
        o["error"].should == nil
        o["result"].should == "Wow!"
      end
    end
  end

end
