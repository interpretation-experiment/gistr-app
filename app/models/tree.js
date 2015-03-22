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
    var dNodes = {}, links = [], networkEdges = this.get('networkEdges');
    if (networkEdges.length === 0) {
      dNodes[this.get('root.id')] = {
        isRoot: true,
        sentenceId: this.get('root.id')
      };
    } else {
      this.get('networkEdges').map(function(edge) {
        if (!(edge.source in dNodes)) {
          dNodes[edge.source] = { sentenceId: edge.source };
        }
        if (!(edge.target in dNodes)) {
          dNodes[edge.target] = { sentenceId: edge.target };
        }
        links.push({
          source: dNodes[edge.source],
          target: dNodes[edge.target]
        });
      });
      dNodes[this.get('root.id')].isRoot = true;
    }

    return {
      nodes: Object.keys(dNodes).map(function(k) { return dNodes[k]; }),
      links: links
    };
  }.property('networkEdges')
});
