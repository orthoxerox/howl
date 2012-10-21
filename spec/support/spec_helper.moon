require 'busted'
say = require('say')
import File from lunar.fs
import theme from lunar.ui
import signal from lunar
_G.Spy = require 'lunar.spec.spy'

-- addition aliases
export context = describe

-- includes assertion
includes = (state, args) ->
  t, b = table.unpack args
  error 'Not a table', 1 if type(t) != 'table'
  for v in *t
    if v == b
      return true, args
  return false, args

say\set("assertion.includes.positive", "Expected '%s' to include '%s'")
say\set("assertion.includes.negative", "Expected '%s' to not include '%s'")
assert\register("assertion", "includes", includes, "assertion.includes.positive", "assertion.includes.negative")

-- match assertion
match = (state, args) ->
  target, pattern = table.unpack args
  return target\match(pattern) != nil, { target, pattern }

say\set("assertion.match.positive", "Expected '%s' to match '%s'")
say\set("assertion.match.negative", "Expected '%s' to not match '%s'")
assert\register("assertion", "match", match, "assertion.match.positive", "assertion.match.negative")

-- raises assertion
raises = (state, args) ->
  pattern, f = table.unpack args
  error 'Not a function', 2 if type(f) != 'function'
  status, raised_error = pcall f
  raised_error = raised_error or '<no-error>'
  val = not status and raised_error\match(pattern) != nil
  return val, { pattern }

say\set("assertion.raises.positive", "Function raised no error matching '%s'")
say\set("assertion.raises.negative", "Function did raise an error matching '%s'")
assert\register("assertion", "raises", raises, "assertion.raises.positive", "assertion.raises.negative")

-- helpers
export with_tmpfile = (f) ->
  file = File.tmpfile!
  status, err = pcall f, file
  file\delete_all! if file.exists
  error err if not status

export with_tmpdir = (f) ->
  dir = File.tmpdir!
  status, err = pcall f, dir
  dir\delete_all! if dir.exists
  error err if not status

root = lunar.app.root_dir
support_files = root / 'spec' / 'support'

-- load basic theme for specs
theme.register('spec_theme', support_files / 'spec_theme.moon')
theme.current = 'spec_theme'

-- catch any errors and store them in _G.errors
-- export errors = {}
-- signal.connect_first 'error', (e) ->
--   append errors, e
--   true