var url = new URL(window.location.href);
var base = url.hostname.split('.').slice(-2).join('.');
url.hostname = 'wt1.local.app.' + base;
url.port = '';
window.open(url.href, '_blank');
