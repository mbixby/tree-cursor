var TreeSearch;

window.TreeSearch = TreeSearch = Ember.Namespace.create();


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


var __slice = [].slice;

TreeSearch.TreeCursor = Ember.Object.extend().reopenClass({
  create: function(parameters) {
    var cursor;
    if (parameters == null) {
      parameters = {};
    }
    if (!parameters.node) {
      return null;
    }
    cursor = this._super.apply(this, arguments);
    cursor._warnAboutMissingMethods();
    return cursor.get('_nearestValidCursor');
  }
});

TreeSearch.TreeCursor.reopen(Ember.Copyable, Ember.Freezable, {
  node: Ember.required(),
  isVolatile: false,
  equals: function(cursor) {
    var _this = this;
    if (!cursor) {
      return false;
    }
    return (this === cursor) || (function() {
      var a, b, isEqualsMethodDefined, _ref;
      _ref = [_this.get('node'), cursor.get('node')], a = _ref[0], b = _ref[1];
      isEqualsMethodDefined = ('object' === typeof a) && (a.equals != null);
      if (isEqualsMethodDefined) {
        return a.equals(b);
      } else {
        return a === b;
      }
    })();
  },
  copy: function(carryOver, otherProperties) {
    var carriedOver, properties, specificToCopying;
    if (carryOver == null) {
      carryOver = this.treewideProperties;
    }
    if (otherProperties == null) {
      otherProperties = {};
    }
    carriedOver = this._memoizedPropertiesForKeys(carryOver);
    specificToCopying = {
      node: this.node
    };
    properties = [specificToCopying, carriedOver, otherProperties];
    properties = properties.reduce((function(a, b) {
      return Ember.merge(a, b);
    }), {});
    return this.constructor.create(properties);
  },
  treewideProperties: ['root', 'isVolatile', '_validators'],
  _init: function() {
    var _ref;
    (_ref = this._super).call.apply(_ref, [this].concat(__slice.call(arguments)));
    return this._translateChildNodesAccessor();
  }
});


TreeSearch.TreeCursor.reopen({
  firstChildFromRight: Ember.computed.alias('lastChild'),
  firstChildFromLeft: Ember.computed.alias('firstChild'),
  rightSuccessor: Ember.computed.alias('successor'),
  leftSuccessor: Ember.computed.alias('predecessor'),
  rightSuccessorAtSameDepth: Ember.computed.alias('successorAtSameDepth'),
  leftSuccessorAtSameDepth: Ember.computed.alias('predecessorAtSameDepth'),
  rightLeafSuccessor: Ember.computed.alias('leafSuccessor'),
  leftLeafSuccessor: Ember.computed.alias('leafPredecessor')
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
        this.findFirstChildNode = function() {
          return this.get('_childNodes.firstObject');
        };
      }
      if (this.findRightSiblingNode == null) {
        this.findRightSiblingNode = function() {
          return (this.get('parent._childNodes')).objectAt(this.get('_indexInSiblingNodes' + 1));
        };
      }
      return this.findLeftSiblingNode != null ? this.findLeftSiblingNode : this.findLeftSiblingNode = function() {
        return (this.get('parent._childNodes')).objectAt(this.get('_indexInSiblingNodes' - 1));
      };
    }
  },
  _childNodes: (function() {
    return this.findChildNodes();
  }).property().meta({
    cursorSpecific: true
  }),
  _indexInSiblingNodes: (function() {
    return (this.get('parent._childNodes')).indexOf(this.get('node'));
  }).property().meta({
    cursorSpecific: true
  })
});


