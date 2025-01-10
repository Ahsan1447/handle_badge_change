# frozen_string_literal: true

class HandleBadge::HandleBadgesController < ::ApplicationController
  requires_plugin HandleBadge::PLUGIN_NAME

  def change
    pro_level_mapping = {
      "not_pro" => 'Not Pro',
      "pro" => 'Pro',
      "expert" => 'Expert',
      "master" => 'Master',
      "block_pro" => 'Block Pro'
    }

    username = params[:username]
    pro_level = params[:pro_level]
    email = params[:email]
    external_id = params[:external_id]

    user = User.find_by_username(username)

    if user.nil?
      user = create_user(params)
      return render json: { success: false, error: "User creation failed" }, status: :unprocessable_entity if user.nil?

      unless create_single_sign_on(params, user)
        return render json: { success: false, error: "SSO record creation failed" }, status: :unprocessable_entity
      end
    end

    current_group = Group.find_by_name(pro_level)
    return if current_group.nil?

    pro_level_group_ids = Group.where(name: pro_level_mapping.keys).pluck(:id)
    user.group_users.where(group_id: pro_level_group_ids).destroy_all
    user.group_users.create(group_id: current_group.id, notification_level: 3)

    render json: { success: true }
  end

  private

  def create_user(params)
    user = User.create!(
      username: params[:username],
      email: params[:email],
      password: "Password@789"
    )

    return user if user.activate

    nil
  end

  def create_single_sign_on(params, user)
    SingleSignOnRecord.create(
      user_id: user.id,
      external_id: params[:external_id],
      external_username: params[:username],
      external_email: params[:email],
      last_payload: {}
    )
  rescue ActiveRecord::RecordInvalid
    false
  end

end
