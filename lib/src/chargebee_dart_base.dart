@JS()
library chargebee_dart.js;

import "dart:html";
import "dart:async";
import 'package:js/js.dart';
import 'package:dart_browser_loader/dart_browser_loader.dart';

// JS interop
@JS()
class _ChargeBee {
  external _ChargeBeeLoader embed(String url, String siteName);
}

@JS()
class _ChargeBeeLoader {
  external void load(_ChargeBeeLoadOptions options);
}

@JS()
@anonymous
class _ChargeBeeLoadOptions {
  external factory _ChargeBeeLoadOptions(
      {Function addIframe,
      Function onLoad,
      Function onResize,
      Function onSuccess,
      Function onCancel});
}

@JS("ChargeBee")
external _ChargeBee get _chargeBee;

////////////////////////

class ChargeBee {
  static Future<ChargeBeeLoader> embed(String url, String siteName) async {
    await loadChargeBeeScript();
    return new ChargeBeeLoader._(_chargeBee.embed(url, siteName));
  }
}

class ChargeBeeLoader {
  _ChargeBeeLoader _loader;
  ChargeBeeLoader._(this._loader);

  void load(ChargeBeeLoadOptions options) {
    final interop = (Function func) => func != null ? allowInterop(func) : null;

    _loader.load(new _ChargeBeeLoadOptions(
        addIframe: interop(options.addIframe),
        onLoad: interop(options.onLoad),
        onResize: interop(options.onResize),
        onSuccess: interop(options.onSuccess),
        onCancel: interop(options.onCancel)));
  }
}

class ChargeBeeLoadOptions {
  /// This function will be called when iframe is created.
  /// addIframe callback will recieve iframe as parameter.
  /// you can use this iframe to add iframe to your page.
  /// Loading image in container can also be showed in this callback.
  /// Note: visiblity will be none for the iframe at this moment
  final IframeCallback addIframe;

  /// This function will be called once when iframe is loaded.
  /// Since checkout pages are responsive you need to handle only height.
  final IframeDimensionCallback onLoad;

  /// This will be triggered when any content of iframe is resized.
  final IframeDimensionCallback onResize;

  /// This will be triggered when checkout is complete.
  final IframeCallback onSuccess;

  /// This will be triggered when user clicks on cancel button.
  final IframeCallback onCancel;

  ChargeBeeLoadOptions(
      {this.addIframe,
      this.onLoad,
      this.onResize,
      this.onSuccess,
      this.onCancel});
}

typedef void IframeCallback(IFrameElement iframe);
typedef void IframeDimensionCallback(
    IFrameElement iframe, num width, num height);

final _api = "https://js.chargebee.com/v1/chargebee.js";

ScriptElement _script;

Future<ScriptElement> loadChargeBeeScript() async {
  _script = document.querySelector("#jssdk-chargebee");
  if (_script == null) {
    _script = await loadScript(_api, id: "jssdk-chargebee");
  }
  return _script;
}
