# -*- coding: utf-8 -*-

require 'net/http'

module RubyStoredScript
  # 説明
  #   動作確認用のメソッドです。
  #
  # argh: Hash
  #
  # 戻り値:
  #   キーをecho値を入力値のarghとするHash
  def echo(argh)
    {echo: argh}
  end


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








  # 引数: player1, player2
  # player1, player2 の player_cd で表わされるプレイヤー同士がフレンドかどうか(Friendship にドキュメントがあるか)を判定して
  # フレンドなら true を、そうでなければ false を返します。
  def is_friend(argh)
    friendship = first(
                 name: "Friendship",
                 conditions: {
                         "$or" => [
                           {
                             "requester_id" => argh[:player1],
                             "accepter_id" => argh[:player2],
                           },
                           {
                             "requester_id" => argh[:player2],
                             "accepter_id" => argh[:player1],
                           }
                         ]
                       }
                 )
    if (friendship and 2 == friendship.status_cd)
      true
    else
      false
    end
  end

  # ログインプレイヤーのフレンド(フレンドシップの状態が2：承認済み)のplayer_idを配列で返します。
  def get_friends(argh)
    friends = all(
              name: "Friendship",
              conditions: {
                    "$or" => [
                      {
                        "requester_id" => player.player_id,
                      },
                      {
                        "accepter_id" => player.player_id,
                      }
                    ],
                    "status_cd" => 2,
                  }
              )
    friends.map{|f| (player.player_id == f["requester_id"]) ? f["accepter_id"] : f["requester_id"] }
  end

  # ログインプレイヤーがフレンド申請中のプレイヤーのplayer_idを配列で返します。
  def get_applyings(argh)
    friends = all(
              name: "Friendship",
              conditions: {
                    "$or" => [
                      {
                        "requester_id" => player.player_id,
                        "status_cd" => 1
                      },
                      {
                        "accepter_id" => player.player_id,
                        "status_cd" => 4
                      }
                    ]
                  }
              )
    friends.map{|f| (player.player_id == f["requester_id"]) ? f["accepter_id"] : f["requester_id"] }
  end

  # ログインプレイヤーに対してフレンド申請中のプレイヤーのplayer_idを配列で返します。
  def get_applied(argh)
    friends = all(
              name: "Friendship",
              conditions: {
                    "$or" => [
                      {
                        "requester_id" => player.player_id,
                        "status_cd" => 4
                      },
                      {
                        "accepter_id" => player.player_id,
                        "status_cd" => 1
                      }
                    ]
                  }
              )
    friends.map{|f| (player.player_id == f["requester_id"]) ? f["accepter_id"] : f["requester_id"] }
  end

  # 引数: player, point
  # player で指定されたプレイヤーの greeting_points に引数 point で指定された数を加算します。加算結果のあいさつポイントを返します。
  def add_greeting_points(argh)
    game_data = get(name: "GameData", player_id: argh[:player])
    greeting_points = game_data["greeting_points"]
    greeting_points += argh[:point]
    update(name: "GameData", player_id: argh[:player], attrs: { greeting_points: greeting_points })
    greeting_points
  end

  # 現在時刻を元にあいさつ定形文の定型文CDを返します
  def predefined_greeting(argh)
    # 時刻を元にあいさつ定型文を選択する
    #  4:00-10:00 => 1 おはようございます！
    # 10:00-16:00 => 2 こんにちは！
    # 16:00-22:00 => 3 こんばんは！
    # 22:00- 4:00 => 4 Zzzzz
    case server_time().hour
    when 4...10
      1
    when 10...16
      2
    when 16...22
      3
    when 0...4, 22...24
      4
    end
  end

  # 引数 friend で指定したフレンドに対して定形文のあいさつをする。
  # あいさつ相手とフレンドであることを確認
  # あいさつ相手へ同じ日付けであいさつ済みでないことを確認
  # あいさつ定型文を時刻を元に自動的に選択
  # あいさつ履歴を登録
  # あいさつポイントを自分、相手に付与
  # コンタクトログを保存
  def greet_friend(argh)
    # 自分の player_cd を取得
    pl = get(name: "Player")
    my_player_cd = pl["player_id"]
    my_level = pl["level"]

    # あいさつ相手とフレンドであることを確認する
    unless is_friend("player1" => my_player_cd, "player2" => argh[:friend])
      return "player #{argh[:friend]} is not your friend"
    end

    # あいさつする相手への最後のあいさつから日付が変更されていることを確認
    last_greet = first name: "GreetingHistory", conditions: { "sender_cd" => my_player_cd, "receiver_cd" => argh[:friend] }, order: "send_at DESC"
    if last_greet and (server_date() == server_date(time: last_greet["send_at"]))
      return "already send greetings this day"
    end

    # 時刻を元にあいさつ定型文を選択する
    greeting_cd = predefined_greeting

    # あいさつ履歴を登録
    create name: "GreetingHistory",
    attrs: {
      "sender_cd" =>  my_player_cd,
      "receiver_cd" =>  argh[:friend],
      "send_at" => server_time(),
      "greeting_cd" => greeting_cd
    }

    # あいさつポイントを付与
    add_greeting_points(player: my_player_cd, point: 3)
    add_greeting_points(player: argh[:friend], point: 3)

    # コンタクトログを保存
    create name: "ContactLog",
    attrs: {
      "sender_cd" => my_player_cd,
      "receiver_cd" => argh[:friend],
      "created_at" => server_time(),
      "contact_cd" => 1,
      "level" => my_level
    }

    "OK"
  end

  def greet_all_friends(argh)
    friendships = all(name: "Friendship", conditions: {"$or" => [{"requester_id" => player.player_id}, {"accepter_id" => player.player_id } ] })

    friendships.each do |fs|
      fid = (fs.requester_id == player.player_id) ? fs.accepter_id : fs.requester_id
      execute(name: "RubyStoredScript", key: "greet_friend", args: {friend: fid})
    end

    "OK"
  end





  # argh: Hash
  #     :items: 合成に用いるアイテムコードをキー、個数を値とするHash
  #
  # アイテム合成1を参照して合成結果を決定し、合成に用いたアイテムを消費、合計結果のアイテムを取得してGameDataを保存します。
  # :items で指定したアイテム群で合成ができない時は "Cannot Composite" を返します。
  # 指定したアイテムを所有していない時は "Item Shortage" を返します。
  # 成功時は合成結果のアイテムのアイテムコードをキー、個数を値とするHashを返します。
  def composite_items(argh)
    # 指定されたアイテムが合成確率テーブルに存在するかをチェック
    unless first(name: "Composition1", conditions: { element: argh[:items] })
      return "Cannot Composite"
    end

    # 指定されたアイテムを保持しているかをチェック
    argh[:items].each do |item_id, num|
      if game_data.content["items"][item_id.to_s].nil? or
          game_data.content["items"][item_id.to_s] < num
        return "Item Shortage"
      end
    end

    # 合成結果を取得
    result = dice(name: "Composition1", conditions: { element: argh[:items]})
    case result
    when Integer
      result = { result.to_s => 1 }
    when Array
      result = result.each_with_object({}){|i, o| o[i.to_s] = 1 }
    when Hash
      result = result
    end

    # 利用したアイテムを減らす
    item_outgoing("item" => argh[:items], "route_cd" => 2)
    # 取得したアイテムを格納
    item_incoming("item" => result, "route_cd" => 8)

    # GameData の保存
    update(name: "GameData", attrs: { "content" => game_data.content })

    return result
  end


  # 引数: argh[:armor]: 進化させる装備品の armor_id
  # 装備進化1 を参照して装備品の進化後を取得して、賢者の石を1つ消費して装備品を進化後のものに置き換えます。
  # 指定した装備品が進化できないものだったら "Cannot Upgrade" を返します。
  # 指定した装備品を所有していなかったら "Armor Shortage" を返します。
  # 賢者の石(20011)を所有していなかったら "Item Shortage" を返します。
  # 成功時は進化後の装備品の armor_id を返します。
  def upgrade_armor(argh)
    # 指定されたアイテムが装備進化テーブルに存在するかをチェック
    upgraded = first(name: "ArmorUpgrade1", conditions: { input: argh[:armor]} )
    if upgraded.nil?
      return "Cannot Upgrade"
    end
    upgraded = upgraded.output

    # 指定された装備品を保有しているかをチェック
    num = game_data.content["items"][argh[:armor].to_s]
    if num.nil? or num < 1
      return "Armor Shortage"
    end

    # 賢者の石(20011)を所有しているかをチェック
    num = game_data.content["items"]["20011"]
    if num.nil? or num < 1
      return "Item Shortage"
    end

    # 進化元装備を減らす
    item_outgoing(item: argh[:armor], route_cd: 6)
    # 賢者の石を減らす
    item_outgoing(item: 20011, route_cd: 1)
    # 進化結果の装備を格納
    item_incoming(item: upgraded, route_cd: 9)

    # GameData の保存
    update(name: "GameData", attrs: { "content" => game_data.content })

    return upgraded
  end






  # 説明: 経験値を加算する。レベルに必要な経験値表を参照してレベルアップもする。
  # 戻り値:
  #  加算後の経験値
  #  元のレベル
  #  加算後のレベル
  # の配列。元のレベルと加算後のレベルが異なっていたらレベルアップしている
  def add_exp(argh)
    # ゲームデータの contents["exp"] に加算
    gamedata = get(name: "GameData")
    gamedata["content"]["exp"] ||= 0
    gamedata["content"]["exp"] += argh[:exp]
    update(name: "GameData", attrs: { "content" => gamedata["content"] })

    # 必要経験値表を検索してレベルを設定
    oldlevel = player.level
    level = get(name: "RequiredExperience", input: gamedata["content"]["exp"])
    if player.level != level
      update(name: "Player", attrs: { "level" => level })
    end

    [ gamedata["content"]["exp"], oldlevel, level ]
  end







  # 購入した内容をGameData.content["items"]に反映させる
  # 引数
  #   product_cd: 商品CD
  #   amount: 購入数
  #
  # {"inputs": [
  #   {"id":"ID123",
  #    "action": "execute",
  #     "name": "RubyStoredScript",
  #     "key": "buy_item2",
  #     "args": { "product_cd": 10001, "amount": 1}
  #   }
  # ] }
  def buy_item2(argh)
    item = first(name: get(name: "ShopSchedule"), conditions: { product_cd: argh[:product_cd] } )
    total = item.price * argh[:amount]

    c = game_data.content
    return "no money!" if (c["money"] < total)

    c["money"] -= total

    case item.items
    when Integer
      items = { item.items.to_s => 1 }
    when Array
      items = item.items.each_with_object({}){|item_cd, obj| obj[item_cd.to_s] = 1 }
    when Hash
      items = item.items
    else
      return "invalid items in ShopMenu1 product_cd=#{argh[:product_cd]}"
    end

    items.each do |item_cd, num|
      execute(name: "RubyStoredScript", key: "item_incoming", args: { item: {item_cd => num * argh[:amount]}, route_cd: 1} )
    end
    create(name: "PurchaseLog", attrs: { "player_id" => player.player_id, "created_at" => server_time, "level" => player.level, "product_cd" => argh[:product_cd], "unit_price" => item.price, "amount" => argh[:amount], "price" => total })

    update(name: "GameData", attrs: {"content" => game_data.content})
    "OK"
  end


  # 引数: argh[:armor]: 進化させる装備品の armor_id
  # 装備進化1 を参照して装備品の進化後を取得して、賢者の石を1つ消費して装備品を進化後のものに置き換えます。
  # 指定した装備品が進化できないものだったら "Cannot Upgrade" を返します。
  # 指定した装備品を所有していなかったら "Armor Shortage" を返します。
  # 賢者の石(20011)を所有していなかったら "Item Shortage" を返します。
  # 成功時は進化後の装備品の armor_id を返します。
  #
  #
  # {"inputs": [
  #   {"id":"ID123",
  #    "action": "execute",
  #     "name": "RubyStoredScript",
  #     "key": "upgrade_armor2",
  #     "args": { "armor": 10001 }
  #   }
  # ] }
  def upgrade_armor2(argh)
    # 指定されたアイテムが装備進化テーブルに存在するかをチェック
    upgraded = first(name: get(name: "ArmorUpgradeSchedule"), conditions: { input: argh[:armor]} )
    if upgraded.nil?
      return "Cannot Upgrade"
    end
    upgraded = upgraded.output

    # 指定された装備品を保有しているかをチェック
    num = game_data.content["items"][argh[:armor].to_s]
    if num.nil? or num < 1
      return "Armor Shortage"
    end

    # 賢者の石(20011)を所有しているかをチェック
    num = game_data.content["items"]["20011"]
    if num.nil? or num < 1
      return "Item Shortage"
    end

    # 進化元装備を減らす
    item_outgoing(item: argh[:armor], route_cd: 6)
    # 賢者の石を減らす
    item_outgoing(item: 20011, route_cd: 1)
    # 進化結果の装備を格納
    item_incoming(item: upgraded, route_cd: 9)

    # GameData の保存
    update(name: "GameData", attrs: { "content" => game_data.content })

    return upgraded
  end

  # AppStoreで購入したレシートを認証して購入済みアイテムを増やします
  #
  # 引数
  #   receipt_data: レシートデータ
  #
  def process_receipt(argh)
    params_json = {"receipt-data" => argh[:receipt_data]}.to_json
    # uri = URI("https://sandbox.itunes.apple.com")

    # logger.debug("AppGarden.platform: #{AppGarden.platform.inspect}")

    uri = URI.parse(AppGarden.platform["app_store"]["url"])
    res = nil
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      r = http.post('/verifyReceipt', params_json)
      case r.code
      when /\A2\d\d\Z/ then # 200番台
        res = JSON.parse(r.body)
      else
        msg = "iTunes storeとの通信に失敗しました。 [#{r.code}] #{r.body}"
        logger.error(msg)
        raise msg
      end
    end
    unless res["status"] == 0 #OK
      msg = "iTunes storeからエラーが返されました。"
      logger.error(msg + ": #{r.body}")
      raise msg
    end

    # resの例
    # {"receipt"=>
    #   {"original_purchase_date_pst"=>"2013-07-08 00:58:46 America/Los_Angeles",
    #    "purchase_date_ms"=>"1373270326687",
    #    "unique_identifier"=>"d716285c22e00afc96f5080509474bc45050628f",
    #    "original_transaction_id"=>"1000000079800467",
    #    "bvrs"=>"1.0",
    #    "transaction_id"=>"1000000079800467",
    #    "quantity"=>"1",
    #    "unique_vendor_identifier"=>"9D256572-7521-495A-8EC8-5568AD85114E",
    #    "item_id"=>"668930184",
    #    "product_id"=>"jp.groovenauts.libgss.cocos2dx.sample1.stone1",
    #    "purchase_date"=>"2013-07-08 07:58:46 Etc/GMT",
    #    "original_purchase_date"=>"2013-07-08 07:58:46 Etc/GMT",
    #    "purchase_date_pst"=>"2013-07-08 00:58:46 America/Los_Angeles",
    #    "bid"=>"jp.groovenauts.libgss.cocos2dx.sample1",
    #    "original_purchase_date_ms"=>"1373270326687"},
    #  "status"=>0}

    # logger.debug("res: #{res.inspect}")

    receipt = res["receipt"]

    # logger.debug("receipt: #{receipt.inspect}")

    purchase_item_incoming(:item => {receipt["product_id"] => receipt["quantity"].to_i}) # このメソッドの戻り値を返す
  end

  # argh: Hash
  #   :item    : アイテムコード、アイテムコードの配列、アイテムコードをキー、個数を値とするHashのいずれか。
  def purchase_item_incoming(argh)
    item_hash = to_item_hash({source: argh[:item]})
    content = game_data["content"]

    items = content["purchase_items"] ||= {}
    item_hash.each do |item_code, amount|
      items[item_code.to_s] ||= 0
      items[item_code.to_s] += amount
      # create(name: "ItemIncomingLog", attrs: { "player_id" => player.player_id, "created_at" => server_time, "level" => player.level, "item_cd" => item_code, "incoming_route_cd" => argh[:route_cd], "amount" => amount })
    end

    # logger.debug("item_hash: #{item_hash.inspect}")
    # logger.debug("content: #{content.inspect}")

    update(name: "GameData", attrs: { "content" => content })

    "OK"
  end


end

