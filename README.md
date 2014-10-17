# TreeCursor

TreeCursor provides a generic way of traversing trees (retrieving node's children, successors, etc.) with support for togglable memoization, property observers, virtual tree representations, lazy validators and partial tree discovery. This is mostly an **experimental** project.

## Features 

By implementing one method (`#findChildrenNodes`) you will 
automatically gain:

* useful node accessors, e.g. `#root`, `#firstChild`, `#successor`, 
  `#leafSuccessor`,...
* property observers
* memoization of adjacent nodes (for more efficient traversal)
* search
* your previous node class cleaned up from basic traversal-related code
* support for volatile trees (trees whose nodes change dynamically)
* nomenclature that follows conventions (popular or from CS literature)

And if you additionally implement `#findParentNode`:

* ability to lazily reject selected nodes based on predefined validations
* ability to trim trees, prune branches
* ability to work with partially discovered trees (nodes will recognize each
  other – see cursor pools)

## Getting Started

### Basic

Provide your own tree-specific implementation by extending this class
and implementing at least methods `#findParentNode` and `#findChildrenNodes`. Alternatively, you can implement `#findParentNode`, `#findFirstChildNode `
and `#findRightSiblingNode`. Implement the rest of `#find*Node` methods
if you need or already have more efficient traversal.

```coffeescript
Node = Ember.Object.extend TreeSearch.Traversable,
  name: undefined
  childNodes: undefined
  parentNode: null

  # By mixing in TreeSearch.Traversable and providing custom cursorClass, 
  # we'll gain all of TreeCursor's perks and features.
  cursorClass: TreeSearch.TreeCursor.extend
    findChildNodes: (node) -> node.childNodes
    findParentNode: (node) -> node.parentNode

a = Node.create()
b = Node.create parentNode: a
a.get 'successor' #=> a
```

### Minimal

```coffeescript
class Node
  name: undefined
  childNodes: undefined
  init: -> @cursor = TreeCursor.create node: this
a = Node.create()
b = Node.create parentNode: a
a.cursor.get 'successor' #=> a
```

### Advanced

Subclass TreeSearch.ObjectWithSharedPool 
TBA Example

## Antipatterns

Don't use TreeCursor...  

* when using trees for data storage, not data representation
* in large trees – there are currently no benchmarks and best performance hasn't been amongst the project's goals

## Dependencies

`ember-core` provides widely-used OOP features (link to blog post) and some faux FRP features that don't require as much time investment (as, for example, Reactive Extensions)   
`lodash`

## Roadmap

* more documentation
* module export
* mutability (currently you need to call #resetSubtree after changing 
  a subtree)
* refactor TreeSearch into lazy `map` and `filter` methods
* circular dependencies and eventual consistency
* better performance, benchmarks

## Last but not least

This is a paragraph used to brag about the included *ASCII tree parser* written solely for better test readability. 

```coffeescript
Helpers.AsciiTreeParser.parse """
         H
       /   ∖
     E       L 
   /  ∖  
  L    O  
"""
```

## Development

Run `npm install; bower install; grunt` to compile.
Run `grunt test` for unit and acceptance tests.
Include in your projects with Bower.

## License

Copyright 2013 by Michal Obrocnik and licensed under the MIT License. See included [LICENSE](/mbixby/tree-cursor/blob/master/LICENSE) file for details. 'Tree' icon by Bruno Forni is used under a [CC BY](http://creativecommons.org/licenses/by/3.0/us/) lincese.

Some documentation and comments are cited from Obrocnik, Michal. "Document Annotation Tool." Thesis. Masaryk University, 2014. Web.
