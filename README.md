TODO Readme

## Usage

### Basic

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
  getCursor: -> TreeCursor.create node: this
a = Node.create()
b = Node.create parentNode: a
a.getCursor().get 'successor' #=> a
```

### Advanced

Subclass TreeSearch.ObjectWithSharedPool

## Development

Run `npm install; grunt` to compile.
Include in your projects with Bower.

