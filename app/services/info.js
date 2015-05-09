import Ember from 'ember';


export default Ember.Service.extend({
  infos: {},
  knownInfos: {
    play: {
      infos: [
        'lifecycle:exp.training:completed-trials',
        'lifecycle:exp.doing:completed-trials',
        'state:all:sentences-empty',
        'state:playing:new-credit',
        'rhythm:exp.doing:break',
        'rhythm:playing:diff-break',
        'rhythm:playing:exploration-break'
      ],
      push: function(infos, info) {
        var isLifecycle = function(item) { return item.includes("lifecycle"); };
        var isRhythm = function(item) { return item.includes("rhythm"); };

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
  pushInfo: function(route, info) {
    console.log('push info [' + route + ']' + info);

    var infos = this.get('infos'),
        knownInfos = this.get('knownInfos');

    if (!(route in knownInfos) || knownInfos[route].infos.indexOf(info) === -1) {
      throw new Error("Asked to push unknown info [" +
                      route + "]" + info);
    }

    var push = knownInfos[route].push;
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
