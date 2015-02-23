import Ember from 'ember';


export default Ember.Mixin.create({
  deactivate: function() {
    this.get('controller').send('reset');
  }
});
