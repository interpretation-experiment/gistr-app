import Ember from 'ember';
import DS from 'ember-data';


export default DS.Transform.extend({
  serialize: function(deserialized) {
    return Ember.isNone(deserialized) ? {} : deserialized;
  },

  deserialize: function(serialized) {
    return Ember.isNone(serialized) ? {} : serialized;
  }
});
