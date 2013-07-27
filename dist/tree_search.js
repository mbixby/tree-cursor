var TreeSearch;

window.TreeSearch = TreeSearch = Ember.Namespace.create();


var TC,
  __hasProp = {}.hasOwnProperty;

TC = TreeSearch.TreeCursor = Ember.Object.extend().reopenClass({
  create: function(parameters) {
    if (parameters == null) {
      parameters = {};
    }
    if (!parameters.node) {
      return null;
    }
    return this._super.apply(this, arguments);
  },
  memoize: function(name) {
    return (function(key, value) {
      if (value) {
        return this._setIfTreeIsNotVolatile(key, value);
      } else {
        return this._getIfTreeIsNotVolatile(name);
      }
    }).property().volatile();
  }
});

TreeSearch.TreeCursor.reopen(Ember.Copyable, Ember.Freezable, {
  node: Ember.required(),
  isTreeVolatile: false,
  parent: TC.memoize('parent'),
  children: TC.memoize('children'),
  firstChild: TC.memoize('firstChild'),
  lastChild: TC.memoize('lastChild'),
  rightSibling: TC.memoize('rightSibling'),
  leftSibling: TC.memoize('leftSibling'),
  rightmostSibling: TC.memoize('rightmostSibling'),
  leftmostSibling: TC.memoize('leftmostSibling'),
  successor: TC.memoize('successor'),
  predecessor: TC.memoize('predecessor'),
  successorAtSameDepth: TC.memoize('successorAtSameDepth'),
  predecessorAtSameDepth: TC.memoize('predecessorAtSameDepth'),
  leafSuccessor: TC.memoize('leafSuccessor'),
  leafPredecessor: TC.memoize('leafPredecessor'),
  root: TC.memoize('root'),
  isLeaf: (function() {
    return !this.get('firstChild');
  }).property().volatile(),
  isRoot: (function() {
    return this === this.get('root');
  }).property().volatile(),
  firstChildFromRight: Ember.computed.alias('lastChild'),
  firstChildFromLeft: Ember.computed.alias('firstChild'),
  rightSuccessor: Ember.computed.alias('successor'),
  leftSuccessor: Ember.computed.alias('predecessor'),
  rightSuccessorAtSameDepth: Ember.computed.alias('successorAtSameDepth'),
  leftSuccessorAtSameDepth: Ember.computed.alias('predecessorAtSameDepth'),
  rightLeafSuccessor: Ember.computed.alias('leafSuccessor'),
  leftLeafSuccessor: Ember.computed.alias('leafPredecessor'),
  findParentNode: void 0,
  findChildNodes: void 0,
  findFirstChildNode: void 0,
  findLastChildNode: void 0,
  findRightSiblingNode: void 0,
  findLeftSiblingNode: void 0,
  findParent: function() {
    if (this.findParentNode) {
      return this.createParent({
        node: this.findParentNode()
      });
    }
  },
  findRoot: function() {
    var _ref;
    return (_ref = this.get('parent.root')) != null ? _ref : this;
  },
  findChildren: function() {
    var childNodes, _ref, _ref1;
    if (this.findChildNodes) {
      childNodes = this.findChildNodes();
      return this.createChildren(childNodes.map(function(node) {
        return {
          node: node
        };
      }), childNodes);
    } else if (this.findFirstChildNode && this.findRightSiblingNode) {
      return (_ref = (_ref1 = this.get('firstChild')) != null ? _ref1.findMeAndRightSiblings() : void 0) != null ? _ref : [];
    }
  },
  findMeAndRightSiblings: function() {
    var rightSiblings;
    rightSiblings = this.findRightSiblings();
    rightSiblings.unshift(this);
    return rightSiblings;
  },
  findRightSiblings: function() {
    var hisSiblings, sibling, _ref;
    sibling = this.get('rightSibling');
    hisSiblings = (_ref = sibling != null ? sibling.findRightSiblings() : void 0) != null ? _ref : [];
    if (sibling) {
      hisSiblings.unshift(sibling);
    }
    return hisSiblings;
  },
  findFirstChild: function() {
    if (this.findFirstChildNode) {
      return this.createFirstChild({
        node: this.findFirstChildNode()
      });
    } else {
      return this.get('children.firstObject');
    }
  },
  findLastChild: function() {
    if (this.findLastChildNode) {
      return this.createLastChild({
        node: this.findLastChildNode()
      });
    } else if (this.findFirstChildNode) {
      return this.get('firstChild.rightmostSibling');
    } else {
      return this.get('children.lastObject');
    }
  },
  someSiblings: (function() {
    return [this];
  }).property(),
  allSiblings: null,
  indexInSiblings: 0,
  findRightSibling: function() {
    var sibling;
    sibling = (this.get('someSiblings')).objectAt((this.get('indexInSiblings')) + 1);
    return sibling != null ? sibling : sibling = this.findRightSiblingNode ? (sibling = this.createRightSibling({
      node: this.findRightSiblingNode()
    }), this.updateMemoizedSiblings({
      sibling: sibling,
      direction: 'right'
    }), sibling) : void 0;
  },
  findLeftSibling: function() {
    var sibling;
    sibling = (this.get('someSiblings')).objectAt((this.get('indexInSiblings')) - 1);
    return sibling != null ? sibling : sibling = this.findLeftSiblingNode ? (sibling = this.createLeftSibling({
      node: this.findLeftSiblingNode()
    }), this.updateMemoizedSiblings({
      sibling: sibling,
      direction: 'left'
    }), sibling) : void 0;
  },
  updateMemoizedSiblings: function(opts) {
    var areAllSiblingsMemoized, newSiblings, sibling, siblings;
    siblings = this.get('someSiblings');
    sibling = opts.sibling;
    if (sibling) {
      newSiblings = (function() {
        if (opts.direction === 'right') {
          siblings.push(sibling);
        } else {
          siblings.unshift(sibling);
        }
        return siblings;
      })();
      this.set('someSiblings', newSiblings);
      sibling.set('someSiblings', newSiblings);
      if (opts.direction === 'left') {
        this.incrementProperty('indexInSiblings');
        return sibling.incrementProperty('indexInSiblings');
      }
    } else {
      this.set("_didMemoize" + (opts.direction.capitalize()) + "mostSibling", true);
      areAllSiblingsMemoized = (this.get('_didMemoizeRightmostSibling')) && (this.get('_didMemoizeLeftmostSibling'));
      if (areAllSiblingsMemoized) {
        return this.set('allSiblings', siblings);
      }
    }
  },
  findRightmostSibling: function() {
    var _ref, _ref1;
    return (_ref = (_ref1 = this.get('allSiblings.lastObject')) != null ? _ref1 : (this.findLastChildNode ? this.get('parent.lastChild') : void 0)) != null ? _ref : this.findRightSiblings().get('lastObject');
  },
  findLeftmostSibling: function() {
    var _ref;
    return (_ref = this.get('allSiblings.firstObject')) != null ? _ref : (this.findFirstChildNode ? this.get('parent.firstChild') : void 0);
  },
  findSuccessor: function() {
    var successor, _, _ref;
    _ref = this.findSuccessorAndItsDepth(), successor = _ref[0], _ = _ref[1];
    return successor;
  },
  findPredecessor: function() {
    var predecessor, _, _ref;
    _ref = this.findPredecessorAndItsDepth(), predecessor = _ref[0], _ = _ref[1];
    return predecessor;
  },
  findSuccessorAndItsDepth: function(depth) {
    var succ, _, _ref, _ref1, _ref2;
    if (depth == null) {
      depth = 0;
    }
    _ref = [this.get('firstChild'), depth + 1], succ = _ref[0], _ = _ref[1];
    if (!succ) {
      _ref1 = [this.get('rightSibling'), depth + 0], succ = _ref1[0], _ = _ref1[1];
    }
    if (!succ) {
      _ref2 = this.findUpwardSuccessorAndItsDepth(depth), succ = _ref2[0], _ = _ref2[1];
    }
    return [succ, _];
  },
  findPredecessorAndItsDepth: function(depth) {
    var pred, _, _ref, _ref1, _ref2;
    if (depth == null) {
      depth = 0;
    }
    _ref = [this.get('lastChild'), depth + 1], pred = _ref[0], _ = _ref[1];
    if (!pred) {
      _ref1 = [this.get('leftSibling'), depth + 0], pred = _ref1[0], _ = _ref1[1];
    }
    if (!pred) {
      _ref2 = this.findUpwardPredecessorAndItsDepth(depth), pred = _ref2[0], _ = _ref2[1];
    }
    return [pred, _];
  },
  findUpwardSuccessorAndItsDepth: function(depth) {
    var succ, _ref;
    if (depth == null) {
      depth = 0;
    }
    succ = this.get('parent.rightSibling');
    if (!(succ || !this.get('parent'))) {
      _ref = (this.get('parent')).findUpwardSuccessorAndItsDepth(depth), succ = _ref[0], depth = _ref[1];
    }
    return [succ, depth - 1];
  },
  findUpwardPredecessorAndItsDepth: function(depth) {
    var pred, _ref, _ref1;
    if (depth == null) {
      depth = 0;
    }
    pred = this.get('parent.leftSibling');
    if (!(pred || !this.get('parent'))) {
      _ref1 = (_ref = this.get('parent')) != null ? _ref.findUpwardPredecessorAndItsDepth(depth) : void 0, pred = _ref1[0], depth = _ref1[1];
    }
    return [pred, depth - 1];
  },
  findSuccessorAtSameDepth: function() {
    return this.findSuccessorAtDepth(0);
  },
  findPredecessorAtSameDepth: function() {
    return this.findPredecessorAtDepth(0);
  },
  findSuccessorAtDepth: function(depth) {
    var rightSibling, succ, _ref, _ref1;
    if (depth == null) {
      depth = 0;
    }
    _ref1 = depth >= 0 ? (rightSibling = this.get('rightSibling'), (_ref = (rightSibling ? [rightSibling, depth] : void 0)) != null ? _ref : this.findUpwardSuccessorAndItsDepth(depth)) : this.findSuccessorAndItsDepth(depth), succ = _ref1[0], depth = _ref1[1];
    if (depth === 0) {
      return succ;
    }
    return succ != null ? succ.findSuccessorAtDepth(depth) : void 0;
  },
  findPredecessorAtDepth: function(depth) {
    var leftSibling, pred, _ref, _ref1;
    if (depth == null) {
      depth = 0;
    }
    _ref1 = depth >= 0 ? (leftSibling = this.get('leftSibling'), (_ref = (leftSibling ? [leftSibling, depth] : void 0)) != null ? _ref : this.findUpwardPredecessorAndItsDepth(depth)) : this.findPredecessorAndItsDepth(depth), pred = _ref1[0], depth = _ref1[1];
    if (depth === 0) {
      return pred;
    }
    return pred != null ? pred.findPredecessorAtDepth(depth) : void 0;
  },
  findLeafSuccessor: function(direction) {
    var succ, successorIsLeaf;
    if (direction == null) {
      direction = 'right';
    }
    succ = this.get("" + direction + "Successor");
    if (!succ) {
      return;
    }
    successorIsLeaf = !succ.get("firstChild");
    if (successorIsLeaf) {
      return succ;
    } else {
      return succ.get("" + direction + "LeafSuccessor");
    }
  },
  findLeafPredecessor: function() {
    return this.findLeafSuccessor('left');
  },
  createParent: function(properties) {
    if (this === this._getMemoized('root')) {
      return null;
    }
    return this.copy(['root'], properties);
  },
  createChildren: function(arrayOfProperties) {
    var index, properties, siblings, _i, _len, _results;
    siblings = arrayOfProperties.mapProperty('node');
    _results = [];
    for (index = _i = 0, _len = arrayOfProperties.length; _i < _len; index = ++_i) {
      properties = arrayOfProperties[index];
      _results.push(this.copy(['root'], Em.merge(properties, {
        parent: this,
        someSiblings: siblings,
        allSiblings: siblings,
        indexInSiblings: index
      })));
    }
    return _results;
  },
  createFirstChild: function(properties) {
    return this.copy(['root'], Em.merge(properties, {
      parent: this
    }));
  },
  createLastChild: function(properties) {
    return this.copy(['root'], Em.merge(properties, {
      parent: this
    }));
  },
  createRightSibling: function(properties) {
    return this.copy('root parent'.w(), Em.merge(properties, {
      indexInSiblings: (this.get('indexInSiblings')) + 1,
      someSiblings: this.get('someSiblings'),
      allSiblings: this.get('allSiblings')
    }));
  },
  createLeftSibling: function(properties) {
    return this.copy('root parent'.w(), Em.merge(properties, {
      indexInSiblings: (this.get('indexInSiblings')) - 1,
      someSiblings: this.get('someSiblings'),
      allSiblings: this.get('allSiblings')
    }));
  },
  copy: function(savedProperties, properties) {
    if (savedProperties == null) {
      savedProperties = ['root'];
    }
    if (properties == null) {
      properties = {};
    }
    savedProperties = this._saved_properties(savedProperties);
    return this.constructor.create(Em.merge(savedProperties, properties));
  },
  _getIfTreeIsNotVolatile: function(name) {
    var getter, key, value,
      _this = this;
    getter = this['find' + name.capitalize()];
    if (this.get('isTreeVolatile')) {
      return getter.call(this);
    } else {
      key = "_saved_" + name;
      value = this.get(key);
      return value != null ? value : value = (function() {
        value = getter.call(_this);
        _this.set(key, value);
        return value;
      })();
    }
  },
  _getMemoized: function(key) {
    return this.get("_saved_" + key);
  },
  _setIfTreeIsNotVolatile: function(key, value) {
    return this.set("_saved_" + key, value);
  },
  _saved_properties: function(propertyList) {
    var keysAndValues,
      _this = this;
    if (propertyList == null) {
      propertyList = [];
    }
    keysAndValues = propertyList.map(function(name) {
      var key;
      key = "_saved_" + name;
      return [key, _this.get(key)];
    });
    return keysAndValues.reduce((function(object, _arg) {
      var key, value;
      key = _arg[0], value = _arg[1];
      object[key] = value;
      return object;
    }), {});
  },
  reset: function(savedProperties, properties) {
    var key, keys, keysOfPropertiesToDelete, value, _i, _len, _results;
    if (savedProperties == null) {
      savedProperties = ['root'];
    }
    if (properties == null) {
      properties = {};
    }
    keys = keysOfPropertiesToDelete = this.keysOfMemoizedProperties();
    keys.concat("node".w());
    keys = keys.reject(function(key) {
      return savedProperties.contains(key);
    });
    for (_i = 0, _len = keys.length; _i < _len; _i++) {
      key = keys[_i];
      this[key] = void 0;
    }
    _results = [];
    for (key in properties) {
      value = properties[key];
      _results.push(this[key] = value);
    }
    return _results;
  },
  _keysOfMemoizedProperties: function() {
    var key, _, _results;
    _results = [];
    for (key in this) {
      if (!__hasProp.call(this, key)) continue;
      _ = this[key];
      if (key.match(/^_saved_/)) {
        _results.push(key);
      }
    }
    return _results;
  }
});


