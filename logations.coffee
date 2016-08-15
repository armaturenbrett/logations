App.widget_data = App.cable.subscriptions.create channel: 'WidgetDataChannel', widget: 'logations',

  connected: ->
    console.log('logations connected')

  disconnected: ->
    console.log('logations disconnected')
    window.logationsWidget.resetTemplate()

  received: (data) ->
    console.log('logations received data:', data)
    window.logationsWidget.renderData(data)



class LogationsWidget
  _this = undefined

  constructor: ->
    _this = this

    this.$widget = $('.widget .logations')
    $template = $('.widget .logations .marker-description-template')
    this.markerTemplate = $template[0].innerHTML
    $template.remove()

    this.initMap()
    this.resetTemplate()
    this.renderData(this.$widget.data('preload'))

  initMap: ->
    this.leafletMap = L.map('logations-map-widget')
    L.tileLayer(
      'https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}',
      {
        maxZoom: 19,
        id: this.$widget.data('mapbox-project-id'),
        accessToken: this.$widget.data('mapbox-api-token')
      }
    ).addTo(this.leafletMap)
    this.leafletMap.attributionControl.setPrefix('')

    this.$widget.data('mapbox-api-token', '')
    this.$widget.data('mapbox-project-id', '')
    this.marker = undefined

  resetTemplate: ->
    this.leafletMap.setView([52.520007, 13.404954], 9)
    this.updateAttribution('(offline)')

  renderData: (data) ->
    this.render(this.markerTemplate, data)

  render: (template, data) ->
    renderedTemplate = Mustache.render(template, data)
    latitude = data.latitude
    longitude = data.longitude

    this.leafletMap.setView([latitude, longitude], 15)
    this.updateAttribution("last update: #{data.created_at}")

    this.leafletMap.removeLayer(this.marker) if this.marker
    this.marker = L.marker([latitude, longitude]).addTo(this.leafletMap)
    this.marker.bindPopup(renderedTemplate)

  updateAttribution: (label) ->
    this.leafletMap.attributionControl.removeAttribution(this.currentLabel)
    this.leafletMap.attributionControl.addAttribution(label)
    this.currentLabel = label

$(document).ready ->
  window.logationsWidget = new LogationsWidget()
