import DS from 'ember-data';


export default DS.Model.extend({
  root: DS.belongsTo('sentence'),  // not async since it's nested
  sentences: DS.hasMany('sentence', { async: true }),
  profiles: DS.hasMany('profile', { async: true }),
  networkEdges: DS.attr('array'),

  /*
   * Unused properties
   */
  url: DS.attr('string'),

  /*
   * Computed properties
   */
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
  }.property('networkEdges')
});