TreeSearch.BFS = Ember.Mixin.create({
  _getNextCursor: function() {
    var direction, firstCursorAtDepth, next;
    direction = this.get("direction");
    if (!this.get('_current')) {
      next = this.get("_cursor");
    }
    if (next == null) {
      next = this.get("_current." + direction + "SuccessorAtSameDepth");
    }
    if (!next) {
      firstCursorAtDepth = this.getWithDefault("_firstCursorAtCurrentDepth", this.get("_current"));
      next = firstCursorAtDepth.get(direction === "left" ? "lastChild" : "firstChild");
      this.set("_firstCursorAtCurrentDepth", next);
      this.incrementProperty("depth");
    }
    this.set('_current', next);
    return next;
  }
});

TreeSearch.BFSWithQueue = Ember.Mixin.create({
  _getNextCursor: function() {
    var child, children, depth, direction, next, queue, _i, _len, _ref, _ref1;
    queue = this.getWithDefault('_queue', [[this.get('_cursor', 0)]]);
    if (queue[0]) {
      _ref = queue.shift(), next = _ref[0], depth = _ref[1];
    }
    direction = this.get('_shouldWalkLeft') ? -1 : 1;
    children = (_ref1 = next != null ? next.get('children') : void 0) != null ? _ref1 : [];
    for ((direction > 0 ? (_i = 0, _len = children.length) : _i = children.length - 1); direction > 0 ? _i < _len : _i >= 0; _i += direction) {
      child = children[_i];
      queue.push([child, depth + 1]);
    }
    this.set('_queue', queue);
    this.set('depth', depth);
    return next;
  }
});


