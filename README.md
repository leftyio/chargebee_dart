# chargebee_dart

A Dart wrapper for the Chargebee iframe API
## Usage

A simple usage example:

```dart
import 'package:chargebee_dart/chargebee_dart.dart';

main() async {
  final loader = await ChargeBee.embed(url, siteName);
  loader.load();
  loader.onAddIframe.then((iframe) {});
  loader.onCancel.then((iframe) {});
  loader.onSuccess.then((iframe) {});
  loader.onLoad.then((dimensions) {
    // dimensions.iframe
    // dimensions.width
    // dimensions.height
  });
  resizeIframeSubscription = _loader.onResize.listen((dimensions) {
    // dimensions.iframe
    // dimensions.width
    // dimensions.height
  });

  ...

  // when done
  loader.dispose();
  resizeIframeSubscription.cancel();
}
```
