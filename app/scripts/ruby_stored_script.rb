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






end