TreeSearch.TreeCursor.reopen({
  branch: (function() {
    return _.flatten(_.compact([this, this.get('parent.branch')]));
  }).property('parent.branch').meta({
    cursorSpecific: true
  }),
  depth: (function() {
    return (this.get('branch.length')) - 1;
  }).property('branch').meta({
    cursorSpecific: true
  }),
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
      if ((!shouldStop) && (ancestorA != null ? ancestorA.equals(ancestorB) : void 0)) {
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
      if (this.equals(candidate.get('parent'))) {
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
  _memoizedPropertiesForKeys: function(propertyList) {
    var keysAndValues,
      _this = this;
    if (propertyList == null) {
      propertyList = [];
    }
    keysAndValues = propertyList.map(function(key) {
      var value;
      value = _this[key] !== void 0 ? _this[key] : _this.cacheFor(key);
      if (value !== void 0) {
        return [key, value];
      }
    });
    return _.zipObject(_.compact(keysAndValues));
  },
  reset: function(preserved, properties) {
    var key, keys, value, _i, _len;
    if (preserved == null) {
      preserved = ['root'];
    }
    if (properties == null) {
      properties = {};
    }
    keys = this.get('_namesOfCursorSpecificProperties');
    keys = keys.reject(function(key) {
      return preserved.contains(key);
    });
    for (_i = 0, _len = keys.length; _i < _len; _i++) {
      key = keys[_i];
      this._clearCacheOfProperty(key);
    }
    for (key in properties) {
      value = properties[key];
      this.set(key, value);
    }
    return this;
  },
  _namesOfCursorSpecificProperties: (function() {
    return _.compact(this.eachComputedProperty(function(name, meta) {
      if (meta.cursorSpecific) {
        return name;
      }
    }));
  }).property().volatile(),
  _getDescriptorOfProperty: function(name) {
    var descriptors, prototype;
    prototype = this.proto();
    descriptors = (Ember.meta(prototype)).descs;
    return descriptors[name];
  },
  _clearCacheOfProperty: function(name) {
    var descriptor;
    descriptor = Ember.meta(this._getDescriptorOfProperty(name));
    if (descriptor._cacheable) {
      return delete meta.cache[keyName];
    }
  },
  _cachedOrDefinedProperty: function(name) {
    var value;
    value = this[name];
    if (value === void 0) {
      value = this.cacheFor(name);
    }
    return value;
  },
  _isPropertyCachedOrDefined: function(name) {
    return void 0 !== this._cachedOrDefinedProperty(name);
  },
  didChangeTreeVolatility: (function() {
    var descriptor, isVolatile, key, wasVolatile, _i, _len, _ref, _results;
    isVolatile = this.get('isVolatile');
    wasVolatile = this._previousValueOfIsVolatile;
    this._previousValueOfIsVolatile = isVolatile;
    _ref = this.get('_namesOfCursorSpecificProperties');
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      key = _ref[_i];
      descriptor = this._getDescriptorOfProperty(key);
      if ((!wasVolatile) && !descriptor._cacheable) {
        Ember.setMeta(descriptor, 'shouldStayVolatile', true);
      }
      if (!Ember.getMeta(descriptor, 'shouldStayVolatile')) {
        descriptor.cacheable(!isVolatile);
        if (!isVolatile) {
          _results.push(this.propertyDidChange(name));
        } else {
          _results.push(void 0);
        }
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  }).observes('isVolatile'),
  _previousValueOfIsVolatile: false
});


TreeSearch.TreeCursor.reopen({
  parent: (function() {
    this._assertExistenceOfParentNodeAccessor();
    return this._createParent({
      node: typeof this.findParentNode === "function" ? this.findParentNode() : void 0
    });
  }).property().meta({
    cursorSpecific: true
  }),
  firstChild: (function() {
    return this._createFirstChild({
      node: this.findFirstChildNode()
    });
  }).property().meta({
    cursorSpecific: true
  }),
  rightSibling: (function() {
    return this._createRightSibling({
      node: this.findRightSiblingNode()
    });
  }).property().meta({
    cursorSpecific: true
  }),
  leftSibling: (function() {
    return this._createLeftSibling({
      node: typeof this.findLeftSiblingNode === "function" ? this.findLeftSiblingNode() : void 0
    });
  }).property().meta({
    cursorSpecific: true
  }),
  rightSiblings: (function() {
    var sibling;
    sibling = this.get('rightSibling');
    return _.flatten(_.compact([sibling, sibling != null ? sibling.get('rightSiblings') : void 0]));
  }).property('rightSibling', 'rightSibling.rightSiblings').meta({
    cursorSpecific: true
  }),
  leftSiblings: (function() {
    var sibling;
    sibling = this.get('leftSibling');
    return _.flatten(_.compact([sibling != null ? sibling.get('leftSiblings') : void 0, sibling]));
  }).property('leftSibling', 'leftSibling.leftSiblings').meta({
    cursorSpecific: true
  }),
  rightmostSibling: (function() {
    var _ref;
    return (_ref = this.get('rightSiblings.lastObject')) != null ? _ref : null;
  }).property('rightSiblings.lastObject').meta({
    cursorSpecific: true
  }),
  leftmostSibling: (function() {
    var _ref;
    return (_ref = this.get('leftSiblings.firstObject')) != null ? _ref : null;
  }).property('leftSiblings.firstObject').meta({
    cursorSpecific: true
  }),
  lastChild: (function() {
    var firstChild, _ref;
    firstChild = this.get('firstChild');
    return (_ref = firstChild != null ? firstChild.get('rightmostSibling') : void 0) != null ? _ref : firstChild;
  }).property('firstChild', 'firstChild.rightmostSibling').meta({
    cursorSpecific: true
  }),
  children: (function() {
    var child;
    child = this.get('firstChild');
    return _.compact(_.flatten([child, child != null ? child.get('rightSiblings') : void 0]));
  }).property('firstChild', 'firstChild.rightSiblings').meta({
    cursorSpecific: true
  }),
  root: (function() {
    var _ref;
    return (_ref = this.get('parent.root')) != null ? _ref : this;
  }).property('parent.root').meta({
    cursorSpecific: true
  }),
  isLeaf: (function() {
    return !this.get('firstChild');
  }).property('firstChild').meta({
    cursorSpecific: true
  }),
  isRoot: (function() {
    return this === this.get('root');
  }).property('root').meta({
    cursorSpecific: true
  }),
  _assertExistenceOfParentNodeAccessor: function() {
    return Ember.assert("Function findParentNode should be defined. For example if you were to copy any cursor and findParentNode wasn't defined, it would have no way to get back to root. (Because memoized adjacent cursors of the copied cursor would be deleted when copying and it would have to compute them again.)", this.findParentNode);
  },
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
    return this.copy(this.treewideProperties, Em.merge(properties, {
      validReplacement: 'parent'
    }));
  },
  _createChild: function(properties) {
    return this.copy(this.treewideProperties, Em.merge(properties, {
      parent: this,
      validReplacement: this._validReplacementForNode()
    }));
  },
  _createFirstChild: function(properties) {
    return this._createChild(Em.merge(properties, {
      leftSibling: null
    }));
  },
  _createSibling: function(properties) {
    return this.copy(this.treewideProperties.concat(['parent']), Em.merge(properties, {
      validReplacement: this._validReplacementForNode()
    }));
  },
  _createLeftSibling: function(properties) {
    return this._createSibling(Em.merge(properties, {
      rightSibling: this
    }));
  },
  _createRightSibling: function(properties) {
    return this._createSibling(Em.merge(properties, {
      leftSibling: this
    }));
  }
});


TreeSearch.TreeCursor.reopen({
  isRightOrTopOfCursor: function(cursor) {
    return ['right', 'top'].contains(this.determinePositionAgainstCursor(cursor));
  },
  isLeftOrTopOfCursor: function(cursor) {
    return ['left', 'top'].contains(this.determinePositionAgainstCursor(cursor));
  },
  determinePositionAgainstCursor: function(cursor) {
    var a, ancestors, b;
    if ((!cursor) || this.equals(cursor)) {
      return void 0;
    } else if (ancestors = this.findClosestSiblingAncestorsWithCursor(cursor)) {
      a = ancestors[0], b = ancestors[1];
      return a != null ? a.determinePositionAgainstSibling(b) : void 0;
    } else {
      return this.determinePositionAgainstMemberOfBranch(cursor);
    }
  },
  determinePositionAgainstSibling: function(sibling) {
    var candidate, direction, _i, _len, _ref;
    if (!sibling) {
      return void 0;
    }
    _ref = ['left', 'right'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      direction = _ref[_i];
      while (candidate = (candidate != null ? candidate : this).get("" + (direction.opposite()) + "Sibling")) {
        if (candidate.equals(sibling)) {
          return direction;
        }
      }
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
    if (!((this.equals(ancestor)) || cursor.equals(ancestor))) {
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
  }).property('parent.rightSibling', 'parent.upwardSuccessor').meta({
    cursorSpecific: true
  }),
  upwardPredecessor: (function() {
    var _ref;
    return (_ref = this.get('parent.leftSibling')) != null ? _ref : this.get('parent.upwardPredecessor');
  }).property('parent.leftSibling', 'parent.upwardPredecessor').meta({
    cursorSpecific: true
  }),
  successor: (function() {
    var _ref, _ref1;
    return (_ref = (_ref1 = this.get('firstChild')) != null ? _ref1 : this.get('rightSibling')) != null ? _ref : this.get('upwardSuccessor');
  }).property('firstChild', 'rightSibling', 'upwardSuccessor').meta({
    cursorSpecific: true
  }),
  predecessor: (function() {
    var _ref, _ref1;
    return (_ref = (_ref1 = this.get('lastChild')) != null ? _ref1 : this.get('leftSibling')) != null ? _ref : this.get('upwardPredecessor');
  }).property('lastChild', 'leftSibling', 'upwardPredecessor').meta({
    cursorSpecific: true
  }),
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
  }).property().volatile().meta({
    cursorSpecific: true
  }),
  predecessorAtSameDepth: (function() {
    return this.findPredecessorAtDepth(this.get('depth'));
  }).property().volatile().meta({
    cursorSpecific: true
  }),
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
  }).property('successor', 'successor.isLeaf', 'successor.leafSuccessor').meta({
    cursorSpecific: true
  }),
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
  }).property('predecessor', 'predecessor.isLeaf', 'predecessor.leafSuccessor').meta({
    cursorSpecific: true
  })
});


