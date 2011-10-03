Jade = require('jade')

window.p = ()->
  console.log.apply(this,arguments)

jQuery.fn.serializeObject = () ->
  objectData = {}
  $.each @serializeArray(), () ->
    value = if @value?
        @value
      else
        ''
    if objectData[@name]?
      objectData[@name] = [objectData[@name]] unless objectData[@name].push
      objectData[@name].push value
    else
      objectData[@name] = value
  objectData


Object::to_json = ->
  JSON.stringify(this)

Dispatcher =
  init:->
    $('body').delegate '.clientform','submit', ()->
      try
        parts = $(this).attr('action').split('#')
        p parts
        params =
          entity: $(this).serializeObject()
        params.controller = parts[0]
        params.action = parts[1] || 'index'
        Dispatcher.dispatch(params)
      catch e
        p e
      return false
    $('body').delegate '.clientlink','click', ()->
      params = $(this).attr('href').split('#')[1]
      params = JSON.parse(params)
      Dispatcher.dispatch(params)
   dispatch:(params)->
      controller = params.controller
      klazz = window["#{controller}Controller"]
      cnt = new klazz
      cnt.params = params
      cnt.action(params.action || 'index')

Renderer =
  templates:{}
  init:->
    $('template').each ->
      Renderer.templates[$(this).attr('name')] = Jade.compile($(this).html())
      this.parentNode.removeChild(this)
window.App =
  init:->
    Renderer.init()
    Dispatcher.init()

class window.Model
  constructor:(attrs)->
    @attrs = attrs
    this[attr] = val for attr,val of attrs

class window.Collection
  constructor:(attrs)->
    this[attr] = val for attr,val of attrs
  items:[]
  model:Model
  all:->
    @items
  find:(id)->
    res = _.select @items, (item)->
      item.id == id
    res[0]
  cid:3
  create:(attrs)->
    attrs.id = @cid++
    @items.push(new @model(attrs))

class window.Controller
  constructor:->
  controller_name:->
    @controller ||= @constructor.name.replace(/Controller$/,'')
  link_to:(label,opts)->
    opts['controller'] ||= @params['controller']
    opts['action'] ||= @params['action']
    "<a class='clientlink' href='##{opts.to_json()}'>#{label}</a>"
  redirect_to:(params)->
    params.controller ||= @params.controller
    params.action ||= @params.action
    @_redirect = true
    Dispatcher.dispatch(params)

  action:(action)->
    @params['action'] = action
    @params['controller'] = @controller_name()
    @[action]() if @[action]?
    $('body').html(Renderer.templates["#{@controller_name()}/#{action}"](this)) unless @_redirect
