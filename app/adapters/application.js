import config from 'gistr/config/environment';
import DS from 'ember-data';
import DRFAdapter from './drf';

var Adapter;

if (config.environment === 'test') {
  Adapter = DS.FixtureAdapter.extend();
} else {
  Adapter = DRFAdapter;
}

export default Adapter;
