import Ember from 'ember';


export default Ember.Mixin.create({
  resetController: function() {
    this.get('controller').send('reset');
  }.on('deactivate')
});
