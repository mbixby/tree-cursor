var TreeSearch;

window.TreeSearch = TreeSearch = Ember.Namespace.create();


if (Ember.EXTEND_PROTOTYPES || Ember.EXTEND_PROTOTYPES.Array) {
  Array.prototype.chunk = function(n) {
    var i, item, x, _i, _len, _results;
    _results = [];
    for ((n > 0 ? (i = _i = 0, _len = this.length) : i = _i = this.length - 1); n > 0 ? _i < _len : _i >= 0; i = _i += n) {
      item = this[i];
      _results.push((function() {
        var _j, _results1;
        _results1 = [];
        for (x = _j = 0; 0 <= n ? _j < n : _j > n; x = 0 <= n ? ++_j : --_j) {
          _results1.push(this[i + x]);
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };
}


var _Debug;

_Debug = {
  bench: function(fnOrLabel, fn) {
    var delta, label, ret, timer;
    label = fn ? fnOrLabel : 'bench';
    fn = fn != null ? fn : fnOrLabel;
    timer = performance.now();
    ret = fn();
    delta = performance.now() - timer;
    if (window[label] == null) {
      window[label] = 0;
    }
    window[label] += delta;
    return ret;
  }
};

setTimeout((function() {
  if (window.bench) {
    return console.log(window.bench);
  }
}), 1000);


if (Ember.EXTEND_PROTOTYPES || Ember.EXTEND_PROTOTYPES.String) {
  String.prototype.stripPrefix = function(prefix) {
    var regex;
    regex = new RegExp("^" + prefix);
    return this.replace(regex, '');
  };
  String.prototype.contains = function(searchedString) {
    var regex;
    regex = new RegExp(searchedString);
    return this.match(regex);
  };
  if (String.Inflector == null) {
    String.Inflector = {};
  }
  String.Inflector.opposites = {
    start: "end",
    end: "start",
    left: "right",
    right: "left",
    "true": "false",
    "false": "true",
    yes: "no",
    no: "yes"
  };
  String.prototype.opposite = function() {
    return String.Inflector.opposites[this];
  };
}


var TogglableComputedProperty,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

TogglableComputedProperty = (function(_super) {
  __extends(TogglableComputedProperty, _super);

  function TogglableComputedProperty() {
    Ember.ComputedProperty.apply(this, arguments);
  }

  TogglableComputedProperty.prototype.get = function(obj, keyName) {
    if (obj.isVolatile) {
      return this.func.call(obj, keyName);
    } else {
      return Ember.ComputedProperty.prototype.get.apply(this, arguments);
    }
  };

  TogglableComputedProperty.prototype.set = function(obj, keyName, value) {
    if (obj.isVolatile || value === void 0) {
      return value;
    } else {
      return Ember.ComputedProperty.prototype.set.apply(this, arguments);
    }
  };

  return TogglableComputedProperty;

})(Ember.ComputedProperty);

TogglableComputedProperty.computed = function(func) {
  var args, cp;
  if (arguments.length > 1) {
    args = [].slice.call(arguments, 0, -1);
    func = [].slice.call(arguments, -1)[0];
  }
  cp = new TogglableComputedProperty(func);
  if (args) {
    cp.property.apply(cp, args);
  }
  return cp;
};

TogglableComputedProperty.computed.alias = function(dependentKey) {
  return TogglableComputedProperty.computed(dependentKey, function(key, value) {
    if (arguments.length > 1) {
      set(this, dependentKey, value);
      return value;
    } else {
      return Ember.get(this, dependentKey);
    }
  });
};

Function.prototype.togglableProperty = function() {
  var ret;
  ret = TogglableComputedProperty.computed(this);
  return ret.property.apply(ret, arguments);
};


var __slice = [].slice;


TreeSearch.ObjectWithSharedPool = Ember.Object.extend().reopenClass({
  create: function(properties) {
    var object;
    if (properties == null) {
      properties = {};
    }
    if (object = this.getFromSharedPool(properties)) {
      return typeof object.setProperties === "function" ? object.setProperties(properties) : void 0;
    } else {
      object = this._super(properties);
      return this.saveToSharedPool(object);
    }
  },
  getFromSharedPool: function(properties) {
    var sharedPool;
    sharedPool = this.sharedPoolForObject(properties);
    return sharedPool != null ? sharedPool.get(this.keyForObject(properties)) : void 0;
  },
  saveToSharedPool: function(object) {
    var sharedPool;
    sharedPool = this.sharedPoolForObject(object);
    if (sharedPool != null) {
      sharedPool.set(this.keyForObject(object), object);
    }
    return object;
  },
  removeFromSharedPool: function(object) {
    var sharedPool;
    sharedPool = this.sharedPoolForObject(object);
    if (sharedPool != null) {
      sharedPool.remove(this.keyForObject(object));
    }
    return object;
  },
  keyForObject: function(properties) {
    return Ember.get(properties, 'id');
  },
  sharedPoolForObject: function(properties) {
    return Ember.get(properties, 'sharedPool');
  }
});

TreeSearch.ObjectWithSharedPool.reopen({
  sharedPool: (function() {
    return Ember.Map.create();
  }).property()
});


TreeSearch.TreeCursor = TreeSearch.ObjectWithSharedPool.extend().reopenClass({
  create: function(properties) {
    var cursor;
    if (properties == null) {
      properties = {};
    }
    if (!properties.node) {
      return null;
    }
    cursor = this._super(properties);
    return cursor.get('_nearestValidCursor');
  },
  keyForObject: function(properties) {
    return properties.node;
  },
  sharedPoolForObject: function(properties) {
    return Ember.get(properties, 'cursorPool');
  }
});

TreeSearch.TreeCursor.reopen(Ember.Copyable, Ember.Freezable, {
  node: Ember.required(),
  isVolatile: false,
  copy: function(properties) {
    var propagatedProperties;
    if (properties == null) {
      properties = {};
    }
    propagatedProperties = this.getProperties(this.treewideProperties.concat(['node']));
    return this.constructor.create(Ember.merge(propagatedProperties, properties));
  },
  copyIntoTree: function(tree, properties) {
    if (properties == null) {
      properties = {};
    }
    return tree.copy(Ember.merge(properties, {
      node: this.node
    }));
  },
  copyIntoNewTree: function(properties, constructor) {
    if (properties == null) {
      properties = {};
    }
    if (constructor == null) {
      constructor = this.constructor;
    }
    return constructor.create(Ember.merge({
      node: this.node,
      _validators: (this.get('_validators')).copy(),
      isVolatile: this.isVolatile
    }, properties));
  },
  concatenatedProperties: ['treewideProperties'],
  treewideProperties: ['cursorPool', 'isVolatile', '_validators', 'originalTree'],
  cursorPool: Ember.computed.alias('sharedPool'),
  init: function() {
    var _ref;
    (_ref = this._super).call.apply(_ref, [this].concat(__slice.call(arguments)));
    return this._translateChildNodesAccessor();
  },
  name: Ember.computed.oneWay('node.name'),
  toString: function() {
    var _ref;
    return (_ref = this.get('name')) != null ? _ref : this._super();
  }
});


var alias;

alias = TogglableComputedProperty.computed.alias;

TreeSearch.TreeCursor.reopen({
  firstChildFromRight: alias('lastChild'),
  firstChildFromLeft: alias('firstChild'),
  rightSuccessor: alias('successor'),
  leftSuccessor: alias('predecessor'),
  rightSuccessorAtSameDepth: alias('successorAtSameDepth'),
  leftSuccessorAtSameDepth: alias('predecessorAtSameDepth'),
  rightLeafSuccessor: alias('leafSuccessor'),
  leftLeafSuccessor: alias('leafPredecessor')
});


TreeSearch.TreeCursor.reopen({
  findParentNode: void 0,
  findChildNodes: void 0,
  findFirstChildNode: void 0,
  findRightSiblingNode: void 0,
  findLeftSiblingNode: void 0,
  _translateChildNodesAccessor: function() {
    if (this.findChildNodes) {
      if (this.findFirstChildNode == null) {
        this.findFirstChildNode = this._firstObjectInChildNodes;
      }
      if (this.findRightSiblingNode == null) {
        this.findRightSiblingNode = this._rightSiblingInChildNodes;
      }
      return this.findLeftSiblingNode != null ? this.findLeftSiblingNode : this.findLeftSiblingNode = this._leftSiblingInChildNodes;
    }
  },
  _firstObjectInChildNodes: function() {
    return this.get('_childNodes.firstObject');
  },
  _rightSiblingInChildNodes: function() {
    var _ref;
    return (_ref = this.get('parent._childNodes')) != null ? _ref.objectAt((this.get('_indexInSiblingNodes')) + 1) : void 0;
  },
  _leftSiblingInChildNodes: function() {
    var _ref;
    return (_ref = this.get('parent._childNodes')) != null ? _ref.objectAt((this.get('_indexInSiblingNodes')) - 1) : void 0;
  },
  _childNodes: (function() {
    return this.findChildNodes(this.node);
  }).togglableProperty(),
  _indexInSiblingNodes: (function() {
    if (this.node === _.head(this.get('parent._childNodes'))) {
      return 0;
    } else {
      if (this.isPropertyMemoized('leftSibling')) {
        return (this.get('leftSibling._indexInSiblingNodes')) + 1;
      } else {
        return (this.get('parent._childNodes')).indexOf(this.node);
      }
    }
  }).togglableProperty()
});


TreeSearch.TreeCursor.reopen({
  branch: (function() {
    return _.flatten(_.compact([this, this.get('parent.branch')]));
  }).togglableProperty('parent.branch'),
  depth: (function() {
    return (this.get('branch.length')) - 1;
  }).togglableProperty('branch'),
  height: (function() {
    if (this.get('isLeaf')) {
      return 0;
    } else {
      return 1 + _.max((this.get('children')).mapProperty('height'));
    }
  }).togglableProperty('isLeaf', 'children.@each.height'),
  findClosestCommonAncestorWithCursor: function(cursor) {
    var branches;
    branches = [this, cursor].map(function(c) {
      return (c.get('branch')).slice().reverse();
    });
    branches = _.zip.apply(_, branches);
    return _.head(_.reduce(branches, (function(_arg, _arg1) {
      var ancestorA, ancestorB, commonAncestor, shouldStop;
      commonAncestor = _arg[0], shouldStop = _arg[1];
      ancestorA = _arg1[0], ancestorB = _arg1[1];
      if ((!shouldStop) && ancestorA === ancestorB) {
        return [ancestorA, false];
      } else {
        return [commonAncestor, shouldStop = true];
      }
    }), [null, false]));
  },
  findChildBelongingToBranch: function(branch) {
    var candidate, _i, _len;
    for (_i = 0, _len = branch.length; _i < _len; _i++) {
      candidate = branch[_i];
      if (this === candidate.get('parent')) {
        return candidate;
      }
    }
    return void 0;
  },
  findClosestSiblingAncestorsWithCursor: function(cursor) {
    var a, ancestor, b, siblings, _ref, _ref1;
    _ref = [this, cursor], a = _ref[0], b = _ref[1];
    ancestor = a.findClosestCommonAncestorWithCursor(b);
    _ref1 = siblings = (function() {
      var _i, _len, _ref1, _results;
      _ref1 = [a, b];
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        cursor = _ref1[_i];
        _results.push(ancestor != null ? ancestor.findChildBelongingToBranch(cursor.get('branch')) : void 0);
      }
      return _results;
    })(), a = _ref1[0], b = _ref1[1];
    if (a && b) {
      return siblings;
    }
  }
});


TreeSearch.TreeCursor.reopen({
  resetCursor: function() {
    return this.resetProperties(this._baseNeighborProperties);
  },
  resetSubtree: function() {
    var _this = this;
    return Ember.changeProperties(function() {
      var cursor, _i, _len, _ref;
      _ref = _this.get('children');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cursor = _ref[_i];
        cursor.resetSubtree();
      }
      return _this.resetCursor();
    });
  },
  resetChildren: function() {
    var _this = this;
    return Ember.changeProperties(function() {
      var cursor, _i, _len, _ref;
      _ref = _this.get('children');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cursor = _ref[_i];
        cursor.resetSubtree();
      }
      return _this.resetProperties(_this._baseChildrenProperties);
    });
  },
  resetProperties: function(keys) {
    var _this = this;
    return Ember.changeProperties(function() {
      var key, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = keys.length; _i < _len; _i++) {
        key = keys[_i];
        _results.push(_this.propertyDidChange(key));
      }
      return _results;
    });
  },
  getMemoizedProperties: function(propertyList) {
    var _this = this;
    if (propertyList == null) {
      propertyList = [];
    }
    return _.zipObject(_.compact(propertyList.map(function(key) {
      var value;
      value = _this.getMemoized(key);
      if (value !== void 0) {
        return [key, value];
      }
    })));
  },
  getMemoized: function(propertyName) {
    var value;
    value = this[propertyName];
    if (value === void 0) {
      value = this.cacheFor(propertyName);
    }
    return value;
  },
  isPropertyMemoized: function(propertyName) {
    return void 0 !== this.getMemoized(propertyName);
  },
  _baseNeighborProperties: ['parent', 'firstChild', 'rightSibling', 'leftSibling', '_childNodes', '_indexInSiblingNodes'],
  _baseChildrenProperties: ['firstChild', '_childNodes', '_indexInSiblingNodes'],
  _clearCacheOfProperty: function(name) {
    var descriptor, meta;
    descriptor = this._getDescriptorOfProperty(name);
    if (descriptor._cacheable) {
      meta = Ember.meta(this, true);
      return delete meta.cache[name];
    }
  },
  _getDescriptorOfProperty: function(name) {
    var descs, prototype;
    prototype = TreeSearch.TreeCursor.proto();
    descs = (Ember.meta(prototype)).descs;
    return descs[name];
  }
});


TreeSearch.TreeCursor.reopen({
  firstChild: (function() {
    return this._createFirstChild({
      node: this.findFirstChildNode(this.node)
    });
  }).togglableProperty(),
  rightSibling: (function() {
    return this._createRightSibling({
      node: this.findRightSiblingNode(this.node)
    });
  }).togglableProperty(),
  leftSibling: (function() {
    return this._createLeftSibling({
      node: typeof this.findLeftSiblingNode === "function" ? this.findLeftSiblingNode(this.node) : void 0
    });
  }).togglableProperty(),
  parent: (function() {
    return this._createParent({
      node: typeof this.findParentNode === "function" ? this.findParentNode(this.node) : void 0
    });
  }).togglableProperty(),
  rightSiblings: (function() {
    var sibling;
    sibling = this.get('rightSibling');
    return _.flatten(_.compact([sibling, sibling != null ? sibling.get('rightSiblings') : void 0]));
  }).togglableProperty('rightSibling', 'rightSibling.rightSiblings'),
  leftSiblings: (function() {
    var sibling;
    sibling = this.get('leftSibling');
    return _.flatten(_.compact([sibling != null ? sibling.get('leftSiblings') : void 0, sibling]));
  }).togglableProperty('leftSibling', 'leftSibling.leftSiblings'),
  rightmostSibling: (function() {
    var _ref;
    return (_ref = this.get('rightSiblings.lastObject')) != null ? _ref : null;
  }).togglableProperty('rightSiblings.lastObject'),
  leftmostSibling: (function() {
    var _ref;
    return (_ref = this.get('leftSiblings.firstObject')) != null ? _ref : null;
  }).togglableProperty('leftSiblings.firstObject'),
  lastChild: (function() {
    var firstChild, _ref;
    firstChild = this.get('firstChild');
    return (_ref = firstChild != null ? firstChild.get('rightmostSibling') : void 0) != null ? _ref : firstChild;
  }).togglableProperty('firstChild', 'firstChild.rightmostSibling'),
  children: (function() {
    var child;
    child = this.get('firstChild');
    return _.compact(_.flatten([child, child != null ? child.get('rightSiblings') : void 0]));
  }).togglableProperty('firstChild', 'firstChild.rightSiblings'),
  root: (function() {
    var _ref;
    return (_ref = this.get('parent.root')) != null ? _ref : this;
  }).togglableProperty('parent.root'),
  isLeaf: (function() {
    return !this.get('firstChild');
  }).togglableProperty('firstChild'),
  isRoot: (function() {
    return !this.get('parent');
  }).togglableProperty('parent'),
  _validReplacementForNode: function() {
    return function() {
      var child, lastChild, rightSibling, _ref;
      if (child = this.get("firstChild")) {
        lastChild = (_ref = child.get('rightmostSibling')) != null ? _ref : child;
        rightSibling = this.get('rightSibling');
        lastChild.set('rightSibling', rightSibling);
        rightSibling.set('leftSibling', lastChild);
        return child;
      } else {
        return this.get("rightSibling");
      }
    };
  },
  _createParent: function(properties) {
    return this.copy(Em.merge(properties, {
      validReplacement: 'parent'
    }));
  },
  _createFirstChild: function(properties) {
    properties = Em.merge(this.getMemoizedProperties(['root']), properties);
    return this.copy(Em.merge(properties, {
      validReplacement: this._validReplacementForNode(),
      parent: this,
      leftSibling: null
    }));
  },
  _createLeftSibling: function(properties) {
    properties = Em.merge(this.getMemoizedProperties(['root', 'parent']), properties);
    return this.copy(Em.merge(properties, {
      validReplacement: this._validReplacementForNode(),
      rightSibling: this
    }));
  },
  _createRightSibling: function(properties) {
    properties = Em.merge(this.getMemoizedProperties(['root', 'parent']), properties);
    return this.copy(Em.merge(properties, {
      validReplacement: this._validReplacementForNode(),
      leftSibling: this
    }));
  }
});


TreeSearch.TreeCursor.reopen({
  isRightOfCursor: function(cursor) {
    return 'right' === this.determineHorizontalPositionAgainstCursor(cursor);
  },
  isLeftOfCursor: function(cursor) {
    return 'left' === this.determineHorizontalPositionAgainstCursor(cursor);
  },
  determinePositionAgainstCursor: function(cursor) {
    var position;
    position = this.determineHorizontalPositionAgainstCursor(cursor);
    return position != null ? position : position = this.determinePositionAgainstMemberOfBranch(cursor);
  },
  determineHorizontalPositionAgainstCursor: function(cursor) {
    var a, ancestors, b;
    if ((!cursor) || this === cursor) {
      return void 0;
    } else if (ancestors = this.findClosestSiblingAncestorsWithCursor(cursor)) {
      a = ancestors[0], b = ancestors[1];
      return a != null ? a.determinePositionAgainstSibling(b) : void 0;
    }
  },
  determinePositionAgainstSibling: function(sibling) {
    var left, nextSiblingPair, right, siblingPair;
    if (!sibling) {
      return void 0;
    }
    nextSiblingPair = function(_arg) {
      var left, right;
      left = _arg[0], right = _arg[1];
      return [left != null ? left.get('leftSibling') : void 0, right != null ? right.get('rightSibling') : void 0];
    };
    siblingPair = [this, this];
    while ((left = siblingPair[0], right = siblingPair[1], siblingPair) && (left || right)) {
      if (sibling === left) {
        return 'right';
      }
      if (sibling === right) {
        return 'left';
      }
      siblingPair = nextSiblingPair(siblingPair);
    }
    return void 0;
  },
  determinePositionAgainstMemberOfBranch: function(cursor) {
    var ancestor, branchA, branchB, _ref;
    if (!cursor) {
      return void 0;
    }
    _ref = [this, cursor].mapProperty('branch'), branchA = _ref[0], branchB = _ref[1];
    ancestor = this.findClosestCommonAncestorWithCursor(cursor);
    if (!((this === ancestor) || cursor === ancestor)) {
      return void 0;
    }
    if (branchA.length < branchB.length) {
      return 'top';
    } else if (branchA.length > branchB.length) {
      return 'bottom';
    } else {
      return void 0;
    }
  }
});


TreeSearch.TreeCursor.reopen({
  upwardSuccessor: (function() {
    var _ref;
    return (_ref = this.get('parent.rightSibling')) != null ? _ref : this.get('parent.upwardSuccessor');
  }).togglableProperty('parent.rightSibling', 'parent.upwardSuccessor'),
  upwardPredecessor: (function() {
    var _ref;
    return (_ref = this.get('parent.leftSibling')) != null ? _ref : this.get('parent.upwardPredecessor');
  }).togglableProperty('parent.leftSibling', 'parent.upwardPredecessor'),
  successor: (function() {
    var _ref, _ref1;
    return (_ref = (_ref1 = this.get('firstChild')) != null ? _ref1 : this.get('rightSibling')) != null ? _ref : this.get('upwardSuccessor');
  }).togglableProperty('firstChild', 'rightSibling', 'upwardSuccessor'),
  predecessor: (function() {
    var _ref, _ref1;
    return (_ref = (_ref1 = this.get('lastChild')) != null ? _ref1 : this.get('leftSibling')) != null ? _ref : this.get('upwardPredecessor');
  }).togglableProperty('lastChild', 'leftSibling', 'upwardPredecessor'),
  findCursorAndItsRelativeDepth: function(propertyName, depth) {
    var cursor;
    if (depth == null) {
      depth = 0;
    }
    cursor = this.get(propertyName);
    if (cursor) {
      return [cursor, Math.abs(depth - cursor.get('depth'))];
    } else {
      return null;
    }
  },
  findSuccessorAtDepth: function(targetDepth, currentDepth) {
    var succ, successorDepth, _ref;
    succ = targetDepth < (currentDepth != null ? currentDepth : this.get('depth')) ? (_ref = this.get('rightSibling')) != null ? _ref : this.get('upwardSuccessor') : this.get('successor');
    successorDepth = succ != null ? succ.get('depth') : void 0;
    if (targetDepth === successorDepth) {
      return succ;
    } else {
      return succ != null ? succ.findSuccessorAtDepth(targetDepth, successorDepth) : void 0;
    }
  },
  findPredecessorAtDepth: function(targetDepth, currentDepth) {
    var pred, predecessorDepth, _ref;
    pred = targetDepth < (currentDepth != null ? currentDepth : this.get('depth')) ? (_ref = this.get('leftSibling')) != null ? _ref : this.get('upwardPredecessor') : this.get('predecessor');
    predecessorDepth = pred != null ? pred.get('depth') : void 0;
    if (targetDepth === predecessorDepth) {
      return pred;
    } else {
      return pred != null ? pred.findPredecessorAtDepth(targetDepth, predecessorDepth) : void 0;
    }
  },
  successorAtSameDepth: (function() {
    return this.findSuccessorAtDepth(this.get('depth'));
  }).togglableProperty().volatile(),
  predecessorAtSameDepth: (function() {
    return this.findPredecessorAtDepth(this.get('depth'));
  }).togglableProperty().volatile(),
  leafSuccessor: (function() {
    var succ;
    if (succ = this.get("successor")) {
      if (succ.get("isLeaf")) {
        return succ;
      } else {
        return succ.get("leafSuccessor");
      }
    } else {
      return null;
    }
  }).togglableProperty('successor', 'successor.isLeaf', 'successor.leafSuccessor'),
  leafPredecessor: (function() {
    var pred;
    if (pred = this.get("predecessor")) {
      if (pred.get("isLeaf")) {
        return pred;
      } else {
        return pred.get("leafPredecessor");
      }
    } else {
      return null;
    }
  }).togglableProperty('predecessor', 'predecessor.isLeaf', 'predecessor.leafSuccessor')
});


TreeSearch.TreeCursor.Validator = Ember.Object.extend({
  error: void 0,
  validate: void 0,
  isTreewideValidation: false
});


TreeSearch.TreeCursor.reopen({
  copyWithNewValidation: function(validationParameters, properties, constructor) {
    var validator;
    validator = TreeSearch.TreeCursor.Validator.create(validationParameters);
    return this.copyWithNewValidator(validator, properties, constructor);
  },
  copyWithNewValidator: function(validator, properties, constructor) {
    if (properties == null) {
      properties = {};
    }
    properties = Ember.merge(properties, {
      _validators: (this.get('_validators')).copy().add(validator),
      originalTree: this
    });
    return this.copyIntoNewTree(properties, constructor);
  },
  validReplacement: void 0,
  _nearestValidCursor: (function() {
    var failed;
    failed = this.get('_firstFailedValidator');
    if (!failed) {
      return this;
    } else if (failed.get('isTreewideValidation')) {
      return null;
    } else {
      return this.get('_extractedValidReplacement');
    }
  }).togglableProperty(),
  _extractedValidReplacement: (function() {
    var accessor;
    accessor = this.get('validReplacement');
    if ('string' === typeof accessor) {
      return this.get(accessor);
    } else {
      return accessor != null ? accessor.apply(this, []) : void 0;
    }
  }).togglableProperty('validReplacement'),
  validations: (function() {
    return _.zipObject((this.get('_validators')).map(function(validator) {
      var identifier, result, _ref;
      identifier = (_ref = validator.identifier) != null ? _ref : Ember.guidFor(validator);
      result = null;
      return [identifier, result];
    }));
  }).togglableProperty('_validators'),
  _validators: (function() {
    return Ember.Set.create();
  }).togglableProperty(),
  _firstFailedValidator: (function() {
    var validator, _i, _len, _ref;
    _ref = this.get('_validators');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      validator = _ref[_i];
      if (!validator.validate(this.get('twinFromOriginalTree'))) {
        return validator;
      }
    }
  }).togglableProperty(),
  twinFromOriginalTree: (function() {
    return this.copyIntoTree(this.originalTree);
  }).togglableProperty(),
  originalTree: void 0
});


