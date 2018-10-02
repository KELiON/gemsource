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
 getGems: (callback, bundleCommand = "bundle")->
   return callback(cache) if cache
   exec "cd #{@projectPath} && #{bundleCommand} show", (err, stdout, stderr)=>
     return @getGems(callback, "bin/bundle") if err and bundleCommand != "bin/bundle"
     cache = stdout.split("\n").map (gem)->
       gem.replace(/^[^\w\d]+/g, '')
     callback(cache)
 viewForItem: (item) ->
   "<li>#{item}</li>"
 confirmed: (item, bundleCommand = "bundle") ->
   item = item.replace(/\s\(.*?\)$/, '')
   exec "cd #{@projectPath} && #{bundleCommand} show #{item}", (err, stdout, stderr)=>
     return @confirmed(item, "bin/bundle") if err and bundleCommand != "bin/bundle"
     atom.open(pathsToOpen: [stdout]);
   @hide()

 cancelled: ->
  @hide()
