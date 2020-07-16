require 'sinatra/base'
require 'mqtt'

require 'pp'
require 'json'

class MeteoWebhook < Sinatra::Base
  DDC_WEATHER = 'org.homebus.experimental.weather'
  DDC_INDOOR = 'org.homebus.experimental.air-sensor'

  CONFIG_FILE='.meteo.json'

  homebus_config = []
  if File.exists? CONFIG_FILE
    f = File.open CONFIG_FILE, 'r'
    homebus_config = JSON.parse f.read, symbolize_names: true
    f.close
  else
    abort "no config file"
  end

  # separate MQTT connections because each is only authorized to publish to its own UUID
  indoor = homebus_config[:indoor_auth]
  indoor[:mqtt] = MQTT::Client.connect(indoor[:mqtt_server], port: indoor[:mqtt_port], username: indoor[:mqtt_username], password: indoor[:mqtt_password])

  outdoor = homebus_config[:outdoor_auth]
  outdoor[:mqtt] = MQTT::Client.connect(outdoor[:mqtt_server], port: outdoor[:mqtt_port], username: outdoor[:mqtt_username], password: outdoor[:mqtt_password])

  get '/' do
    if params['indoor_temperature'] != '--'
      indoor_data = {
        source: indoor[:uuid],
        timestamp: Time.now.to_i,
        contents: {
          ddc: DDC_INDOOR,
          payload:  {
            temperature: params['indoor_temperature'].to_f,
            humidity: params['indoor_humidity'].to_f,
            pressure: params['pressure'].to_f
          }
      }

      indoor[:mqtt].publish "homebus/device/#{indoor[:uuid]}/#{DDC_INDOOR}",
                            JSON.generate(indoor_data),
                            true
    else
      msg = {
        msg: "Invalid data received from intdoor sensors",
        timestamp: Time.now.to_i
      }

      indoor[:mqtt].publish "homebus/device/#{indoor[:uuid]}/$error",
                            JSON.generate(msg)
    end

    if params['outdoor_temperature'] != '--'
      outdoor_data = {
        source: outdoor[:uuid],
        timestamp: Time.now.to_i,
        contents: {
          ddc: DDC_WEATHER,
          payload: {
            temperature: params['outdoor_temperature'].to_f,
            humidity: params['outdoor_humidity'].to_f,
            pressure: params['pressure'].to_f,
            rain_total: params['rain_total'].to_f,
            rain_rate: params['rain_rate'].to_f,
            wind_average: params['wind_average'].to_f,
            wind_direction: params['wind_direction'].to_f
          }
        }
      }

      outdoor[:mqtt].publish "homebus/device/#{outdoor[:uuid]}/#{DDC_WEATHER}",
                             JSON.generate(outdoor_data),
                             true
    else
      msg = {
        msg: "Invalid data received from outdoor sensors",
        timestamp: Time.now.to_i
      }

      outdoor[:mqtt].publish "/homebus/device/#{outdoor[:uuid]}/$error",
                             JSON.generate(msg)
    end

    'OK'
  end
end

run MeteoWebhook
