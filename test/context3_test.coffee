grunt = require 'grunt'

exports.contextualize =
  adjacent_properties_override: (test) ->
    test.equal grunt.config.get('contextTestConfig2.target1.options.cousin'), 'context3 cousin'
    test.done()
