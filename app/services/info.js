import Ember from 'ember';


export default Ember.Service.extend({
  infos: {},
  separator: /:/,
  knownInfos: {
    play: [
      'exp.training:lifecycle:just-completed-trials',
      'exp.doing:lifecycle:just-completed-trials',
      'all:state:sentences-empty',
      'playing:gain:new-credit',
      'exp.doing:rhythm:break',
      'playing:rhythm:diff-break',
      'playing:rhythm:exploration-break'
    ]
  },
  split: function(info) {
    var parts = info.split(this.get('separator'));
    return {
      state: parts[0],
      type: parts[1],
      name:parts[2]
    };
  },
  pushInfo: function(route, info) {
    console.log('push info [' + route + ']' + info);

    var infos = this.get('infos'),
        knownInfos = this.get('knownInfos');

    if (!(route in knownInfos) || knownInfos[route].indexOf(info) === -1) {
      throw new Error("Asked to push unknown info [" +
                      route + "]" + info);
    }

    if (!(route in infos)) { infos[route] = []; }
    if (infos[route].indexOf(info) === -1) { infos[route].push(info); }

    console.log('infos[' + route + '] is now [' + this.get('infos')[route].join(", ") + ']');
  },
  getInfos: function(route, params) {
    if (Ember.isNone(params)) {
      return this.getWithDefault('infos.' + route, []);
    } else {
      var self = this,
          infos = this.getWithDefault('infos.' + route, []);

      var optIncludes = function(part, param) {
        return part.includes(param) || Ember.isNone(param);
      };

      return infos.filter(function(info) {
        var parts = self.split(info);
        return (optIncludes(parts.state, params.state) &&
                optIncludes(parts.type, params.type) &&
                optIncludes(parts.name, params.name));
      });
    }
  },
  resetInfos: function(route) {
    console.log('reset infos[' + route + ']');
    delete this.get('infos')[route];
  }
});
