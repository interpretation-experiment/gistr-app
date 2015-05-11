import Ember from 'ember';


export default Ember.Service.extend({
  infos: {},
  separator: /:/,
  knownInfos: {
    play: {
      infos: [
        'exp.training:lifecycle:just-completed-trials',
        'exp.doing:lifecycle:just-completed-trials',
        'all:state:sentences-empty',
        'playing:state:new-credit',
        'exp.doing:rhythm:break',
        'playing:rhythm:diff-break',
        'playing:rhythm:exploration-break'
      ],
      push: function(infos, info) {
        var self = this;
        var isLifecycle = function(item) { return self.split(item).type.includes("lifecycle"); };
        var isRhythm = function(item) { return self.split(item).type.includes("rhythm"); };

        var infoIsLifecycle = isLifecycle(info),
            infoIsRhythm = isRhythm(info),
            infosHasLifecycle = infos.any(isLifecycle),
            infosHasRhythm = infos.any(isRhythm);

        if ((infosHasLifecycle && infoIsRhythm) || (infosHasRhythm && infoIsLifecycle)) {
          throw new Error("Tried to combine rhythm and lifecycle infos in play route, " +
                          "that's not allowed");
        }

        infos.push(info);
      }
    }
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

    if (!(route in knownInfos) || knownInfos[route].infos.indexOf(info) === -1) {
      throw new Error("Asked to push unknown info [" +
                      route + "]" + info);
    }

    var push = Ember.run.bind(this, knownInfos[route].push);
    if (!(route in infos)) { infos[route] = []; }
    if (infos[route].indexOf(info) === -1) { push(infos[route], info); }

    console.log('infos[' + route + '] is now [' + this.get('infos')[route].join(", ") + ']');
  },
  getInfos: function(route) {
    return this.getWithDefault('infos.' + route, []);
  },
  resetInfos: function(route) {
    console.log('reset infos[' + route + ']');
    delete this.get('infos')[route];
  }
});
