
if defined?(Rails)
  Rails.logger.debug("StoredScript loaded #{__FILE__}")
end

module ItemRubyStoredScript

  # argh: Hash
  #    :item_cd
  def use_item(argh)
    item_count = game_data["content"]["items"][argh[:item_cd]]
    if !item_count || item_count <= 0
      return "You don't have enough item"
    end

    # invoke item effect
    item = first(name: "Item", conditions: { "item_cd" => argh[:item_cd] })
    collection, key = item.stored_script_name.split(".", 2)
    res = execute(name: collection, key: key, args: item.stored_script_args)

    # consume item
    execute(name: "RubyStoredScript", key: "item_outgoing", args: { "item" =>argh[:item_cd], "amount" => 1, "route_cd" => 1 })
    update(name: "GameData", attrs: { "content" => game_data.content })

    res
  end

  # argh: Hash
  #    :target
  #    :percent
  #    :value
  def recovery(argh)
    content = game_data["content"]
    max = content["max_" + argh[:target]]
    additional = (argh[:percent]) ? max * argh[:value] / 100 : argh[:value]
    orig = content[argh[:target]]
    new_val = orig + additional
    if new_val > max
      new_val = max
    end
    content[argh[:target]] = new_val
    game_data["content"] = content
    return "recovery " + argh[:target] + " " + (content[argh[:target]] - orig).to_s + "points"
  end


  def recovery_all(argh)
    game_data["content"]["hp"] = game_data["content"]["max_hp"]
    game_data["content"]["mp"] = game_data["content"]["max_mp"]
    return "curovery HP and MP to max points"
  end

  def love_portion(argh)
    "..."
  end

  def philosophers_stone(argh)
    "The Holy Grail"
  end

  def torch(argh)
    "enlighten"
  end

end
