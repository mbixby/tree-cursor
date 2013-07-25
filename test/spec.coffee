mocha.setup 'bdd'
expect = chai.expect

require 'tree_search'
require 'helpers/*'
require 'spec/**/*'

mocha.run()
