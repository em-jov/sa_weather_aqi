# Sarajevo weather & air pollution
> Simple, static website providing information about Air Quality Index (AQI) and weather conditions in Sarajevo. https://sarajevo-meteo.com/

### Overview

Ruby script retrieves data from third-party APIs or resorts to web scraping when APIs are not available. It then generates an HTML file by integrating the collected data into an ERB (Embedded Ruby) template. To ensure that information is up-to-date, the script is scheduled to run automatically every hour using AWS Lambda.

### Features
- Meteoalarms
- Current weather data
- Hourly AQI data available for 5 monitoring sites
- Hourly city-wide AQI data
- Health recommendations
- 5-day weather forecast provided in 3-hour intervals

### Prerequisites

- Ensure that you have the following installed on your machine:
    - Ruby: Download and install Ruby 3.2.
    - Bundler: Install Bundler by running `gem install bundler`
- API key from [OpenWeather](https://openweathermap.org/api) 

### Setup
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
    - Create a new file named `.env` and paste the content from the `.env.example` file into it
    - Update the `API_KEY` variable with the obtained `OpenWeather API key`
    - During the deployment process, you will acquire the values for the remaining environment variables

### Deployment

![image info](./images/deployment.png)
The details of this process are outlined in a separate [file](DEPLOYMENT.md).

### Contributing
Your contributions are welcome and appreciated. If you find issues or have improvements, feel free to open an issue or submit a pull request.

### License
[MIT License](MIT-LICENCE.txt)

### Project Status
Project is _in progress_.