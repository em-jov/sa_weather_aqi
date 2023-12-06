# Sarajevo weather & air pollution
> Simple, static [web page](https://sa-aqi-weather.simplify.ba/) providing comprehensive weather and AQI (air quality index) details for Sarajevo, known as the most polluted city in Europe.

## Overview

The Ruby script gathers essential data either from third-party APIs or by scraping when APIs are unavailable. It then compiles this information into a template. The script is scheduled to run every hour using AWS Lambda to keep the data up-to-date.

## Features
- Real-time current weather updates.
- 5-day weather forecast provided in 3-hour intervals.
- Hourly AQI data available for 5 monitoring sites, detailing AQI for each pollutant.
- Hourly city-wide AQI data, with breakdowns for each pollutant.

## Prerequisites
Ensure that you have the following installed on your machine:

Ruby: Download and install Ruby from https://www.ruby-lang.org/en/downloads/.

Bundler: Install Bundler by running **'gem install bundler'**.

## Project Setup
1. Clone the Repository:
```
git clone https://github.com/em-jov/sa_weather_aqi.git
cd sa_weather_aqi
```
2. Install Dependencies:
```
bundle install
```
3. Configure
..

## Customization
Modify the target URL, CSS selector, and scraping logic in the **aqi_guide module** according to your requirements.
Customize the HTML content in the **template.html.erb** file.

## Contributing
If you find issues or have improvements, feel free to open an issue or submit a pull request.

## License

## Acknowledgments
[Nokogiri](https://github.com/sparklemotion/nokogiri) - HTML parsing and scraping library for Ruby.

## Project Status
Project is _in progress_.