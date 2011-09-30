Jade = require('jade')

p = ()->
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

get_class = (name)=>
  NotesController

Object::to_json = ->
  JSON.stringify(this)

class Note
  constructor:(attrs)->
    @attrs = attrs
    this[attr] = val for attr,val of attrs

Notes =
  notes: [
    new Note(id:0,title:'note 1',content:"bla,bla,bla\nbla")
    new Note(id:1,title:'Jada Jada',content:"bla,bla,bla\nbla")
    new Note(id:2,title:'My first note',content:"bla,bla,bla\nbla")
  ]
  all:->
    @notes
  find:(id)->
    res = _.select @notes, (item)->
      item.id == id
    res[0]
  cid:3
  create:(attrs)->
    attrs.id = @cid++
    @notes.push(new Note(attrs))

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

class Controller
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

window.NotesController = class NotesController extends Controller
  index:->
    @notes = Notes.all()
    if @params.sort
      @notes = _(@notes).sortBy (note)=>
        note[@params.sort]
  show:->
    @note = Notes.find(@params.id)
    p @note
  create:->
    @note = Notes.create(@params.entity)
    @redirect_to action:'index'

Renderer.init()
Dispatcher.init()

cnt = new NotesController()
cnt.params= {filter:'myfilter'}
cnt.action('index')
