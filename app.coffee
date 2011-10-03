class window.Note extends Model

window.Notes = new Collection
  model: Note
  items: [
    new Note(id:0,title:'note 1',content:"bla,bla,bla\nbla")
    new Note(id:1,title:'Jada Jada',content:"bla,bla,bla\nbla")
    new Note(id:2,title:'My first note',content:"bla,bla,bla\nbla")
  ]

class window.NotesController extends Controller
  index:->
    @notes = Notes.all()
    if @params.sort
      @notes = _(@notes).sortBy (note)=>
        note[@params.sort]
  show:->
    @note = Notes.find(@params.id)
  create:->
    @note = Notes.create(@params.entity)
    @redirect_to action:'index'

App.init()
cnt = new NotesController()
cnt.params= {filter:'myfilter'}
cnt.action('index')
