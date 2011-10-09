class window.Note extends Model

window.Notes = new Collection
  model: Note
  url:'notes.json',

class window.NotesController extends Controller
  index:->
    @notes = Notes.all()
    if @params.sort
      @notes = @notes.pipe (notes)=>
        p notes
        _(notes).sortBy (note)=>
          note[@params.sort]
  show:->
    @note = Notes.find(@params.id)
  update:->
    @note = Notes.find(@params.id)
    @note.update_attributes(@params.entity)
    @redirect_to action:'show', id:@note.id
  edit:->
    @note = Notes.find(@params.id)
  create:->
    @note = Notes.create(@params.entity)
    @redirect_to action:'index'

App.init
  routes:
    default: {controller:'Notes',action:'index'}
