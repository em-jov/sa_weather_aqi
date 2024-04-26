document.addEventListener("DOMContentLoaded", function () {
  if (window.matchMedia) {
    if(window.matchMedia('(prefers-color-scheme: dark)').matches){
      // Dark
      var images = document.getElementsByClassName("mountain_icon")
      Array.from(images).forEach(element => {
        element.src = "<%= icon_path('mountains_black_bg') %>"
      }); 
    } else {
      // Light
      var images = document.getElementsByClassName("mountain_icon")
      Array.from(images).forEach(element => {
        element.src = "<%= icon_path('mountains_light_bg') %>"
      }); 
    }
  } 

  // Initialize Leaflet map
  var map = L.map('map').setView([43.8560, 18.390], 12);

  // Add OpenStreetMap as the base layer
  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
  }).addTo(map);

  <% fhmz_aqi.each do |_station, values| %>
    <% next if values[:aqi][:value].nil? %>
    
    // Define a custom HTML for the marker
    var customMarkerHtml = '<div class="custom-marker <%= values[:aqi][:class] %>"><%= values[:aqi][:value] %></div>';

    // Create a custom divIcon with the HTML
    var customIcon = L.divIcon({
        className: 'custom-div-icon',
        html: customMarkerHtml,
        iconSize: [30, 30]
    });

    // Add a marker with the custom icon
    L.marker([<%= values[:latitude] %>, <%= values[:longitude] %>], { icon: customIcon }).addTo(map).bindPopup('<%= values[:name] %>');
    
  <% end %>  
 
  var btn = document.getElementById("button");

  window.onscroll = function () {
    if (document.body.scrollTop > 300 || document.documentElement.scrollTop > 300 || window.scrollY > 300) {
        btn.classList.add("show");
    } else {
        btn.classList.remove("show");
    }
  };

  btn.addEventListener("click", function (e) {
    e.preventDefault();
    document.body.scrollTop = 0; // For Safari
    document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE, and Opera
    window.scrollY = 0;
  });

  var toggleButton = document.getElementById('see_more_stations');
  var hiddenRows = document.querySelectorAll('.hiddenRow');

  toggleButton.addEventListener('click', function() {
    hiddenRows.forEach(function(row) {
      if(row.style.display === 'none'){
        row.style.display = 'table-row';
        toggleButton.textContent = toggleButton.dataset.text_less;
      }
      else{
        row.style.display = 'none';
        toggleButton.textContent = toggleButton.dataset.text_more;
      }
    });
  });


  var temperatureElements = document.querySelectorAll('.temp');
  var speedElement = document.getElementById('speed');

  var imperialBtn = document.getElementById('imperial');
  var metricBtn = document.getElementById('metric');

  if (imperialBtn) {
    imperialBtn.addEventListener('click', changeToImperial);
    metricBtn.addEventListener('click', changeToMetric);
  }

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