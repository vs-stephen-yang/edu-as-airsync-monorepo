// This function works with any scheme, not just http and https,
// thereby overcoming the limitation of Uri.origin.
String getUriOrigin(Uri uri) {
  return '${uri.scheme}://${uri.host}:${uri.port}';
}
