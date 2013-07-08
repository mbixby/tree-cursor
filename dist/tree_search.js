(function() {
  var TreeSearch;

  window.TreeSearch = TreeSearch = Ember.Object.extend();


(function() {
  TreeSearch.reopenClass({
    createAndPerform: function() {
      var search;
      search = this.create.apply(this, arguments);
      return search.perform();
    }
  });

  TreeSearch.reopen({
    rootNode: null,
    initialNode: Ember.alias('rootNode'),
    method: TreeSearch.BFS,
    shouldAcceptNode: function(node) {
      return true;
    },
    shouldYieldSingleResult: false,
    shouldIgnoreRootNode: true,
    direction: 'right',
    shouldStopSearch: function(node) {
      return false;
    },
    perform: function() {
      var candidate, result;
      this._pickAlgorithm();
      result = [];
      while (candidate = this.getNextNode()) {
        if (this.shouldStopSearch(candidate)) {
          break;
        }
        if (this.shouldSkipNode(candidate)) {
          continue;
        }
        if (this.shouldAcceptNode(candidate)) {
          result.push(candidate);
          if (this.get('shouldYieldSingleResult')) {
            break;
          }
        }
      }
      return this.processResult(result);
    },
    processResult: function(result) {
      var _ref;
      if (this.get('shouldYieldSingleResult')) {
        return (_ref = result[0]) != null ? _ref : null;
      } else if (Ember.isEmpty(result)) {
        return null;
      } else {
        return result;
      }
    },
    cursorFactoryClass: TreeCursorFactory,
    getNextNode: Ember.K(),
    _pickAlgorithm: function() {
      var algorithm;
      algorithm = this.get('method');
      return algorithm.apply(this);
    },
    _treeCursor: (function() {
      return (this.get('cursorFactoryClass')).createCursor({
        initialNode: this.get('rootNode')
      });
    }).property(),
    _shouldWalkLeft: (function() {
      return (this.get('direction')) === 'left';
    }).property('direction')
  });

}).call(this);


(function() {
  TreeSearch.BFS = Ember.Mixin.create({
    getNextNode: function() {
      var next;
      next = this.get('_shouldWalkLeft') ? (this.get('_treeCursor')).leftAtLevel() : (this.get('_treeCursor')).rightAtLevel();
      if (next == null) {
        next = this.set('_firstNodeAtCurrentLevel', (this.getWithDefault('_firstNodeAtCurrentLevel', this.get('_treeCursor'))).down());
      }
      return next.node;
    }
  });

  TreeSearch.BFSWithQueue = Ember.Mixin.create({
    getNextNode: function() {
      var next, queue, x, _i, _len, _ref;
      queue = this.getWithDefault('_queue', [this.get('_treeCursor')]);
      next = queue.shift();
      _ref = next.down();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        x = _ref[_i];
        queue.push(x);
      }
      this.set('queue', queue);
      return next.node;
    }
  });

}).call(this);


(function() {
  TreeSearch.DFS = Ember.Mixin.create({
    getNextNode: function() {
      var next, queue, x, _i, _ref;
      queue = this.getWithDefault('_queue', [this.get('_treeCursor')]);
      next = queue.pop();
      _ref = next.down();
      for (_i = _ref.length - 1; _i >= 0; _i += -1) {
        x = _ref[_i];
        queue.push(x);
      }
      this.set('queue', queue);
      return next.node;
    }
  });

}).call(this);


(function() {
  TreeSearch.LeavesOnlySearch = Ember.Mixin.create({
    getNextNode: function() {
      var successorOf;
      if (this.get('_shouldWalkLeft')) {
        successorOf = function(cursor) {
          return cursor.pred();
        };
      } else {
        successorOf = function(cursor) {
          return cursor.succ();
        };
      }
      return successorOf(this.get('_treeCursor'));
    }
  });

}).call(this);


(function() {
  TreeSearch.SameDepthSearch = Ember.Mixin.create({
    getNextNode: function() {
      var next;
      return next = this.get('_shouldWalkLeft') ? (this.get('_treeCursor')).leftAtLevel() : (this.get('_treeCursor')).rightAtLevel();
    }
  });

}).call(this);


}).call(this);
