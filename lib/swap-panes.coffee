module.exports =
  activate: (state) ->
    atom.commands.add 'atom-workspace', 'swap-panes:swap-right', => @swapRight()
    atom.commands.add 'atom-workspace', 'swap-panes:swap-left', => @swapLeft()
    atom.commands.add 'atom-workspace', 'swap-panes:swap-down', => @swapDown()
    atom.commands.add 'atom-workspace', 'swap-panes:swap-up', => @swapUp()
    atom.commands.add 'atom-workspace', 'swap-panes:swap-next', => @swapNext()
    atom.commands.add 'atom-workspace', 'swap-panes:swap-previous', => @swapPrevious()

  swapRight: -> @swap 'horizontal', +1
  swapLeft: -> @swap 'horizontal', -1
  swapUp: -> @swap 'vertical', -1
  swapDown: -> @swap 'vertical', +1
  swapNext: -> @swapOrder @nextMethod
  swapPrevious: -> @swapOrder @previousMethod

  nextMethod: 'activateNextPane'
  previousMethod: 'activatePreviousPane'

  active: -> atom.workspace.getActivePane()

  swapOrder: (method) ->
    source = @active()
    atom.workspace[method]()
    target = @active()
    @swapPane source, target

  swap: (orientation, delta) ->
    pane = atom.workspace.getActivePane()
    [axis,child] = @getAxis pane, orientation
    if axis?
      target = @getRelativePane axis, child, delta
    if target?
      @swapPane pane, target

  swapPane: (source, target) ->
    active = source.getActiveItem()
    [srcItems, tgtItems] = @removeItems [source, target]
    @addItems [source, target], [tgtItems, srcItems]
    target.activateItem active
    target.activate()

  removeItems: (panes) ->
    for pane in panes
      items = pane.getItems()
      pane.removeItem i for i in items
      items

  addItems: (panes, items) ->
    for i in [0...panes.length]
      panes[i].addItems items[i]

  getAxis: (pane, orientation) ->
    axis = pane.parent
    child = pane
    while true
      return unless axis.constructor.name == 'PaneAxis'
      break if axis.orientation == orientation
      child = axis
      axis = axis.parent
    return [axis,child]

  getRelativePane: (axis, source, delta) ->
    position = axis.children.indexOf source
    target = position + delta
    return unless target < axis.children.length
    return axis.children[target].getPanes()[0]

  deactivate: ->

  serialize: ->
