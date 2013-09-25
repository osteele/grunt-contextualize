grunt = require 'grunt'

exports.contextualize =
  sibling_properties_override: (test) ->
    test.equal grunt.config.get('contextTestConfig1.options.sibling'), 'context1 sibling'
    test.done()

  adjacent_properties_override: (test) ->
    test.equal grunt.config.get('contextTestConfig1.options.cousin'), 'context2 cousin'
    test.equal grunt.config.get('contextTestConfig2.target1.options.cousin'), 'context2 cousin'
    test.done()
