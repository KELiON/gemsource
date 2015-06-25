SearchGemView = require './search_gem_view'

module.exports =
  activate: ->
    atom.commands.add 'atom-workspace', "gemsource:open", => @showSelector()

  showSelector: ->
    @palette = new SearchGemView
    @palette.show()
