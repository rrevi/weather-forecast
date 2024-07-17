require "net/http"
require "json"

class WeatherController < ApplicationController
  def index
    @errors = []
    if request.post?
      # get zipcode from params
      @zipcode = location_params[:zipcode]

      # basic validate zipcode (depiste the front-end already validating)
      if @zipcode.blank?
        @errors << "Zipcode cannot be blank."
        render :index, status: :unprocessable_entity
      else
        # OpenWeatherMap (owm)
        # get owm api key from credentials
        owm_api_key = openweathermap_api_key
        if not owm_api_key
          logger.error("WeatherController.index - openweathermap.api_key credentials key does not exists or is blank")
          @errors << "An error has occured. Contact your system administrator."
          render :index, status: :unprocessable_entity
        else
          # get lat and lon coordinates using zipcode from owm
          uri = URI("http://api.openweathermap.org/geo/1.0/zip?zip=#{@zipcode},US&appid=#{owm_api_key}")
          res = Net::HTTP.get_response(uri)
          if res.is_a?(Net::HTTPSuccess)
            zip_json = JSON.parse(res.body)
            lat, lon = zip_json["lat"], zip_json["lon"]
            redirect_to forecast_url + "?lat=#{lat}&lon=#{lon}"
          elsif res.is_a?(Net::HTTPNotFound)
            logger.error("WeatherController.index - failed to fetch lat and lon using zipcode, zipcode not found")
            @errors << "Zipcode not found. Please try again."
            render :index, status: :unprocessable_entity
          else
            logger.error("WeatherController.index - failed to fetch lat and lon using zipcode")
            @errors << "An error has occured. Contact your system administrator."
            render :index, status: :unprocessable_entity
          end
        end
      end
    end
  end

  def forecast
    @errors = []

    # get lat and lon from params
    lat = forecast_params[:lat]
    lon = forecast_params[:lon]

    # basic validate zipcode (depiste the front-end already validating)
    if lat.blank? or lon.blank?
      redirect_to root_path
    else
      # OpenWeatherMap (owm)
      # get owm api key from credentials
      owm_api_key = openweathermap_api_key
      if not owm_api_key
        logger.error("WeatherController.forecast - openweathermap.api_key credentials key does not exists or is blank")
        @errors << "An error has occured. Contact your system administrator."
      else
        # using lat and lon, get weather overview from owm
        uri = URI("https://api.openweathermap.org/data/2.5/weather?lat=#{lat}&lon=#{lon}&appid=#{owm_api_key}&units=imperial")

        cache_key = [ lat, lon ] # caching with lat and lon instead of zipcode, but it's essentially the same ;-)
        @cache_miss = false
        weather_res = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
          @cache_miss = true
          Net::HTTP.get_response(uri)
        end

        if weather_res.is_a?(Net::HTTPSuccess)
          @weather = JSON.parse(weather_res.body)
        elsif weather_res.is_a?(Net::HTTPNotFound)
          logger.error("WeatherController.forecast - failed to fetch current weather conditions, received 404 Not Found")
          @errors << "Current weather conditions not found. Please try again."
          render :forecast, status: :unprocessable_entity
        else
          logger.error("WeatherController.forecast - failed to fetch current weather conditions")
          @errors << "An error has occured. Contact your system administrator."
          render :forecast, status: :unprocessable_entity
        end
      end
    end
  end

  private
  def location_params
    params.require(:location).permit(:zipcode)
  end

  def forecast_params
    params.permit(:lat, :lon)
  end

  def openweathermap_api_key
    if not Rails.application.credentials.openweathermap or not Rails.application.credentials.openweathermap.api_key or Rails.application.credentials.openweathermap.api_key.blank?
      nil
    else
      Rails.application.credentials.openweathermap.api_key
    end
  end
end
