document.addEventListener('DOMContentLoaded', function() {
    var temperatureElements = document.querySelectorAll('.temp');
    var speedElement = document.getElementById('speed');
    var changeButton = document.getElementById('changeButton');
    
    changeButton.addEventListener('click', function() {
        changeButton.innerText = (changeButton.innerText === 'imperial: °F, mph') 
            ? 'metric: °C, km/h' 
            : 'imperial: °F, mph';

        var speedString = speedElement.innerText;
        if (speedString.length > 0) {
            var currentSpeed = parseFloat(speedString);
            var currentUnit = speedString.slice(-3);
            currentUnit = (currentUnit === 'm/h') ? 'km/h' : currentUnit;
            var newUnit = currentUnit === 'km/h' ? 'mph' : 'km/h';
            var newSpeed = convertSpeed(currentSpeed, currentUnit, newUnit)
            speedElement.innerText = newSpeed.toFixed(2) + ' ' + newUnit;
        } else {
            console.error('Speed string is empty or undefined.');
        }

        temperatureElements.forEach(function(temperatureElement) {
            var temperatureString = temperatureElement.innerText.trim(); 

            if (temperatureString.length > 0) {
                var currentTemperature = parseFloat(temperatureString);
                var currentUnit = temperatureString.slice(-1); 
                var newUnit = currentUnit === 'C' ? 'F' : 'C';
                var newTemperature = Math.round(convertTemperature(currentTemperature, currentUnit, newUnit));
                temperatureElement.innerText = newTemperature + '°' + newUnit;
            } else {
                console.error('Temperature string is empty or undefined.');
            }
        });
    });

    // var imperialBtn = document.getElementById('imperial');
    // var metricBtn = document.getElementById('metric');

    // imperialBtn.addEventListener('click', changeUnits);
    // metricBtn.addEventListener('click', changeUnits);

    // function changeUnits(){
    //     // changeButton.innerText = (changeButton.innerText === 'imperial: °F, mph') 
    //     // ? 'metric: °C, km/h' 
    //     // : 'imperial: °F, mph';
    //     if(imperialBtn.cliked)

    //     var speedString = speedElement.innerText;
    //     if (speedString.length > 0) {
    //         var currentSpeed = parseFloat(speedString);
    //         var currentUnit = speedString.slice(-3);
    //         currentUnit = (currentUnit === 'm/h') ? 'km/h' : currentUnit;
    //         var newUnit = currentUnit === 'km/h' ? 'mph' : 'km/h';
    //         var newSpeed = convertSpeed(currentSpeed, currentUnit, newUnit)
    //         speedElement.innerText = newSpeed.toFixed(2) + ' ' + newUnit;
    //     } else {
    //         console.error('Speed string is empty or undefined.');
    //     }

    //     temperatureElements.forEach(function(temperatureElement) {
    //         var temperatureString = temperatureElement.innerText.trim(); 

    //         if (temperatureString.length > 0) {
    //             var currentTemperature = parseFloat(temperatureString);
    //             var currentUnit = temperatureString.slice(-1); 
    //             var newUnit = currentUnit === 'C' ? 'F' : 'C';
    //             var newTemperature = Math.round(convertTemperature(currentTemperature, currentUnit, newUnit));
    //             temperatureElement.innerText = newTemperature + '°' + newUnit;
    //         } else {
    //             console.error('Temperature string is empty or undefined.');
    //         }
    //     });
    // }


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
        const conversionFactor = 0.621371;
    
        if (fromUnit === 'km/h' && toUnit === 'mph') {
            return speed * conversionFactor;
        } else if (fromUnit === 'mph' && toUnit === 'km/h') {
            return speed / conversionFactor;
        } else {
            return speed;
        }
    }
});