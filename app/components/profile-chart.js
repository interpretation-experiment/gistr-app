import Ember from 'ember';

var d3 = window.d3;


export default Ember.Component.extend({
  tagName: 'div',
  classNames: ['profile-chart'],

  /*
   * Input data
   */
  binsCount: 20,        // optional
  xtitle: null,         // required
  profileValue: null,   // required
  values: null,         // required

  /*
   * Resizing
   */
  chart: null,
  aspectRatio: null,
  resizeEvent: function() {
    // TODO: adapt when we have multiple charts
    return `resize.profile-chart-${Ember.String.camelize(this.get('xtitle'))}`;
  }.property(),
  sizeChart: function() {
    var chart = this.get('chart'),
        targetWidth = chart.parent().width();
    chart.attr('width', targetWidth);
    chart.attr('height', targetWidth / this.get('aspectRatio'));
  },

  /*
   * Data preparation
   */
  binning: function() {
    var middles = this.get('x').ticks(this.get('binsCount')),
        binSize = middles[1] - middles[0],
        bins = middles.map(function(middle) { return middle - binSize / 2; });

    // Add the last right limit
    bins.push(middles[middles.length - 1] + binSize / 2);

    return Ember.Object.create({ bins: bins, middles: middles });
  }.property('values', 'binsCount'),
  hist: function() {
    var values = this.get('values'),
        bins = this.get('binning.bins');
    return d3.layout.histogram().bins(bins)(values);
  }.property('values', 'binning'),
  data: function() {
    var hist = this.get('hist'),
        middles = this.get('binning.middles'),
        data = [];

    for (var i = 0; i < hist.length; i++) {
      data.push({ values: hist[i], middle: middles[i] });
    }

    return data;
  }.property('hist', 'binning'),
  x: function() {
    return d3.scale.linear().domain(d3.extent(this.get('values')));
  }.property('values'),
  y: function() {
    return d3.scale.linear()
      .domain([0, d3.max(this.get('hist'), function(d) { return d.length; })]);
  }.property('hist'),

  /*
   * Initialize and close drawing
   */
  initDrawing: function() {
    var self = this,
        element = this.get('element');

    var svgWidth  = 196,
        svgHeight = 100,
        margin = { top: 15, right: 5, bottom: 30, left: 5 },
        chartWidth  = svgWidth  - margin.left - margin.right,
        chartHeight = svgHeight - margin.top  - margin.bottom;

    var x = this.get('x').range([0, chartWidth]),
        y = this.get('y').range([chartHeight, 0]);

    var xAxis = d3.svg.axis().scale(x).orient('bottom')
                  .ticks(10).innerTickSize(3).outerTickSize(0).tickPadding(5),
        yAxis = d3.svg.axis().scale(y).orient('left')
                  .ticks(0).innerTickSize(3).outerTickSize(0).tickPadding(5);

    var svg = d3.select(element).append("svg")
      .attr('width',  svgWidth)
      .attr('height', svgHeight)
      .attr('viewBox', `0 0 ${svgWidth} ${svgHeight}`)
      .attr('preserveAspectRatio', 'xMidYMid')
      .append('g')
        .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

    // Size the chart for the first time, and set the resize event handler
    this.set('chart', Ember.$(element).find('svg'));
    this.set('aspectRatio', svgWidth / svgHeight);
    this.sizeChart();
    Ember.$(window).on(this.get('resizeEvent'), function() {
      self.sizeChart();
    });

    // Draw the chart
    this.drawPaths(svg, x, y);
    this.addAxesAndLegend(svg, xAxis, yAxis, margin, chartWidth, chartHeight);
  }.on('didInsertElement'),

  closeDrawing: function() {
    Ember.$(window).off(this.get('resizeEvent'));
  }.on('willDestroyElement'),

  drawPaths: function(svg, x, y) {
    /*
     * Distribution area and line
     */
    var area = d3.svg.area()
      .interpolate('basis')
      .x(function(d) { return x(d.middle); })
      .y0(y(0))
      .y1(function(d) { return y(d.values.length); });

    var line = d3.svg.line()
      .interpolate('basis')
      .x(function(d) { return x(d.middle); })
      .y(function(d) { return y(d.values.length); });

    svg.datum(this.get('data'));

    svg.append('path')
      .attr('class', 'area')
      .attr('d', area);

    svg.append('path')
      .attr('class', 'line')
      .attr('d', line);

    /*
     * Profile line and dot
     */
    var profileLine = d3.svg.line()
      .interpolate('basis')
      .x(x(this.get('profileValue')))
      .y(y);

    svg.append('path').datum([0, y.domain()[1]])
      .attr('class', 'profile')
      .attr('d', profileLine);

    svg.append('circle')
      .attr('class', 'profile')
      .attr('r', 5)
      .attr('cx', x(this.get('profileValue')))
      .attr('cy', y(y.domain()[1]));
  },

  addAxesAndLegend: function(svg, xAxis, yAxis, margin, chartWidth, chartHeight) {
    var axes = svg.append('g')
      .attr('clip-path', 'url(#axes-clip)');

    axes.append('g')
      .attr('class', 'x axis')
      .attr('transform', 'translate(0,' + chartHeight + ')')
      .call(xAxis)
      .append('text')
        .attr('x', chartWidth / 2)
        .attr('y', xAxis.innerTickSize() + xAxis.tickPadding())
        .attr('dy', '2em')
        .attr('text-anchor', 'middle')
        .attr('class', 'xtitle')
        .text(this.get('xtitle'));

    //axes.append('g')
      //.attr('class', 'y axis')
      //.call(yAxis)
  },
});
