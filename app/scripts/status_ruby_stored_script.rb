
module StatusRubyStoredScript

  # argh: Hash
  #    :status
  def status_going(argh)
    current_status = game_data["status"] || []
    going_status = argh[:status]

    if going_status.blank?
      if current_status.blank?
        return "Your status is normal"
      else
        current_status_line = current_status.map{|s| s }.join(', ')
        return "Your status is #{current_status_line}"
      end
    end

    current_status << going_status unless current_status.include?(going_status)
    update(name: "GameData", attrs: { "status" => current_status })

    return "You become a #{going_status} state"
  end

  # argh: Hash
  #    :status
  def recovery_status(argh)
    current_status = game_data["status"] || []
    going_status = argh[:status]

    if going_status.blank?
      if current_status.blank?
        return "Your status is normal"
      else
        current_status_line = current_status.map{|s| s }.join(', ')
        return "Your status is #{current_status_line}"
      end
    end

    current_status.delete(going_status) if current_status.include?(going_status)
    update(name: "GameData", attrs: { "status" => current_status })

    return "Recovery your #{going_status} state"
  end

end
