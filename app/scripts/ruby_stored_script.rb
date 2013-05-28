# -*- coding: utf-8 -*-
module RubyStoredScript

  # 説明:
  #   アイテムセット用のオブジェクトの整形を行います。
  #   以下のような変換を行います。
  #     20009 ----> {"20009" => 1}
  #     [10001, 10008, 20001] ----> {"10001" => 1, "10008" => 1, "20001" => 1}
  #     {"10003" => 1,"10010" => 1,"10015" => 1,"20001" => 10} ----> {"10003" => 1,"10010" => 1,"10015" => 1,"20001" => 10}(変換なし)
  #
  # argh: Hash
  #   :source: 入力となるオブジェクト。
  #
  # 戻り値:
  #   :sourceから変換されたHash
  def to_item_hash(argh)
    case argh[:source]
    when Hash then argh[:source]
    when Array then argh[:source].each_with_object({}){ |i, r| r[i.to_s] = 1 }
    else {argh[:source].to_s => 1}
    end
  end

  # argh: Hash
  #   :item    : アイテムコード、アイテムコードの配列、アイテムコードをキー、個数を値とするHashのいずれか。
  #   :route_cd: 取得方法CD
  def item_incoming(argh)
    item_hash = execute(name: "RubyStoredScript", key: "to_item_hash", args: {source: argh[:item]})
    content = game_data["content"]

    items = content["items"] ||= {}
    item_hash.each do |item_code, amount|
      items[item_code.to_s] ||= 0
      items[item_code.to_s] += amount
      create(name: "ItemIncomingLog", attrs: { "player_id" => player.player_id, "created_at" => server_time, "level" => player.level, "item_cd" => item_code, "incoming_route_cd" => argh[:route_cd], "amount" => amount })
    end

    "OK"
  end


  # argh: Hash
  #   :item    : アイテムコード、アイテムコードの配列、アイテムコードをキー、個数を値とするHashのいずれか。
  #   :route_cd: 消費方法CD
  def item_outgoing(argh)
    item_hash = execute(name: "RubyStoredScript", key: "to_item_hash", args: {source: argh[:item]})
    content = game_data["content"]

    items = content["items"] ||= {}
    item_hash.each do |item_code, amount|
      items[item_code.to_s] ||= 0
      items[item_code.to_s] -= amount
      create(name: "ItemOutgoingLog", attrs: { "player_id" => player.player_id, "created_at" => server_time, "level" => player.level, "item_cd" => item_code, "outgoing_route_cd" => argh[:route_cd], "amount" => amount })
    end

    "OK"
  end

end

