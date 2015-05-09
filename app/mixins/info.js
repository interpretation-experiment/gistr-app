import Ember from 'ember';


export default Ember.Mixin.create({
  infos: [],
  knownInfos: Ember.required(),
  pushInfo: function(info) {
    console.log('[push info] ' + info);
    var infos = this.get('infos');
    if (infos.indexOf(info) === -1) {
      this.get('infos').push(info);
    }
    console.log('[infos=] ' + this.get('infos'));
  },
  resetInfos: function() {
    console.log('[reset infos]');
    this.setProperties({
      'infos': []
    });
  }
});
