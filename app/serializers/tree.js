import DS from 'ember-data';

import DRFSerializer from './drf';


export default DRFSerializer.extend(DS.EmbeddedRecordsMixin, {
  // 'root' object is embedded
  attrs: {
    root: { embedded: 'always' }
  }
});
