import Ember from 'ember';
import DS from 'ember-data';
import nx from 'npm:jsnetworkx';


export default DS.Model.extend({
  root: DS.belongsTo('sentence'),  // not async since it's nested
  sentences: DS.hasMany('sentence', { async: true }),
  sentencesCount: DS.attr('number'),
  profiles: DS.hasMany('profile', { async: true }),
  networkEdges: DS.attr('array'),
  branchesCount: DS.attr('number'),
  shortestBranchDepth: DS.attr('number'),

  /*
   * Unused properties
   */
  url: DS.attr('string'),

  /*
   * Computed properties
   */
  shaping: Ember.inject.service(),
  graph: function() {
    var dNodes = {},
        links = [],
        networkEdges = this.get('networkEdges');

    if (networkEdges.length === 0) {
      dNodes[this.get('root.id')] = { sentenceId: this.get('root.id') };
    } else {
      networkEdges.map(function(edge) {
        if (!(edge.source in dNodes)) {
          dNodes[edge.source] = { sentenceId: edge.source };
        }
        if (!(edge.target in dNodes)) {
          dNodes[edge.target] = { sentenceId: edge.target };
        }

        var parent = dNodes[edge.source],
            child = dNodes[edge.target];

        if (parent.children) {
          parent.children.push(child);
        } else {
          parent.children = [child];
        }

        links.push({
          source: parent,
          target: child
        });
      });
    }

    return {
      nodes: Object.keys(dNodes).map(function(k) { return dNodes[k]; }),
      links: links,
      root: dNodes[this.get('root.id')]
    };
  }.property('networkEdges'),
  depth: function() {
    var graph = this.get('graph');

    var maxDepth = function(node) {
      if (node.children) {
        var depths = node.children.map(function(child) {
          return 1 + maxDepth(child);
        });
        return Math.max.apply(null, depths);
      } else {
        return 0;
      }
    };

    return maxDepth(graph.root);
  }.property('graph'),
  breadth: function() {
    var graph = this.get('graph');

    var maxBreadth = function(node) {
      if (node.children) {
        return node.children.reduce(function(currentBreadth, child) {
          return currentBreadth + maxBreadth(child);
        }, 0) + node.children.length - 1;
      } else {
        return 0;
      }
    };

    return maxBreadth(graph.root);
  }.property('graph'),
  tips: function() {
    var networkEdges = this.get('networkEdges'),
        graph = this.get('graph'),
        targetBranchDepth = this.get('shaping.targetBranchDepth');

    // No children under the root? Return fast
    if (networkEdges.length === 0) {
      return { allTips: [], underTips: [], overflownTips: [] };
    }

    var nxGraph = nx.DiGraph(networkEdges.map(function(edge) {
      return [edge.source, edge.target];
    }));
    var allTipsDepths = graph.root.children
        .map(function(child) { return child.sentenceId; })
        .map(function(head) {
          return nx.single_source_shortest_path_length(nxGraph, head).w;
        })
        .map(function(nodeToDepth) {
          var nodes = Object.keys(nodeToDepth),
              depthToNodes = {},
              node, depth;

          // Get all nodes at a given depth, for each depth
          for (var i = 0; i < nodes.length; i++) {
            node = nodes[i];
            depth = nodeToDepth[node];
            if (!(depth in depthToNodes)) { depthToNodes[depth] = []; }
            depthToNodes[depth].push(node);
          }

          var maxDepth = Math.max.apply(null, Object.keys(depthToNodes));
          return { depth: maxDepth + 1, nodes: depthToNodes[maxDepth] };
        });

    var allTips = [],
        underTips = [],
        overflownTips = [];
    allTipsDepths.forEach(function(tips) {
      allTips.push(tips.nodes);
      if (tips.depth < targetBranchDepth) {
        underTips.push(tips.nodes);
      } else {
        overflownTips.push(tips.nodes);
      }
    });

    return { allTips: allTips, underTips: underTips, overflownTips: overflownTips };
  }.property('networkEdges', 'graph')
});