TreeSearch.DFS = Ember.Mixin.create({
  _getNextCursor: function() {
    var child, children, depth, direction, next, queue, _i, _len, _ref, _ref1;
    queue = this.getWithDefault('_queue', [[this.get('_cursor', 0)]]);
    if (queue[0]) {
      _ref = queue.pop(), next = _ref[0], depth = _ref[1];
    }
    direction = this.get('_shouldWalkLeft') ? -1 : 1;
    children = (_ref1 = next != null ? next.get('children') : void 0) != null ? _ref1 : [];
    for ((direction > 0 ? (_i = 0, _len = children.length) : _i = children.length - 1); direction > 0 ? _i < _len : _i >= 0; _i += direction) {
      child = children[_i];
      queue.push([child, depth + 1]);
    }
    this.set('_queue', queue);
    this.set('depth', depth);
    return next;
  }
});


TreeSearch.LeavesOnlySearch = Ember.Mixin.create({
  _getNextCursor: function() {
    var direction, next, _ref;
    direction = this.get('direction');
    next = !this.get('_current') ? (_ref = (this.get('_cursor.isLeaf') ? this.get('_cursor') : void 0)) != null ? _ref : this.get("_cursor." + direction + "LeafSuccessor") : this.get("_current." + direction + "LeafSuccessor");
    this.set('_current', next);
    return next;
  }
});


