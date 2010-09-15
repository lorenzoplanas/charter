# encoding: UTF-8
require 'sinatra/base'

class Charter < Sinatra::Base
  helpers Sinatra::Charter::Helpers
  set :env,                   :production
  set :app_file,              __FILE__
  set :root,                  File.dirname(__FILE__)
  set :public,                Proc.new { File.join(root, "public") }
  enable                      :static

  # Default chart theme
  set :hide_title,            true
  set :hide_legend,           true
  set :right_margin,          0
  set :left_margin,           0
  set :marker_color,          '#999'
  set :marker_font_size,      16

  post %r{^/chart/(\w+)\.json/?$} do render :from => :json  end
  post %r{^/chart/(\w+)/?$}       do render                 end
end
