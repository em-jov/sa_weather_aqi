document.addEventListener('DOMContentLoaded', function() {
    var temperatureElements = document.querySelectorAll('.temp');
    var speedElement = document.getElementById('speed');

    var imperialBtn = document.getElementById('imperial');
    var metricBtn = document.getElementById('metric');

    imperialBtn.addEventListener('click', changeToImperial);
    metricBtn.addEventListener('click', changeToMetric);

    function changeToImperial(){
      var speedString = speedElement.innerText;
      var currentUnit = speedString.slice(-3)
      if (currentUnit === 'mph'){
        return;
      }

      imperialBtn.classList.remove("unit_off")
      metricBtn.classList.remove("unit_on")
      imperialBtn.classList.add("unit_on")
      metricBtn.classList.add("unit_off")

      if (speedString.length > 0) {
        var currentSpeed = parseFloat(speedString);
        var newSpeed = convertSpeed(currentSpeed, 'm/s', 'mph')
        speedElement.innerText = newSpeed.toFixed(2) + ' mph';
      } else {
        console.error('Speed string is empty or undefined.');
      }

      temperatureElements.forEach(function(temperatureElement) {
        var temperatureString = temperatureElement.innerText.trim(); 

        if (temperatureString.length > 0) {
          var currentTemperature = parseFloat(temperatureString);
          var newTemperature = Math.round(convertTemperature(currentTemperature, 'C', 'F'));
          temperatureElement.innerText = newTemperature + '°F';
        } else {
          console.error('Temperature string is empty or undefined.');
        }
      });
    };

    function changeToMetric(){
      var speedString = speedElement.innerText;
      var currentUnit = speedString.slice(-3)
      if (currentUnit === 'm/s'){
        return;
      }

      metricBtn.classList.remove("unit_off")
      imperialBtn.classList.remove("unit_on")
      metricBtn.classList.add("unit_on")
      imperialBtn.classList.add("unit_off")

      if (speedString.length > 0) {
          var currentSpeed = parseFloat(speedString);
          var newSpeed = convertSpeed(currentSpeed, 'mph', 'm/s')
          speedElement.innerText = newSpeed.toFixed(2) + ' m/s';
      } else {
          console.error('Speed string is empty or undefined.');
      }

      temperatureElements.forEach(function(temperatureElement) {
        var temperatureString = temperatureElement.innerText.trim(); 

        if (temperatureString.length > 0) {
            var currentTemperature = parseFloat(temperatureString);
            var newTemperature = Math.round(convertTemperature(currentTemperature,'F', 'C'));
            temperatureElement.innerText = newTemperature + '°C';
        } else {
            console.error('Temperature string is empty or undefined.');
        }
      });
    };

    function convertTemperature(temperature, fromUnit, toUnit) {
        if (fromUnit === 'C' && toUnit === 'F') {
            return (temperature * 9/5) + 32;
        } else if (fromUnit === 'F' && toUnit === 'C') {
            return (temperature - 32) * 5/9;
        } else {
            return temperature;
        }
    }

    function convertSpeed(speed, fromUnit, toUnit) {
        const conversionFactor = 2.23694;
    
        if (fromUnit === 'm/s' && toUnit === 'mph') {
            return speed * conversionFactor;
        } else if (fromUnit === 'mph' && toUnit === 'm/s') {
            return speed / conversionFactor;
        } else {
            return speed;
        }
    }
});