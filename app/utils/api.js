import config from 'gistr/config/environment';

export default function(url) {
  return config.APP.API_HOST + '/' + config.APP.API_NAMESPACE + url;
}
