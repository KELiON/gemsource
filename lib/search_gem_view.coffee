{SelectListView} = require 'atom-space-pen-views'
fs = require('fs')
exec = require('child_process').exec

cache = null

module.exports =
class SearchGemView extends SelectListView
 initialize: ->
   super
   # [todo] several directories?
   @projectPath = atom.project.getDirectories()[0].path
   @gemfile = "#{@projectPath}/Gemfile.lock"
   @getGemsCommand = "cd #{@projectPath} && bundle show | cut -d \" \" -f 4 | sed 1d"
   @setMaxItems(20)
 show: ->
   @addClass('overlay from-top')
   @listGems()
   @panel ?= atom.workspace.addModalPanel(item: this)
   @panel.show()
   @focusFilterEditor()
 hide: ->
   @panel.hide()
 setList: (list)->
   @_list ||= list.split("\n")
   @setItems(@_list)
 getList: (list)->
   @_list ||= list.split("\n")
 listGems: ->
   if fs.existsSync(@gemfile)
     @getGems (list)=>
       @setItems(list)
   else
    # [todo] show error dialog
 getGems: (callback)->
   return callback(cache) if cache
   exec @getGemsCommand, (err, stdout, stderr)=>
     cache = stdout.split("\n")
     callback(cache)
 viewForItem: (item) ->
   "<li>#{item}</li>"
 confirmed: (item) ->
   exec "cd #{@projectPath} && bundle show #{item}", (err, stdout, stderr)=>
     atom.open(pathsToOpen: [stdout]);
   @hide()

 cancelled: ->
  @hide()