TreeSearch.Base = Ember.Object.extend().reopenClass({
  createAndPerform: function(properties) {
    var search;
    if (properties == null) {
      properties = {};
    }
    search = this.create(properties);
    return search._perform();
  }
});

TreeSearch.Base.reopen({
  initialNode: Ember.required(),
  shouldAcceptNode: function(node) {
    return true;
  },
  method: TreeSearch.BFS,
  shouldYieldSingleResult: false,
  shouldIgnoreInitialNode: true,
  direction: 'right',
  shouldStopSearch: function(node) {
    return false;
  },
  depth: 0,
  error: null,
  result: (function() {
    if (this.get('shouldYieldSingleResult')) {
      return null;
    } else {
      return [];
    }
  }).property(),
  willEnterNode: Ember.K,
  didEnterNode: Ember.K,
  cursorClass: Ember.required(),
  _perform: function() {
    var candidate, shouldStop;
    this._pickAlgorithm();
    if (this.get('shouldIgnoreInitialNode')) {
      this.set('_cursor', this._getNextCursor());
    }
    while (candidate = this._getNextNode()) {
      shouldStop = this._visitNode(candidate);
      if (shouldStop) {
        break;
      }
    }
    return this.get('result');
  },
  _getNextNode: function() {
    this.set('_cursor', this._getNextCursor());
    return this.get('_cursor.node');
  },
  _visitNode: function(candidate) {
    this.willEnterNode(candidate);
    if (this.shouldStopSearch(candidate)) {
      return true;
    }
    if (this.shouldAcceptNode(candidate)) {
      this._addToResult(candidate);
      if (this.get('shouldYieldSingleResult')) {
        return true;
      }
    }
    this.didEnterNode(candidate);
    return false;
  },
  _addToResult: function(node) {
    if (this.get('shouldYieldSingleResult')) {
      return this.set('result', node);
    } else {
      return (this.get('result')).push(node);
    }
  },
  _pickAlgorithm: function() {
    var algorithm;
    algorithm = this.get('method');
    return algorithm.apply(this);
  },
  _getNextCursor: null,
  _cursor: (function() {
    return (this.get('cursorClass')).create({
      node: this.get('initialNode')
    });
  }).property(),
  _shouldWalkLeft: (function() {
    return (this.get('direction')) === 'left';
  }).property('direction')
});
