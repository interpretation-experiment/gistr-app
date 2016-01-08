/* jshint node: true */

module.exports = {
  //development: {
    //store: {
      //type: 'redis', // the default store is 'redis'
      //host: 'localhost',
      //port: 6379
    //},
    //assets: {
      //type: 's3', // default asset-adapter is 's3'
      //gzip: false, // if undefined or set to true, files are gziped
      //gzipExtensions: ['js', 'css', 'svg'], // if undefined, js, css & svg files are gziped
      //accessKeyId: '<your-access-key-goes-here>',
      //secretAccessKey: process.env['AWS_ACCESS_KEY'],
      //bucket: '<your-bucket-name>'
    //}
  //},

  staging: {
    buildEnv: 'staging',
    store: {
      type: 'ssh',
      remoteDir: '/home/gistr/next/gistr-revisions',
      host: 'eauchat.org',
      port: 10022,
      username: 'gistr',
      agent: process.env['SSH_AUTH_SOCK']
    },
    assets: {
      accessKeyId: 'AKIAJBII74XCBJSSFWLA',
      secretAccessKey: process.env['AWS_ACCESS_KEY'],
      bucket: 'gistr'
    }
  },

  production: {
    store: {
      type: 'ssh',
      remoteDir: '/home/gistr/root/gistr-revisions',
      host: 'eauchat.org',
      port: 10022,
      username: 'gistr',
      agent: process.env['SSH_AUTH_SOCK']
    },
    assets: {
      accessKeyId: 'AKIAJBII74XCBJSSFWLA',
      secretAccessKey: process.env['AWS_ACCESS_KEY'],
      bucket: 'gistr'
    }
  }
}
