import DS from 'ember-data';

import DRFSerializer from './drf';


export default DRFSerializer.extend(DS.EmbeddedRecordsMixin, {
  // Embedded fields
  attrs: {
    profile: { embedded: 'always' },
    emails: { embedded: 'always' },
  }
});
