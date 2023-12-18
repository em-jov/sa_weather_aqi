require_relative '../test_helper'

class WeatherAirTest < Minitest::Test
  def setup 
    @script = WeatherAir.new
  end

  def test_fetch_hfmzbih_data
    stub_request(:get, "https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php").
      to_return(status: 200, body: File.read('test/fixtures/fhmzbih.html'), headers: {})
          
    data = @script.fetch_fhmzbih_data
    assert_equal(data.keys, ["embassy", "bjelave", "vijecnica", "otoka", "ilidza"])
    assert_equal(data['embassy'].class, Nokogiri::XML::Element)
  end
end

# stub_request(:get, "https://aqicn.org/city/bosnia-herzegovina/sarajevo/us-embassy/").
#   to_return(status: 200, body: File.read('test/fixtures/aqicn.html'), headers: {})
