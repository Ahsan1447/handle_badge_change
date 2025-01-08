# frozen_string_literal: true

# name: handle_badge_change
# about: Handle badge change
# version: 0.1
# authors: Ahsan

enabled_site_setting :enable_handle_badge_change

after_initialize do
  module ::HandleBadge
    PLUGIN_NAME = "handle-badge"

    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace HandleBadge
    end
  end

  require_relative "app/controllers/handle_badges_controller"

  HandleBadge::Engine.routes.draw do
    post "/change" => "handle_badges#change"
  end

  Discourse::Application.routes.append { mount ::HandleBadge::Engine, at: "/handle_badge" }

end
