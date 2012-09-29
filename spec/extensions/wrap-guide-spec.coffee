$ = require 'jquery'
RootView = require 'root-view'

describe "WrapGuide", ->
  [rootView, editor, wrapGuide] = []

  beforeEach ->
    rootView = new RootView(require.resolve('fixtures/sample.js'))
    requireExtension('wrap-guide')
    rootView.attachToDom()
    editor = rootView.getActiveEditor()
    wrapGuide = rootView.find('.wrap-guide').view()

  afterEach ->
    rootView.deactivate()

  describe "@initialize", ->
    it "appends a wrap guide to all existing and new editors", ->
      expect(rootView.panes.find('.pane').length).toBe 1
      expect(rootView.panes.find('.lines > .wrap-guide').length).toBe 1
      editor.splitRight()
      expect(rootView.find('.pane').length).toBe 2
      expect(rootView.panes.find('.lines > .wrap-guide').length).toBe 2

  describe "@updateGuide", ->
    it "positions the guide at the configured column", ->
      width = editor.charWidth * wrapGuide.getGuideColumn()
      expect(width).toBeGreaterThan(0)
      expect(wrapGuide.position().left).toBe(width)

  describe "font-size-change", ->
    it "updates the wrap guide position", ->
      initial = wrapGuide.position().left
      expect(initial).toBeGreaterThan(0)
      rootView.trigger('increase-font-size')
      expect(wrapGuide.position().left).toBeGreaterThan(initial)

  describe "overriding getGuideColumn", ->
    it "invokes the callback with the editor path", ->
      editorPath = null
      wrapGuide.getGuideColumn = (path) ->
        editorPath = path
        80
      wrapGuide.updateGuide(editor)
      expect(editorPath).toBe(require.resolve('fixtures/sample.js'))

    it "uses the function from the config data", ->
      rootView.find('.wrap-guide').remove()
      config =
        getGuideColumn: ->
          1
      requireExtension('wrap-guide', config)
      wrapGuide = rootView.find('.wrap-guide').view()
      expect(wrapGuide.getGuideColumn).toBe(config.getGuideColumn)

    it "hides the guide when the column is less than 1", ->
      wrapGuide.getGuideColumn = (path) ->
        -1
      wrapGuide.updateGuide(editor)
      expect(wrapGuide).toBeHidden()
