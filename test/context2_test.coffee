grunt = require 'grunt'

exports.contextualize =
  adjacent_properties_override: (test) ->
    test.equal grunt.config.get('contextTestConfig1.options.cousin'), 'replaced by cousin from context2'
    test.equal grunt.config.get('contextTestConfig2.target1.options.cousin'), 'replaced by cousin from context2'
    test.done()
