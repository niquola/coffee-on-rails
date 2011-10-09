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
  init:(config)->
    @config = config
    $('body').delegate '.clientform','submit', ()->
      try
        parts = $(this).attr('action').split('#')
        params = $(this).attr('params')
        if params?
          params = JSON.parse(params)
        else
          params = {}
        params.entity     = $(this).serializeObject()
        params.controller = parts[0]
        params.action     = parts[1] || 'index'
        Dispatcher.dispatch(params)
      catch e
        p e
      false
    window.addEventListener "hashchange", @handle_hash.bind(this), false
    @handle_hash(Dispatcher)
  handle_hash:->
    try
      params = window.location.hash.split('#')[1]
      if params?
        params = JSON.parse(params)
      else
        params = @config.routes.default
      Dispatcher.dispatch(params)
    catch e
      p e
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
  init:(config)->
    Renderer.init()
    Dispatcher.init(config)

class window.Model
  constructor:(attrs)->
    @attrs = attrs
    @update_attributes(attrs)
  update_attributes:(attrs)->
    this[attr] = val for attr,val of attrs

class window.Collection
  constructor:(attrs)->
    this[attr] = val for attr,val of attrs
  items:null
  model:Model
  all:->
    if @items?
      deferred = $.Deferred()
      deferred.resolve(@items)
    else
      $.getJSON(@url).pipe (data)=>
        @items = _(data).map (item)=>
          new @model(item)

  find:(id)->
    res = _.select @items, (item)->
      p item
      item.id == id
    res[0]
  cid:3
  create:(attrs)->
    attrs.id = @cid++
    @items.push(new @model(attrs))

class window.Controller
  constructor:->
  params:{}
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
    @params.action = action
    @params.controller = @controller_name()
    @[action]() if @[action]?
    proto =  @.constructor.prototype
    vars = []
    self = this
    for key,val of @
      if ! proto[key]? &&  val && val.pipe
        k = key
        vars.push val.pipe (data)->
          p k,data
          self[k] = data
    $.when(vars...).done =>
      p self.notes
      $('body').html(Renderer.templates["#{@controller_name()}/#{action}"](this)) unless @_redirect