TreeSearch.BFS = Ember.Object.extend().reopenClass({
  getNextCursor: function(cursor, direction, initialCursor, meta) {
    var next;
    if (!cursor) {
      next = initialCursor;
    }
    if (next == null) {
      next = cursor.get("" + direction + "SuccessorAtSameDepth");
    }
    return next != null ? next : next = (function() {
      if (meta.leftmost == null) {
        meta.leftmost = initialCursor;
      }
      return meta.leftmost = meta.leftmost.get("firstChildFrom" + (direction.opposite().capitalize()));
    })();
  }
});

TreeSearch.BFSWithQueue = Ember.Object.extend().reopenClass({
  getNextCursor: function(cursor, direction, initialCursor, meta) {
    var child, children, directionStep, next, queue, _i, _len, _ref;
    queue = meta._queue != null ? meta._queue : meta._queue = [initialCursor];
    next = queue.shift();
    directionStep = direction === 'left' ? -1 : 1;
    children = (_ref = next != null ? next.get('children') : void 0) != null ? _ref : [];
    for ((directionStep > 0 ? (_i = 0, _len = children.length) : _i = children.length - 1); directionStep > 0 ? _i < _len : _i >= 0; _i += directionStep) {
      child = children[_i];
      queue.push(child);
    }
    return next;
  }
});