TreeSearch.TreeCursor.Validator = Ember.Object.extend({
  error: void 0,
  validate: void 0,
  shouldSkipInvalidCursors: false
});


TreeSearch.TreeCursor.reopen({
  addValidation: function(parameters) {
    return this.addValidator(TreeSearch.TreeCursor.Validator.create(parameters));
  },
  addValidator: function(validator) {
    (this.get('_validators')).push(validator);
    return this;
  },
  validReplacement: void 0,
  _nearestValidCursor: (function() {
    var failed;
    failed = this.get('_firstFailedValidator');
    if (!failed) {
      return this;
    } else if (failed.get('shouldSkipInvalidCursors')) {
      return this.get('_extractedValidReplacement');
    } else {
      return null;
    }
  }).property(),
  _extractedValidReplacement: (function() {
    var accessor;
    accessor = this.get('validReplacement');
    if ('string' === typeof accessor) {
      return this.get(accessor);
    } else {
      return accessor != null ? accessor.apply(this, []) : void 0;
    }
  }).property('validReplacement'),
  _validators: (function() {
    return [this._validateExistenceOfNode];
  }).property(),
  _validateExistenceOfNode: TreeSearch.TreeCursor.Validator.create({
    validate: function(cursor) {
      return (cursor.node !== void 0) && cursor.node !== null;
    },
    shouldSkipInvalidCursors: false,
    error: "Node does not exist"
  }),
  _firstFailedValidator: (function() {
    var validator, _i, _len, _ref;
    _ref = this.get('_validators');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      validator = _ref[_i];
      if (!validator.validate(this)) {
        return validator;
      }
    }
  }).property(),
  _warnAboutMissingMethods: function() {
    var doesNodeDefineEqualsMethod, node;
    if (this.constructor._didWarnBefore) {
      return;
    }
    node = this.get('node');
    doesNodeDefineEqualsMethod = ('object' !== typeof node) || (('object' === typeof node) && ((node != null ? node.equals : void 0) != null));
    Ember.warn("You have not defined #equals method on the node prototype. Please see documentation for TreeCursor#equals for more information. – " + (this.constructor.toString()), doesNodeDefineEqualsMethod);
    if (!doesNodeDefineEqualsMethod) {
      return this.constructor._didWarnBefore = true;
    }
  }
});


