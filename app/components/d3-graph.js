import Ember from 'ember';
var d3 = window.d3;

import SessionMixin from 'gistr/mixins/session';


export default Ember.Component.extend(SessionMixin, {
  tagName: 'div',
  classNames: ['graph'],
  classNameBindings: ['list:graph-list:graph-detail'],

  /*
   * Drawing
   */
  resizeEvent: function() {
    var name = 'resize.d3-graph-', tree = this.get('tree');
    name += this.get('list') ? 'list-' : 'detail-';
    name += `tree-${tree.id}`;
    return name;
  }.property('list', 'tree'),
  resizeT0: null,
  initDrawing: function() {
    var self = this,
        element = this.get('element'),
        $element = Ember.$(element);

    var width = $element.width(),
        height = $element.height(),
        svg = d3.select(element).append("svg");

    Ember.$(window).on(this.get('resizeEvent'), function() {
      if(self.get('resizeT0')) {
        Ember.run.cancel(self.get('resizeT0'));
      }
      self.set('resizeT0', Ember.run.later(null, function() {
        var width = $element.width(),
            height = $element.height();
        self.draw(svg, width, height);
      }, 200));
    });

    this.draw(svg, width, height);
  }.on('didInsertElement'),
  closeDrawing: function() {
    Ember.$(window).off(this.get('resizeEvent'));
  }.on('willDestroyElement'),
  draw: function(svg, width, height) {
    var graph = this.get('tree.graph');

    var force = d3.layout.force()
        .charge(-120)
        .linkDistance(30)
        .size([width, height]);

    svg.attr("width", width)
        .attr("height", height);

    force
        .nodes(graph.nodes)
        .links(graph.links)
        .start();

    var link = svg.selectAll(".link")
        .data(graph.links)
      .enter().append("line")
        .attr("class", "link")
        .style("stroke-width", 1);

    var node = svg.selectAll(".node")
        .data(graph.nodes)
      .enter().append("circle")
        .attr("class", "node")
        .attr("r", 5)
        .style("fill", function(d) { return d.isRoot ? "#900" : "#ccc"; })
        .call(force.drag);

    node.append("title")
        .text(function(d) { return `${d.sentenceId}`; });

    var x = function(d) { return d.isRoot ? width/5 : d.x; },
        y = function(d) { return d.isRoot ? height/2 : d.y; };

    force.on("tick", function() {
      link.attr("x1", function(d) { return x(d.source); })
          .attr("y1", function(d) { return y(d.source); })
          .attr("x2", function(d) { return x(d.target); })
          .attr("y2", function(d) { return y(d.target); });

      node.attr("cx", function(d) { return x(d); })
          .attr("cy", function(d) { return y(d); });
    });

    // Find own sentence
    var profile = this.get('currentProfile');
    this.get('tree.sentences').then(function(sentences) {
      var sentenceProfileMap = {};
      sentences.forEach(function(sentence) {
        sentenceProfileMap[sentence.get('id')] = sentence.get('profile');
      });
      return Ember.RSVP.hash(sentenceProfileMap);
    }).then(function(sentenceProfileMap) {
      console.dir(sentenceProfileMap);
      console.dir(profile);
      node.style("stroke", function(d) {
        return sentenceProfileMap[d.sentenceId] === profile ? "#f60" : "#fff";
      });
    });
  }
});
