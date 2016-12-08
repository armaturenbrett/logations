class LogationsClient
  require 'action_view'
  require 'uri'
  require 'net/http'
  require 'json'
  require 'time'
  require 'awesome_print'

  def initialize
    @verbose = __FILE__ == $0
    @user_details = {}

    user_information_for_API_token

    $widget_scheduler.every '20s', first: :immediately do
      location_update
    end unless @verbose
    location_update if @verbose
  end

  def user_information_for_API_token
    recource = 'users/details'
    url = create_request_address(recource)

    api_request(url) do |responseJson|
      @user_details = { name: responseJson['name'] }
    end
  end

  def location_update
    recource = 'locations/recent'
    url = create_request_address(recource)

    api_request(url) do |response_json|
      response_json['title'] = "#{@user_details[:name]}'s last known position"
      response_json.except! 'id'

      ap(response_json) if @verbose
      WidgetDatum.new(name: 'logations', data: response_json).save unless @verbose
    end
  end

  def create_request_address(recource)
    url = $config['logations']['server-url']
    api_token = $config['logations']['api-token']

    address = "#{url}/#{recource}"
    suffix = "API_token=#{api_token}"
    URI.parse("#{address}?#{suffix}")
  end

  def api_request(url)
    ap url if @verbose
    uri = URI(url)
    response = Net::HTTP.get(uri)
    yield JSON.parse(response)
  rescue
    ap 'Logations API connection error!'
    return false
  end
end

logations = LogationsClient.new
