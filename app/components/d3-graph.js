import Ember from 'ember';
var d3 = window.d3;

import SessionMixin from 'gistr/mixins/session';


export default Ember.Component.extend(SessionMixin, {
  /*
   * Component options
   */
  tagName: 'div',
  classNameBindings: ['overview:graph-overview:graph-detail'],

  /*
   * Utility properties
   */
  detail: Ember.computed.not('overview'),

  /*
   * Resizing
   */
  resizeEvent: function() {
    var name = 'resize.d3-graph-', tree = this.get('tree');
    name += this.get('overview') ? 'overview-' : 'detail-';
    name += `tree-${tree.id}`;
    return name;
  }.property('overview', 'tree'),
  resizeT0: null,

  /*
   * Initialize and close drawing
   */
  initDrawing: function() {
    var self = this,
        element = this.get('element'),
        $parent = Ember.$(this.get('element')).parent(),
        scale = this.get("overview") ? 0.5 : 1,
        margin = { top: 20 * scale, right: 20 * scale, bottom: 20 * scale, left: 20 * scale },
        width = $parent.width() - margin.left - margin.right,
        height = $parent.height() - margin.top - margin.bottom,
        svg = d3.select(element).append("svg");

    console.log(width, height);

    var g = svg.attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + "), scale(" + scale + ")");

    Ember.$(window).on(this.get('resizeEvent'), function() {
      if(self.get('resizeT0')) {
        Ember.run.cancel(self.get('resizeT0'));
      }
      self.set('resizeT0', Ember.run.later(null, function() {
        var width = $parent.width() - margin.left - margin.right,
            height = $parent.height() - margin.top - margin.bottom;

        svg.attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom);

        self.draw(g, width / scale, height / scale);
      }, 200));
    });

    this.draw(g, width / scale, height / scale);
  }.on('didInsertElement'),
  closeDrawing: function() {
    Ember.$(window).off(this.get('resizeEvent'));
  }.on('willDestroyElement'),

  /*
   * Actual drawing core
   */
  draw: function(g, width, height) {
    var graph = this.get('tree.graph');

    var layout = d3.layout.tree()
        .size([height, width]);  // inverted height/width to have a horizontal tree

    var layoutNodes = layout.nodes(graph.root),
        layoutLinks = layout.links(layoutNodes);

    var diagonal = d3.svg.diagonal()
        .projection(function(d) { return [d.y, d.x]; });

    g.selectAll(".link")
        .data(layoutLinks)
        .attr("d", diagonal)
      .enter().append("path")
        .attr("class", "link")
        .attr("d", diagonal);

    var node = g.selectAll(".node")
        .data(layoutNodes)
        .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; })
      .enter().append("g")
        .attr("class", "node")
        .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

    node.append("circle")
        .attr("r", 8)
        .style("fill", function(d) { return Ember.isNone(d.parent) ? "#900" : "#999"; });

    node.append("text")
        .attr("dx", 0)
        .attr("dy", "-1em")
        .text(function(d) { return `${d.sentenceId}`; });

    if (this.get('detail')) {
      this.markOwnSentences(node);
      this.setMouseListeners(node);
    }
  },
  markOwnSentences: function(node) {
    // Find own sentences
    var profile = this.get('currentProfile');
    return this.get('tree.sentences').then(function(sentences) {
      var sentenceProfileMap = {};
      sentences.forEach(function(sentence) {
        sentenceProfileMap[sentence.get('id')] = sentence.get('profile');
      });
      return Ember.RSVP.hash(sentenceProfileMap);
    }).then(function(sentenceProfileMap) {
      node.selectAll("circle")
          .style("stroke", function(d) {
        return sentenceProfileMap[d.sentenceId] === profile ? "#f60" : "#fff";
      });
    });
  },
  setMouseListeners: function(node) {
    var self = this;
    // Set event listeners
    node.selectAll("circle")
        .on("mouseover", function(d) {
      d3.select(this).attr("r", 10);
      self.sendAction("hover", self.store.find('sentence', d.sentenceId));
    })
        .on("mouseout", function(/*d*/) {
      d3.select(this).attr("r", 8);
      self.sendAction("hover", null);
    });
  }
});
