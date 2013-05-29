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




  # argh: Hash
  #   :product_cd: 商品CD
  #   :collection: 商品メニューマスタのコレクション名
  #
  # return:
  #    :collection のマスタの :product_cd の商品の購入トランザクションを開始します。
  def order(argh)
    payment = first(name: argh[:collection], conditions: { product_cd: argh[:product_cd] })
    items = {
      "collection_name" => argh[:collection],
      "product_cd" => argh[:product_cd],
      "item_name" => payment["name"],
      "unit_price" => payment["price"],
      "image_url" => payment["image_url"],
      "description" => payment["description"]
    }
    start_payment(message: argh[:message], items: items)
  end

  # argh: Hash
  #   :item_cd 購入したアイテムのID
  #   :amount  購入個数
  def buy(argh)
    item_incoming(item: { argh[:item_cd].to_s => argh[:amount] }, route_cd: 1)
    content = game_data.content
    update(name: "GameData", attrs: { "content" => content })
  end

  def purchase_log(argh)
    # argh[:log] に受け取った購入ログの独自フィールドをうめる
    # login_days を追加
    argh[:log]["login_days"] = player.login_days
    argh[:log]
  end

end

