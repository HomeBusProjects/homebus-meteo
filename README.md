# homebus-meteo

A Homebus publisher which publishes weather station data from a Meteobridge.

The software provides webhook which receives current weather conditions from a Meteobridge. It creates JSON payloads to publish indoor and outdoor data separately.

## Setup

1. Clone the repository.
```
git clone https://github.com/HomeBusProjects/homebus-meteo
cd homebus-meteo
```

2. Install the needed gems
```
bundle install
```

3. Provision the publisher
```
bundle exec ./provision -b localhost -P 80
```

This will generate a Homebus provisioning request for indoor and outdoor conditions. You may need to change `localhost` and `80` to be the correct name or IP address and port number of the Homebus provisioner for your system.

4. Run the webhook server
```
puma -p 9394 access.ru
```

This tells Puma to execute the Sinatra app in access.ru and bind it to port 9394. The Nginx configuration file in step 5 depends on port number 9394; if you change the port you'll need to change the Nginx configuration as well.

If your server supports systemd, you may wish to install the systemd script located in `systemd/homebus-meteo.service`. Copy it to `/etc/systemd/system` and run:
```
sudo systemctl daemon-reload
sudo systemctl enable homebus-meteo
sudo systemctl start homebus-meteo
```

You'll need to edit the file if you don't install `homebus-meteo` in the location expected in the file.

5. Configure nginx
```
sudo cp nginx/meteo-webhook.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/meteo-webhook.conf /etc/nginx/sites-enabled/meteo-webhook.conf
sudo systemctl reload nginx
```

7. Configure Meteobridge

`http://HOSTNAME:PORT/?outdoor_temperature=[th0temp-act.1:--]&outdoor_humidity=[th0hum-act.1:--]&indoor_temperature=[thb0temp-act.1:--]&indoor_humidity=[thb0hum-act.1:--]&pressure=[thb0press-act.1:--]&wind_average=[wind0avgwind-act.1:--]&wind_direction=[wind0dir-act.1:--]&rain_total=[rain0total-act.1:--]&rain_rate=[rain0rate-act.1:--]`

***coming soon***

8. Test


## LICENSE

This code is licensed under the [MIT License](https://romkey.mit-license.org).
