_ = require "underscore"
HasProps = require "../core/has_props"
{logger} = require "../core/logging"
Selector = require "./selector"
hittest = require "./hittest"
p = require "../core/properties"

class SelectionManager extends HasProps
  type: 'SelectionManager'

  @internal {
    source: [ p.Any ]
  }

  initialize: (attrs, options) ->
    super(attrs, options)
    @selector = new Selector()
    @inspector = new Selector()

  select: (tool, renderer_view, geometry, final, append=false) ->
    if @source != renderer_view.mget('data_source')
      logger.warn('select called with mis-matched data sources')

    indices = renderer_view.hit_test(geometry)

    if indices?
      @selector.update(indices, final, append)
      @source.set({ "selected": @selector.get('indices') }, {"silent": true })

      @source.trigger('select')
      @source.trigger('select-' + renderer_view.mget('id'))

      return not indices.is_empty()
    else
      return false

  inspect: (tool, renderer_view, geometry, data) ->
    if @source != renderer_view.mget('data_source')
      logger.warn('inspect called with mis-matched data sources')

    indices = renderer_view.hit_test(geometry)

    if indices?
      @inspector.update(indices, true, false, true)
      @source.set({ "inspected": @inspector.get('indices')}, {"silent": true })

      @source.trigger(
        'inspect', indices, tool, renderer_view, @source, data
      )
      @source.trigger(
        "inspect#{renderer_view.model.id}", indices, tool, renderer_view,
        @source, data
      )
      return not indices.is_empty()
    else
      return false

  clear: () ->
    @selector.clear()
    @source.set({ "selected": @selector.indices})

module.exports = SelectionManager