TreeSearch.BFS = {
  getNextCursor: function(cursor, direction, initialCursor) {
    var next;
    if (!cursor) {
      next = initialCursor;
    }
    if (next == null) {
      next = cursor.get("" + direction + "SuccessorAtSameDepth");
    }
    return next != null ? next : next = (function() {
      var leftmost, _ref;
      leftmost = (_ref = cursor.get("" + (direction.opposite()) + "mostSibling")) != null ? _ref : cursor;
      return leftmost != null ? leftmost.get("firstChildFrom" + (direction.opposite().capitalize())) : void 0;
    })();
  }
};

TreeSearch.BFSWithQueue = {
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
};


TreeSearch.DFS = {
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
};


TreeSearch.LeavesOnlySearch = {
  getNextCursor: function(cursor, direction, initialCursor) {
    if ((!cursor) && initialCursor.get('isLeaf')) {
      return initialCursor;
    } else {
      return (cursor != null ? cursor : initialCursor).get("" + direction + "LeafSuccessor");
    }
  }
};


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
    if (this.get('shouldIgnoreInitialNode')) {
      this._getNextNode();
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
    var args, cursor, _ref,
      _this = this;
    args = ['_cursor', 'direction', '_initialCursor', '_searchMeta'];
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
  _initialCursor: (function() {
    return (this.get('cursorClass')).create({
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


TreeSearch.Trimming = Ember.Object.extend().reopenClass({
  trim: function(properties) {
    var trimming;
    trimming = this.create(properties);
    return trimming.perform();
  }
});

TreeSearch.Trimming.reopen({
  leftBoundary: (function(_, newValue, cachedValue) {
    if (arguments.length === 1) {
      return cachedValue;
    } else {
      return this._extractCursorFrom(newValue);
    }
  }).property(),
  everythingLeftOfBranch: Ember.computed.alias('leftBoundary'),
  rightBoundary: (function(_, newValue, cachedValue) {
    if (arguments.length === 1) {
      return cachedValue;
    } else {
      return this._extractCursorFrom(newValue);
    }
  }).property(),
  everythingRightOfBranch: Ember.computed.alias('rightBoundary'),
  perform: function() {
    var _this = this;
    return (this.get('_root')).addValidation({
      validate: function(cursor) {
        return _this._isCursorInsideBoundaries(cursor);
      },
      shouldSkipInvalidCursors: true,
      error: "Node has been trimmed away. " + (this.toString())
    });
  },
  _root: (function() {
    var boundary, root, _ref;
    boundary = (_ref = this.get('leftBoundary')) != null ? _ref : this.get('rightBoundary');
    root = boundary.get('root');
    return root.copy([]);
  }).property(),
  _isCursorInsideBoundaries: function(cursor) {
    var positionAgainstLeftBoundary, positionAgainstRightBoundary;
    positionAgainstLeftBoundary = cursor.determinePositionAgainstCursor(this.get('leftBoundary'));
    positionAgainstRightBoundary = cursor.determinePositionAgainstCursor(this.get('rightBoundary'));
    return (('right' === positionAgainstLeftBoundary) && ('left' === positionAgainstRightBoundary)) || (['top', void 0].contains(positionAgainstLeftBoundary)) || (['top', void 0].contains(positionAgainstRightBoundary));
  },
  _extractCursorFrom: function(nodeOrCursor) {
    var node, _ref;
    if (nodeOrCursor instanceof TreeSearch.TreeCursor) {
      return nodeOrCursor;
    } else {
      node = nodeOrCursor;
      return (_ref = node.get('cursor')) != null ? _ref : node.cursor;
    }
  }
});
