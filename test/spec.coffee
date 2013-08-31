mocha.setup 'bdd'
expect = chai.expect

Helpers = Ember.Namespace.create()

require 'tree_search'
require 'helpers/*'
require 'spec/**/*'

mocha.run()
