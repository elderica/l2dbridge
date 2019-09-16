# vim: set sw=2:
require 'sinatra'
require 'discordrb/webhooks'
require 'line/bot'

unless ENV.has_key? 'LINE_CHANNEL_TOKEN' and
       ENV.has_key? 'LINE_CHANNEL_SECRET' and
       ENV.has_key? 'DISCORD_WEBHOOK_URL'
  puts 'export LINE_CHANNEL_TOKEN, LINE_CHANNEL_SECRET and DISCORD_WEBHOOK_URL'
  exit 1
end

def line_client
  @line_client ||= Line::Bot::Client.new { |config|
    config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    config.channel_secret = ENV['LINE_CHANNEL_SECRET']
  }
end

prev_userid = 0
prev_post_is_image = true

post '/line' do
  body = self.request.body.read
  
  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless line_client.validate_signature(body, signature)
    halt 400, {'Content-Type' => 'text/plain'}, 'Bad request'
  end

  events = line_client.parse_events_from(body)
  events.each do |event|
    case event
    when Line::Bot::Event::Message
      userid = event['source']['userId']
      case event['source']['type']
      when 'user'
        profile = JSON.parse(line_client.get_profile(event['source']['userId']).read_body)
        # ダイレクトメッセージは無視する
        next
      when 'group'
        profile = JSON.parse(line_client.get_group_member_profile(event['source']['groupId'], event['source']['userId']).read_body)
      else
        profile = { displayName: 'unknown' }
      end

      if prev_userid == userid then
        text_header = "　️"
      else
        text_header = "#{profile['displayName']}　：\n"
      end
      prev_userid = userid
      
      discord_client = Discordrb::Webhooks::Client.new(url: ENV['DISCORD_WEBHOOK_URL'])
      case event.type
      when Line::Bot::Event::MessageType::Text
        discord_client.execute do |builder|
          builder.content = "#{text_header}　　#{event.message['text']}"
        end
      when Line::Bot::Event::MessageType::Sticker
        discord_client.execute do |builder|
          url = "https://stickershop.line-scdn.net/stickershop/v1/sticker/#{event.message['stickerId']}/iPhone/sticker_key@2x.png"
          builder.content = "#{text_header}　　#{url}"
        end
      when Line::Bot::Event::MessageType::Image
        #discord_client.execute do |builder|
        #  builder.content = "#{profile['displayName']}　："
        #end
        response = line_client.get_message_content(event.message['id'])
        tf = Tempfile.open(["content", ".jpg"])
        tf.write(response.body)
        tf.close
        tf.open
        discord_client.execute do |builder|
          builder.file = tf
          #builder.add_embed do |embed|
          #  embed.title = "#{profile['displayName']}"
          #end
        end
      end
    end
  end
  
  "OK"
end

