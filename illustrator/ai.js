// Generated by CoffeeScript 1.8.0
var B, L, R, T, active_ab, active_document_name, active_document_path, array_from_rect, export_jpeg, export_png_24, export_png_24_no_alpha, exports, get_ab_rect, get_pi_rect, index_of_ab, ios_app, rect_from_array, set_ab_rect, set_active_ab;

active_ab = function() {
  return activeDocument.artboards[activeDocument.artboards.getActiveArtboardIndex()];
};

index_of_ab = function(ab) {
  var abs, i, _i, _ref;
  abs = activeDocument.artboards;
  for (i = _i = 0, _ref = abs.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
    if (abs[i].name === ab.name) {
      return i;
    }
  }
  return -1;
};

set_active_ab = function(ab) {
  var index;
  index = index_of_ab(ab);
  if (index >= 0) {
    activeDocument.artboards.setActiveArtboardIndex(index);
  }
};

L = 0;

T = 1;

R = 2;

B = 3;

rect_from_array = function(a) {
  return {
    x: a[L],
    y: a[B],
    w: a[R] - a[L],
    h: a[T] - a[B]
  };
};

array_from_rect = function(r) {
  return [r.x, r.y + r.h, r.x + r.w, r.y];
};

get_ab_rect = function(ab) {
  return rect_from_array(ab.artboardRect);
};

set_ab_rect = function(ab, r) {
  ab.artboardRect = array_from_rect(r);
};

get_pi_rect = function(pi) {
  return rect_from_array(pi.geometricBounds);
};

active_document_path = function() {
  return activeDocument.path.toString().split(/[\\\/]/g).slice(0, -1).join('/').split('%20').join(' ');
};

active_document_name = function() {
  return activeDocument.name.toString().replace(/\..*/g, '');
};

export_png_24 = function(scale, png_path) {
  var file, options;
  options = new ExportOptionsPNG24;
  options.antiAliasing = true;
  options.artBoardClipping = true;
  options.horizontalScale = 100 * scale;
  options.verticalScale = 100 * scale;
  file = new File(png_path);
  activeDocument.exportFile(file, ExportType.PNG24, options);
};

export_png_24_no_alpha = function(scale, png_path) {
  var file, options;
  options = new ExportOptionsPNG24;
  options.antiAliasing = true;
  options.artBoardClipping = true;
  options.transparency = false;
  options.horizontalScale = 100 * scale;
  options.verticalScale = 100 * scale;
  file = new File(png_path);
  activeDocument.exportFile(file, ExportType.PNG24, options);
};

export_jpeg = function(scale, path) {
  var file, options;
  options = new ExportOptionsJPEG;
  options.antiAliasing = true;
  options.artBoardClipping = true;
  options.qualitySetting = 100;
  options.horizontalScale = 100 * scale;
  options.verticalScale = 100 * scale;
  file = new File(path);
  activeDocument.exportFile(file, ExportType.JPEG, options);
};

ios_app = function() {
  var app, file, find_path_of_file, path, prop, rep, script;
  find_path_of_file = function(file_name, start_path) {
    var parts;
    if (new File("" + start_path + "/" + file_name).exists) {
      return start_path;
    }
    parts = start_path.split('/');
    if (parts.length < 2) {
      return null;
    }
    return find_path_of_file(file_name, parts.slice(0, -1).join('/'));
  };
  rep = function(s, o, n) {
    return s.toString().split(o).join(n);
  };
  path = find_path_of_file('ios_app.js', rep(rep(activeDocument.path, '%20', ' '), '\\', '/'));
  if (path === null) {
    alert("ios_app.js not found");
    return null;
  }
  file = new File("" + path + "/ios_app.js");
  file.open('r');
  script = "(function(){var app={};" + (file.read()) + ";return app})();";
  file.close();
  app = eval(script);
  prop = function(name, get_value) {
    if (!(name in app)) {
      app[name] = get_value();
    }
  };
  prop('name', function() {
    return activeDocument.name.toString().replace(/\..*/g, '');
  });
  prop('path', function() {
    return path;
  });
  prop('images_path', function() {
    return "" + app.path + "/" + app.name + "/Assets/Images";
  });
  prop('icons_path', function() {
    return "" + app.images_path + "/Icons";
  });
  prop('launch_images_path', function() {
    return "" + app.images_path + "/Launch";
  });
  prop('itc_snapshots_path', function() {
    return "" + app.path + "/itc/snapshots";
  });
  return app;
};

exports = {
  active_ab: active_ab,
  index_of_ab: index_of_ab,
  set_active_ab: set_active_ab,
  rect_from_array: rect_from_array,
  array_from_rect: array_from_rect,
  get_ab_rect: get_ab_rect,
  set_ab_rect: set_ab_rect,
  get_pi_rect: get_pi_rect,
  active_document_path: active_document_path,
  active_document_name: active_document_name,
  export_jpeg: export_jpeg,
  export_png_24: export_png_24,
  export_png_24_no_alpha: export_png_24_no_alpha,
  ios_app: ios_app
};
