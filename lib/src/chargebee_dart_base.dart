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

  final _onAddIframe = new Completer<IFrameElement>();
  final _onLoad = new Completer<IFrameDimensions>();
  final _onResize = new StreamController<IFrameDimensions>();
  final _onSuccess = new Completer<IFrameElement>();
  final _onCancel = new Completer<IFrameElement>();

  void load() {
    final interop = (Function func) => allowInterop(func);

    _loader.load(new _ChargeBeeLoadOptions(
        addIframe: interop((iframe) => _onAddIframe.complete(iframe)),
        onLoad: interop((iframe, width, height) =>
            _onLoad.complete(new IFrameDimensions(iframe, width, height))),
        onResize: interop((iframe, width, height) =>
            _onResize.add(new IFrameDimensions(iframe, width, height))),
        onSuccess: interop((iframe) => _onSuccess.complete(iframe)),
        onCancel: interop((iframe) => _onCancel.complete(iframe))));
  }

  void dispose() {
    _onResize.close();
  }

  /// This function will be called when iframe is created.
  /// addIframe callback will recieve iframe as parameter.
  /// you can use this iframe to add iframe to your page.
  /// Loading image in container can also be showed in this callback.
  /// Note: visiblity will be none for the iframe at this moment
  Future<IFrameElement> get onAddIframe => _onAddIframe.future;

  /// This function will be called once when iframe is loaded.
  /// Since checkout pages are responsive you need to handle only height.
  Future<IFrameDimensions> get onLoad => _onLoad.future;

  /// This will be triggered when any content of iframe is resized.
  /// if onResize is used [ChargeBeeLoader] must be dispose calling [ChargeBeeLoader.dispose]
  Stream<IFrameDimensions> get onResize => _onResize.stream;

  /// This will be triggered when checkout is complete.
  Future<IFrameElement> get onSuccess => _onSuccess.future;

  /// This will be triggered when user clicks on cancel button.
  Future<IFrameElement> get onCancel => _onCancel.future;
}

class IFrameDimensions {
  final IFrameElement iframe;
  final num height;
  final num width;
  IFrameDimensions(this.iframe, this.width, this.height);
}

final _api = "https://js.chargebee.com/v1/chargebee.js";

ScriptElement _script;

Future<ScriptElement> loadChargeBeeScript() async {
  _script = document.querySelector("#jssdk-chargebee");
  if (_script == null) {
    _script = await loadScript(_api, id: "jssdk-chargebee");
  }
  return _script;
}
