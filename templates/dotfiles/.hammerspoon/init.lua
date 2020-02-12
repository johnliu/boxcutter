
local _ = require('utils')
local grid = require('grid')
local scroller = require('scroller')


grid.bind(hs.hotkey.modal.new({'ctrl', 'alt', 'cmd'}, 'space', nil))
scroller.start()
