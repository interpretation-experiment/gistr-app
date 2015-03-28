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
  maxTreeDepth: 10,   // FIXME: move this to server meta
  maxTreeBreadth: 5,  // FIXME: move this to server meta
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
        depth = this.get('tree.depth'),
        breadth = this.get('tree.breadth'),
        element = this.get('element'),
        $element = Ember.$(element),
        $parent = Ember.$(this.get('element')).parent();

    var pwidth = $parent.width(),
        pheight = $parent.height();

    var scale = this.get("overview") ? 0.5 : 1,
        wScale = (depth + 1) / (this.get('maxTreeDepth') + 1),
        hScale = (breadth + 1) / (this.get('maxTreeBreadth') + 1);

    $element.css("height", pheight * hScale);

    var margin = {
      top: pheight / ((this.get('maxTreeBreadth') + 1) * 2),
      right: pwidth / ((this.get('maxTreeDepth') + 1) * 2),
      bottom: pheight / ((this.get('maxTreeBreadth') + 1) * 2),
      left: pwidth / ((this.get('maxTreeDepth') + 1) * 2)
    };

    var width = pwidth * wScale - margin.left - margin.right,
        height = pheight * hScale - margin.top - margin.bottom;

    var svg = d3.select(element).append("svg");

    var g = svg.attr("width", pwidth)
        .attr("height", pheight * hScale)
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + "), scale(" + scale + ")");

    Ember.$(window).on(this.get('resizeEvent'), function() {
      if(self.get('resizeT0')) {
        Ember.run.cancel(self.get('resizeT0'));
      }
      self.set('resizeT0', Ember.run.later(null, function() {
        pwidth = $parent.width();
        var width = pwidth * wScale - margin.left - margin.right,
            height = pheight * hScale - margin.top - margin.bottom;

        svg.attr("width", pwidth)
            .attr("height", pheight * hScale);

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
        .size([height, width])  // inverted height/width to have a horizontal tree
        .sort(function(a, b) {
      // Proxy creation order by sentenceId
      return a.sentenceId - b.sentenceId;
    });

    var layoutNodes = layout.nodes(graph.root),
        layoutLinks = layout.links(layoutNodes);

    var diagonal = d3.svg.diagonal()
        .projection(function(d) { return [d.y, d.x]; });

    var link = g.selectAll(".link")
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

    if (this.get('detail')) {
      this.numberSentences(node);
      this.styleLinks(link);
      this.markOwnSentences(node);
      this.setMouseListeners(node);
    }
  },
  styleLinks: function(link) {
    return this.get('tree.sentences').then(function(sentences) {
      var sentenceMap = {};
      sentences.forEach(function(sentence) {
        sentenceMap[sentence.get('id')] = sentence;
      });
      link.attr("stroke-dasharray", function(d) {
        var source = sentenceMap[d.source.sentenceId],
            target = sentenceMap[d.target.sentenceId];
        return source.get('text').localeCompare(target.get('text')) == 0 ? "3px" : "0";
      });
    });
  },
  numberSentences: function(node) {
    node.append("text")
        .attr("dx", 0)
        .attr("dy", "-1.2em")
        .text(function(d) { return `${d.sentenceId}`; });
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