TreeSearch.DFS = Ember.Object.extend().reopenClass({
  getNextCursor: function(cursor, direction, initialCursor, meta) {
    var next;
    if (!cursor) {
      next = initialCursor;
    }
    return next != null ? next : next = cursor.get("" + direction + "Successor");
  }
});

TreeSearch.DFSWithQueue = Ember.Object.extend().reopenClass({
  getNextCursor: function(cursor, direction, initialCursor, meta) {
    var child, children, directionStep, next, queue, _i, _len, _ref;
    queue = meta._queue != null ? meta._queue : meta._queue = [initialCursor];
    next = queue.pop();
    directionStep = direction === 'left' ? -1 : 1;
    children = (_ref = next != null ? next.get('children') : void 0) != null ? _ref : [];
    for ((directionStep > 0 ? (_i = 0, _len = children.length) : _i = children.length - 1); directionStep > 0 ? _i < _len : _i >= 0; _i += directionStep) {
      child = children[_i];
      queue.push(child);
    }
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
    return search.perform();
  }
});

TreeSearch.Base.reopen({
  initialNode: Ember.required(),
  shouldAcceptNode: function(node) {
    return true;
  },
  method: TreeSearch.BFSWithQueue,
  shouldYieldSingleResult: false,
  shouldIgnoreInitialNode: false,
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
  currentNode: void 0,
  previousNode: void 0,
  cursorClass: Ember.required(),
  perform: function() {
    var shouldStop;
    if (this.get('shouldIgnoreInitialNode')) {
      this._getNextNode();
    }
    this.previousNode = this.currentNode;
    while (this.currentNode = this._getNextNode()) {
      shouldStop = this._visitNode(this.currentNode);
      if (shouldStop) {
        break;
      }
    }
    return this.get('result');
  },
  _getNextNode: function() {
    var args, cursor, _ref,
      _this = this;
    args = ['_cursor', 'direction', 'initialCursor', '_searchMeta'];
    args = args.map(function(key) {
      return _this.get(key);
    });
    cursor = (_ref = this.get('method')).getNextCursor.apply(_ref, args);
    this.set('_cursor', cursor);
    return cursor != null ? cursor.node : void 0;
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
  _cursor: null,
  initialCursor: (function() {
    var _ref;
    return (_ref = this.get('initialNode.cursor')) != null ? _ref : (this.get('cursorClass')).create({
      node: this.get('initialNode')
    });
  }).property(),
  _searchMeta: (function() {
    return {};
  }).property(),
  _shouldWalkLeft: (function() {
    return (this.get('direction')) === 'left';
  }).property('direction')
});


TreeSearch.Traversable = Ember.Mixin.create({
  unknownProperty: function(key) {
    var value;
    if (['rootNode', 'cursorClass'].contains(key)) {
      return;
    }
    value = this.get("cursor." + key);
    if (value instanceof TreeSearch.TreeCursor) {
      return value.get('node');
    } else if ((value != null ? value[0] : void 0) && (value != null ? value[0] : void 0) instanceof TreeSearch.TreeCursor) {
      return value.mapProperty('node');
    } else {
      return value;
    }
  },
  cursor: (function() {
    var cursor, rootNode, _ref;
    cursor = (this.get('cursorClass')).create({
      node: this
    });
    rootNode = (_ref = this.get('rootNode')) != null ? _ref : cursor.get('root.node');
    if (this === rootNode) {
      return cursor;
    } else {
      return cursor.copyIntoTree(rootNode.get('cursor'));
    }
  }).property(),
  rootNode: void 0,
  cursorClass: TreeSearch.TreeCursor
});


TreeSearch.Trimming = Ember.Object.extend().reopenClass({
  trim: function(properties) {
    var trimming;
    trimming = this.create(properties);
    return trimming.perform();
  }
});

TreeSearch.Trimming.reopen({
  leftBoundary: null,
  everythingLeftOfBranch: Ember.computed.alias('leftBoundary'),
  rightBoundary: null,
  everythingRightOfBranch: Ember.computed.alias('rightBoundary'),
  perform: function() {
    var root;
    this._coalesceBoundariesOnTheSameBranch();
    root = (this.get('leftBoundary.root')).copyIntoNewTree({}, this.get('_cursorClass'));
    return root.copyWithNewValidator(this.get('_validator'));
  },
  _validator: (function() {
    var _this = this;
    return TreeSearch.TreeCursor.Validator.create({
      validate: function(cursor) {
        return _this._isCursorInsideBoundaries(cursor);
      },
      shouldSkipInvalidCursors: true,
      error: "Node has been trimmed away. " + (this.toString())
    });
  }).property(),
  _isCursorInsideBoundaries: function(cursor) {
    return (cursor.get('_isInsideOfLeftBoundary')) && (cursor.get('_isInsideOfRightBoundary')) && (!cursor.get('_isDescendantOfBoundary'));
  },
  _cursorClass: (function() {
    var trimming;
    trimming = this;
    return (this.get('leftBoundary')).constructor.extend({
      _trimming: trimming,
      propagatedProperties: ['_trimming', '_leftBoundary', '_rightBoundary'],
      _leftBoundary: (function() {
        return (this.get('_trimming.leftBoundary')).copyIntoTree(this, this.getMemoizedProperties(this.propagatedProperties));
      }).property(),
      _rightBoundary: (function() {
        return (this.get('_trimming.rightBoundary')).copyIntoTree(this, this.getMemoizedProperties(this.propagatedProperties));
      }).property(),
      _isInsideOfLeftBoundary: (function() {
        return this._isInsideOfBoundary('left');
      }).property('leftSuccessor._isInsideOfLeftBoundary'),
      _isInsideOfRightBoundary: (function() {
        return this._isInsideOfBoundary('right');
      }).property('rightSuccessor._isInsideOfRightBoundary'),
      _isInsideOfBoundary: function(direction) {
        return ((this.get("_" + direction + "Boundary.branch")).contains(this)) || (this.get("" + direction + "Successor._isInsideOf" + (direction.capitalize()) + "Boundary"));
      },
      _isDescendantOfBoundary: (function() {
        var _ref, _ref1;
        return ((_ref = this.get('parent.branch')) != null ? _ref.contains(this.get('_leftBoundary')) : void 0) || ((_ref1 = this.get('parent.branch')) != null ? _ref1.contains(this.get('_rightBoundary')) : void 0);
      }).property('parent.branch')
    });
  }).property(),
  _coalesceBoundariesOnTheSameBranch: function() {
    var ancestor;
    ancestor = (this.get('leftBoundary')).findClosestCommonAncestorWithCursor(this.get('rightBoundary'));
    if (ancestor === this.get('leftBoundary')) {
      this.set('leftBoundary', this.get('rightBoundary'));
    }
    if (ancestor === this.get('rightBoundary')) {
      return this.set('rightBoundary', this.get('leftBoundary'));
    }
  }
});
