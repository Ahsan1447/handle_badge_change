# frozen_string_literal: true

class HandleBadge::AnswerController < ::ApplicationController
  requires_plugin HandleBadge::PLUGIN_NAME

  def change
    pro_level_mapping = {
      "not_pro" =>  'Not Pro',
      "pro" =>  'Pro',
      "expert" =>  'Expert',
      "master" =>  'Master',
      "block_pro" => 'Block Pro'
    }

    username = params[:username]
    pro_level = params[:pro_level]
    user = User.find_by_username(username)
    current_group = Group.find_by_name(pro_level)
    return if user.nil? || current_group.nil?

    pro_level_group_ids = Group.where(name: pro_level_mapping.keys).pluck(:id)
    user.group_users.where(group_id: pro_level_group_ids).destroy(false)
    user.group_users.create(group_id: current_group.id, notification_level: 3)
  end

end
