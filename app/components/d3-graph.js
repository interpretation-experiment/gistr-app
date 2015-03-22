import Ember from 'ember';
var d3 = window.d3;


export default Ember.Component.extend({
  tagName: 'div',
  classNames: ['graph-large'],

  draw: function() {
    var graph = this.get('tree.graph');

    var width = 400, height = 200;

    var force = d3.layout.force()
        .charge(-120)
        .linkDistance(30)
        .size([width, height]);

    var svg = d3.select(this.get('element')).append("svg")
        .attr("width", width)
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

    force.on("tick", function() {
      link.attr("x1", function(d) { return d.source.x; })
          .attr("y1", function(d) { return d.source.y; })
          .attr("x2", function(d) { return d.target.x; })
          .attr("y2", function(d) { return d.target.y; });

      node.attr("cx", function(d) { return d.x; })
          .attr("cy", function(d) { return d.y; });
    });
  }.on('didInsertElement')
});
