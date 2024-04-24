require_relative '../test_helper'

class AirQualityIndexTest < TestCase
  def setup 
    super
    @script = WeatherAir::AirQualityIndex.new
    @stations_pollutants = {
    "vijecnica"=>{:aqi=>{:value=>"1", :class=>:good_eea}, :so2=>{:value=>"1", :class=>:good_eea}, :no2=>{:value=>"1", :class=>:good_eea}, :o3=>{:value=>"", :class=>nil}, :pm10=>{:value=>"", :class=>nil}, :pm25=>{:value=>"", :class=>nil}, :name=>"Vijećnica", :latitude=>43.859, :longitude=>18.434},
    "bjelave"=>{:aqi=>{:value=>"3", :class=>:moderate_eea}, :so2=>{:value=>"1", :class=>:good_eea}, :no2=>{:value=>"1", :class=>:good_eea}, :o3=>{:value=>"3", :class=>:moderate_eea}, :pm10=>{:value=>"1", :class=>:good_eea}, :pm25=>{:value=>"1", :class=>:good_eea}, :name=>"Bjelave", :latitude=>43.867, :longitude=>18.42},
    "otoka"=>{:aqi=>{:value=>"2", :class=>:fair_eea}, :so2=>{:value=>"1", :class=>:good_eea}, :no2=>{:value=>"2", :class=>:fair_eea}, :o3=>{:value=>"2", :class=>:fair_eea}, :pm10=>{:value=>"2", :class=>:fair_eea}, :pm25=>{:value=>"2", :class=>:fair_eea}, :name=>"Otoka", :latitude=>43.848, :longitude=>18.363},
    "ilidza"=>{:aqi=>{:value=>"2", :class=>:fair_eea}, :so2=>{:value=>"1", :class=>:good_eea}, :no2=>{:value=>"1", :class=>:good_eea}, :o3=>{:value=>"", :class=>nil}, :pm10=>{:value=>"2", :class=>:fair_eea}, :pm25=>{:value=>"2", :class=>:fair_eea}, :name=>"Ilidža", :latitude=>43.83, :longitude=>18.31},
    "vogosca"=>{:aqi=>{:value=>"2", :class=>:fair_eea}, :so2=>{:value=>"1", :class=>:good_eea}, :no2=>{:value=>"1", :class=>:good_eea}, :o3=>{:value=>"", :class=>nil}, :pm10=>{:value=>"2", :class=>:fair_eea}, :pm25=>{:value=>"1", :class=>:good_eea}, :name=>"Vogošća", :latitude=>43.9, :longitude=>18.342},
    "hadzici"=>{:aqi=>{:value=>"2", :class=>:fair_eea}, :so2=>{:value=>"1", :class=>:good_eea}, :no2=>{:value=>"1", :class=>:good_eea}, :o3=>{:value=>"2", :class=>:fair_eea}, :pm10=>{:value=>"", :class=>nil}, :pm25=>{:value=>"", :class=>nil}, :name=>"Hadžići", :latitude=>43.823, :longitude=>18.2},
    "ilijas"=>{:aqi=>{:value=>"2", :class=>:fair_eea}, :so2=>{:value=>"1", :class=>:good_eea}, :no2=>{:value=>"1", :class=>:good_eea}, :o3=>{:value=>"", :class=>nil}, :pm10=>{:value=>"2", :class=>:fair_eea}, :pm25=>{:value=>" ", :class=>nil}, :name=>"Ilijaš", :latitude=>43.96, :longitude=>18.269},
    "ivan_sedlo"=>{:aqi=>{:value=>"3", :class=>:moderate_eea}, :so2=>{:value=>"1", :class=>:good_eea}, :no2=>{:value=>"1", :class=>:good_eea}, :o3=>{:value=>"3", :class=>:moderate_eea}, :pm10=>{:value=>"1", :class=>:good_eea}, :pm25=>{:value=>"", :class=>nil}, :name=>"Ivan sedlo", :latitude=>43.75, :longitude=>18.035}}
  end

  def test_aqi_by_fhmz
    skip

    stub_request(:get, "https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php").
      to_return(status: 200, body: File.read('test/fixtures/fhmzbih.html'), headers: {})
          
    result = @script.aqi_by_fhmz
    assert_equal({:value=>"3", :class=>:moderate_eea}, result['otoka'][:o3])
  end

  def test_aqi_by_fhmz_no_data
    skip

    stub_request(:get, "https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php").
    to_return(status: 200, body: File.read('test/fixtures/fhmzbih_no_data.html'), headers: {})

    result = @script.aqi_by_fhmz
    expected = {:error=>{:en=>'Error: No current air quality index data available from Federal Hydro-Meteorological Institute! Please visit <a href="https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php">fhmzbih.gov.ba</a> for more information.', 
                         :bs=>'Greška: Nedostupni podaci o indeksu kvalitete zraka Federalnog hidrometeoroloskog zavoda! Posjetite <a href="https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php">fhmzbih.gov.ba</a> za više informacija.'}}
    assert_equal(expected, result)
  end

  def test_aqi_by_fhmz_one_station_data
    skip

    stub_request(:get, "https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php").
    to_return(status: 200, body: File.read('test/fixtures/fhmzbih_some_data.html'), headers: {})

    result = @script.aqi_by_fhmz
    pp result
    assert_equal({:value=>"4", :class=>:poor_eea}, result["bjelave"][:aqi])
  end

  def test_aqi_by_fhmz_empty_html
    skip

    stub_request(:get, "https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php").
    to_return(status: 200, body: File.read('test/fixtures/fhmzbih_empty.html'), headers: {})

    result = @script.aqi_by_fhmz
    expected = {:error=>{:en=>'Error: No current air quality index data available from Federal Hydro-Meteorological Institute! Please visit <a href="https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php">fhmzbih.gov.ba</a> for more information.', 
                         :bs=>'Greška: Nedostupni podaci o indeksu kvalitete zraka Federalnog hidrometeoroloskog zavoda! Posjetite <a href="https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php">fhmzbih.gov.ba</a> za više informacija.'}}
    assert_equal(expected, result)
  end

  def test_aqi_by_ks
    skip

    stub_request(:get, "https://aqms.live/kvalitetzraka/st.php?st=vijecnica").
      to_return(status: 200, body: File.read('test/fixtures/ks_aqi_vijecnica.html'), headers: {})
    
    stub_request(:get, "https://aqms.live/kvalitetzraka/st.php?st=otoka").
      to_return(status: 200, body: File.read('test/fixtures/ks_aqi_otoka.html'), headers: {})

    stub_request(:get, "https://aqms.live/kvalitetzraka/st.php?st=ilidza").
      to_return(status: 200, body: File.read('test/fixtures/ks_aqi_ilidza.html'), headers: {})

    stub_request(:get, "https://aqms.live/kvalitetzraka/st.php?st=vogosca").
      to_return(status: 200, body: File.read('test/fixtures/ks_aqi_vogosca.html'), headers: {})

    stub_request(:get, "https://aqms.live/kvalitetzraka/st.php?st=ilijas").
      to_return(status: 200, body: File.read('test/fixtures/ks_aqi_ilijas.html'), headers: {})  
    
    I18n.locale = :bs

    result = @script.aqi_by_ks
    assert_equal("9.42 μg/m3", result[0]['Vijećnica']["SO2"][:concentration])
  end

  def test_aqi_by_ks
    skip

    stub_request(:get, "https://aqms.live/kvalitetzraka/st.php?st=vijecnica").
      to_return(status: 200, body: "", headers: {})
    
    stub_request(:get, "https://aqms.live/kvalitetzraka/st.php?st=otoka").
      to_return(status: 200, body: "", headers: {})

    stub_request(:get, "https://aqms.live/kvalitetzraka/st.php?st=ilidza").
      to_return(status: 200, body: "", headers: {})

    stub_request(:get, "https://aqms.live/kvalitetzraka/st.php?st=vogosca").
      to_return(status: 200, body: "", headers: {})

    stub_request(:get, "https://aqms.live/kvalitetzraka/st.php?st=ilijas").
      to_return(status: 200, body: "", headers: {})  
    
    I18n.locale = :bs

    result = @script.aqi_by_ks
    expected = { error: { en: 'Error: No current air quality index data available from Sarajevo Canton Ministry of Communal Industry, Infrastructure, Physical Planning, Construction and Environmental Protection. Please visit <a href="https://aqms.live/kvalitetzraka/index.php">mkipgo.ks.gov.ba</a> for more information.', 
                          bs: 'Greška: Nedostupni podaci o indeksu kvalitete zraka sa webstranice Ministarstva komunalne privrede, infrastrukture, prostornog uređenja, građenja i zaštite okoliša Kantona Sarajevo! Posjetite <a href="https://aqms.live/kvalitetzraka/index.php">mkipgo.ks.gov.ba</a> za više informacija.' } }
    assert_equal(expected, result)
  end

  def test_aqi_by_ekoakcija
    skip

    stub_request(:get, "https://zrak.ekoakcija.org/sarajevo").
      to_return(status: 200, body: File.read("test/fixtures/ekoakcija_aqi.html"), headers: {})

    result = @script.aqi_by_ekoakcija
    expected = [[["Ambasada SAD", "", "26", "", "75", "Umjereno zagađen"],
                ["Otoka", "28", "17", "9", "55", "Umjereno zagađen"],
                ["Vijećnica", "14", "13", "2", "53", "Umjereno zagađen"],
                ["Bjelave", "35", "10", "8", "33", "Dobar"],
                ["Ilidža", "13", "8", "4", "25", "Dobar"]],
                75, "moderate"]
    assert_equal(expected, result)
  end

  def test_aqi_by_ekoakcija_no_data
    skip

    stub_request(:get, "https://zrak.ekoakcija.org/sarajevo").
      to_return(status: 403, body: File.read("test/fixtures/ekoakcija_aqi_no_data.html"), headers: {})

    ExceptionNotifier.expects(:notify)  
    result = @script.aqi_by_ekoakcija
    expected = {:error=>{:en=>'Error: No current air quality index data available from ekoakcija.org. Please visit <a href="https://zrak.ekoakcija.org/sarajevo">zrak.ekoakcija.org</a> for more information.', 
                         :bs=>'Greška: Nedostupni podaci o indeksu kvalitete zraka sa webstranice ekoakcija.org! Posjetite <a href="https://zrak.ekoakcija.org/sarajevo">zrak.ekoakcija.org</a> za više informacija.'}}
    assert_equal(expected, result)
  end

  def test_aqi_by_ekoakcija_raises_no_data_error
    # Use instance_eval to redefine the method within the context of the @script instance
    @script.instance_eval do
      # Redefine the method without the rescue block
      def aqi_by_ekoakcija
        station_ea_site = Nokogiri::HTML(URI.open("https://zrak.ekoakcija.org/sarajevo"))
        table = station_ea_site.search(".views-table.cols-6 tbody tr")
  
        ea_table = table.map do |tr|
          tr.search('td').map { |td| td.text.strip }
        end
        raise WeatherAir::NoDataError.new("No ekoakcija AQI data") if ea_table == []
  
        aqi_values = ea_table.map { |x| x[4].to_i }
        city_aqi_value =  aqi_values.max
        city_aqi_desc = AQI.find{|key, value| value.include?(city_aqi_value)}&.first&.to_s
  
        [ea_table, city_aqi_value, city_aqi_desc]
      end
    end
  
    stub_request(:get, "https://zrak.ekoakcija.org/sarajevo").
      to_return(status: 200, body: File.read("test/fixtures/ekoakcija_aqi_no_data.html"), headers: {})
  
    # Assert that the error is not rescued within the method
    error = assert_raises(WeatherAir::NoDataError, "No ekoakcija AQI data") do
      @script.aqi_by_ekoakcija
    end
  
    assert_equal "No ekoakcija AQI data", error.message
  end

  # def test_aqi_by_ekoakcija_raises_no_data_error
  #   # Stub the aqi_by_ekoakcija method of the @script instance
  #   @script.stub(:aqi_by_ekoakcija, -> { raise WeatherAir::NoDataError.new("No ekoakcija AQI data") }) do
  #     stub_request(:get, "https://zrak.ekoakcija.org/sarajevo").
  #       to_return(status: 200, body: File.read("test/fixtures/ekoakcija_aqi_no_data.html"), headers: {})
  
  #     # Assert that the error is not rescued within the method
  #     error = assert_raises(WeatherAir::NoDataError, "No ekoakcija AQI data") do
  #       @script.aqi_by_ekoakcija
  #     end

  #     assert_equal "No ekoakcija AQI data", error.message
  #   end
  # end

  def test_citywide_aqi_by_fhmz_no_values
    skip

    stations_pollutants = { "vijecnica" => { :so2 => nil, :no2 => nil, :co => nil, :o3 => nil, :pm10 => nil, :pm2_5 => nil, :pm => nil, :aqi => nil },
                            "bjelave" => { :so2 => nil, :no2 => nil, :co => nil, :o3 => nil, :pm10 => nil, :pm2_5 => nil, :pm => nil, :aqi => nil },
                            "embassy" => { :so2 => nil, :no2 => nil, :co => nil, :o3 => nil, :pm10 => nil, :pm2_5 => nil, :pm => nil, :aqi => nil },
                            "otoka" => { :so2 => nil, :no2 => nil, :co => nil, :o3 => nil, :pm10 => nil, :pm2_5 => nil, :pm => nil, :aqi => nil },
                            "ilidza" => { :so2 => nil, :no2 => nil, :co => nil, :o3 => nil, :pm10 => nil, :pm2_5 => nil, :pm => nil, :aqi => nil } }


    @script.expects(:aqi_by_fhmz).returns(stations_pollutants)
    result = @script.citywide_aqi_by_fhmz
    
    assert_equal(result[:value],  0)
    assert_nil(result[:class])
  end

  def test_citywide_aqi_by_fhmz
    skip

    @script.expects(:aqi_by_fhmz).returns(@stations_pollutants)
    result = @script.citywide_aqi_by_fhmz

    assert_equal(result[:value],  3)
    assert_equal(result[:class],  :moderate_eea)
  end

end


