var url = new URL(window.location.href);
var pathParts = url.pathname.split('/');
if (pathParts.length >= 3 && /^\d+$/.test(pathParts[2])) {
  pathParts[2] = '99260771';
  url.pathname = pathParts.join('/');
  window.open(url.toString(), "_blank");
}
