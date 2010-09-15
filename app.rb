# encoding: utf-8
require 'sinatra/base'
require 'json'
require 'gruff'

class Charter < Sinatra::Base
  set :env,                   :production
  set :app_file,              __FILE__
  set :root,                  File.dirname(__FILE__)
  set :public,                Proc.new { File.join(root, "public") }
  enable                      :static

  post  %r{^/chart/?$} do render(@chart = JSON.parse(request.body.read.to_s)) end
  get   %r{^/chart/?$} do render(@chart = params[:chart]) end

  helpers do
    def layout
      @chart_layout ||= {
        :charts_dir         => File.join(settings[:public], 'charts'),
        :size               => ( @chart['size']             || '300x200'        ),
        :hide_title         => ( @chart['hide_title']       || true             ),
        :hide_legend        => ( @chart['hide_legend']      || true             ),
        :right_margin       => ( @chart['right_margin']     || 0                ),
        :left_margin        => ( @chart['left_margin']      || 0                ),
        :bar_spacing        => ( @chart['bar_spacing']      || 0.8              ),
      }
    end

    def theme
      @chart_theme ||= {
        :marker_color       => ( @chart['marker_color']      || '#999'           ),
        :marker_font_size   => ( @chart['marker_font_size']  || 16               ),
        :colors             => ( @chart['colors']            || ['#6cb12f']      ),
        :marker_color       => ( @chart['marker_color']      || '#000'           ),
        :font_color         => ( @chart['font_color']        || '#666'           ),
        :background_colors  => ( @chart['background_colors'] || ['#fff', '#fff'] )
      }
    end

    def chart_full_path
      File.join layout['charts_dir'], chart_name
    end

    def chart_name
      @chart_name ||= "#{Digest::MD5.hexdigest chart.to_s}.png"
    end

    def render
      stored?(@chart) ? serve(@chart) : draw(@chart)
    end

    def stored?(chart)
      File.exists? chart_name
    end
    
    def draw(chart)
      g                 = Gruff::Bar.new layout['size']
      g.title           = chart['title']
      g.theme           = chart_theme
      g.labels          = chart['labels'].each_pair {|k,v| labels[k.to_i] = v}
      layout.each_pair  { |k, v| g.send :"#{k}=", v }
      g.data chart['data'].first, chart['data'].last.map(&:to_i)
      serve @chart if g.write chart_full_path
    end

    def serve(chart)
    end
  end
end
