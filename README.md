# Sarajevo weather & air pollution
> Simple, static [web page](https://sa-aqi-weather.simplify.ba/) providing information about Air Quality Index (AQI) and weather conditions in Sarajevo, known for being the most polluted city in Europe.

## Overview

The Ruby script retrieves data from third-party APIs or resorts to web scraping when APIs are not available. It then generates an HTML file by integrating the collected data into an ERB (Embedded Ruby) template. To ensure that information is up-to-date, the script is scheduled to run automatically every hour using AWS Lambda.

## Features
- Current weather data.
- 5-day weather forecast provided in 3-hour intervals.
- Hourly AQI data available for 5 monitoring sites, detailing AQI for each pollutant.
- Hourly city-wide AQI data, with breakdowns for each pollutant.

## Prerequisites
Ensure that you have the following installed on your machine:

- Ruby: Download and install Ruby 3.2.
- Bundler: Install Bundler by running `gem install bundler`.
- API key from [OpenWeather](https://openweathermap.org/api).

## Setup
1. Clone the Repository:
```
git clone https://github.com/em-jov/sa_weather_aqi.git
cd sa_weather_aqi
```
2. Install Dependencies:
```
bundle install
```
3. Configure:

Copy the contents of the `.env.example` file to create a new file named `.env`. Modify the variables inside, ensuring that, for development purposes, you include the required OpenWeather API key. This project utilizes the [Current weather data](https://openweathermap.org/current) and [5-day weather forecast](https://openweathermap.org/forecast5) API endpoints.

4. Deployment

[Instructions](DEPLOYMENT.md)


## Customization
Modify the target URL, CSS selector, and scraping logic in the `aqi_guide module` according to your requirements.
Customize the HTML content in the `template.html.erb` file.

## Contributing
If you find issues or have improvements, feel free to open an issue or submit a pull request.

## License
[MIT License](MIT-LICENCE.txt)

## Project Status
Project is _in progress_.