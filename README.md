# Decibel

I use [Decibel 10th Pro Noise Meter](http://skypaw.com/decibel10th.html) to measure noise levels in the office. With the app you can record noise levels, and, as an export option, send the historical data as a zip file to your email address.

The data file doesn't lend itself nicely to work with. This script converts it to something you can use with InfluxDB import

```
./decibel.rb Decibel10thData.zip > data
influx -import -path=data -precision=ms
```

## Description

The data is stored as a "csv" file. The first 9 lines

```
Start Time: 2017/01/03, 10:50:16.920

End Time: 2017/01/03, 12:42:51.520

Min (dB): 32.2
Max (dB): 105.3
Peak (dB): 113.7
Leq (dB): 68.3
Recorded values (dB):
```

contain a description of the session and is then followed by one entry a line of actual measurements:

```
53.7
52.6
55.9
64.3
56.9
54.5
```

## Requirements

* the [Decibel 10th Pro Noise Meter](http://skypaw.com/decibel10th.html) app.
* working Ruby installation
* working InfluxDB
* working Grafana

```
bundle install --path vendor/bundle
```

## Health

> Ideally, you should keep noise levels below  50 decibels if your work requires high concentration or effortless conversation
- [Work Heath and Safety Regulation, Australia](http://www.safework.nsw.gov.au/health-and-safety/safety-topics-a-z/noise-at-work)

