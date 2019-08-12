#!/usr/bin/env ruby

require 'homebus'

require 'json'
require 'pp'

CONFIG_FILE='.meteo.json'

homebus_config = []

if File.exists? CONFIG_FILE
  f = File.open CONFIG_FILE, 'r'
  homebus_config = JSON.parse f.read, symbolize_names: true
  f.close
end


provision_request = {
  friendly_name: 'PDX Hackerspace Meteobridge Weather Station',
  friendly_location: 'Portland, OR',
  manufacturer: 'Homebus',
  model: 'Meteobridge',
  pin: 0,
  serial_number: 'indoor',
  devices: [ {
               friendly_name: 'Indoor Conditions',
               friendly_location: 'Portland, OR',
               update_frequency: 0,
               index: 0,
               accuracy: 0,
               precision: 0,
               wo_topics: [ 'temperature', 'pressure', 'hunmidity' ],
               ro_topics: [],
               rw_topics: []
             }
           ]
}

result = HomeBus.provision provision_request

auth_info  = {}

auth_info[:indoor_auth] =  { uuid: result[:uuid],
                             mqtt_server: result[:host],
                             mqtt_port: result[:port],
                             mqtt_username: result[:username],
                             mqtt_password: result[:password]
                           }

provision_request = {
  friendly_name: 'PDX Hackerspace Meteobridge Weather Station',
  friendly_location: 'Portland, OR',
  manufacturer: 'Homebus',
  model: 'Meteobridge',
  pin: 0,
  serial_number: 'outdoor',
  devices: [ {
               friendly_name: 'Outdoor Conditions',
               friendly_location: 'Portland, OR',
               update_frequency: 0,
               index: 0,
               accuracy: 0,
               precision: 0,
               wo_topics: [ 'temperature', 'pressure', 'hunmidity', 'rain_total', 'rain_average', 'wind_average', 'wind_direciton' ],
               ro_topics: [],
               rw_topics: []
             }
           ]
}


result =  HomeBus.provision provision_request

auth_info[:outdoor_auth] =  { uuid: result[:uuid],
                              mqtt_server: result[:host],
                              mqtt_port: result[:port],
                              mqtt_username: result[:username],
                              mqtt_password: result[:password]
                            }

File.open(CONFIG_FILE, 'w') do |f| f.write(JSON.pretty_generate(auth_info)) end
