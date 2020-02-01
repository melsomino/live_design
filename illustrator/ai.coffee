


active_ab = () ->
	activeDocument.artboards[activeDocument.artboards.getActiveArtboardIndex()]





index_of_ab = (ab) ->
	abs = activeDocument.artboards
	for i in [0 ... abs.length]
		if abs[i].name is ab.name
			return i
	return -1





set_active_ab = (ab) ->
	index = index_of_ab ab
	if index >= 0
		activeDocument.artboards.setActiveArtboardIndex index
	return



# Y
# ^
# |
# +-------> X
#
# [ 0  1  2  3 ]
# [ L  T  R  B ]
#
L = 0
T = 1
R = 2
B = 3

rect_from_array = (a) ->
	{
		x: a[L]
		y: a[B]
		w: a[R] - a[L]
		h: a[T] - a[B]
	}





array_from_rect = (r) ->
#	[ L		T			R			B ]
	[ r.x,	r.y + r.h,	r.x + r.w,	r.y ]





get_ab_rect = (ab) ->
	rect_from_array ab.artboardRect





set_ab_rect = (ab, r) ->
	ab.artboardRect = array_from_rect r
	return





get_pi_rect = (pi) ->
	rect_from_array pi.geometricBounds





active_document_path = () ->
	activeDocument.path.toString().split(/[\\\/]/g).slice(0, -1).join('/').split('%20').join(' ')





active_document_name = () ->
	activeDocument.name.toString().replace /\..*/g, ''





export_png_24 = (scale,png_path) ->
	options = new ExportOptionsPNG24
	# options.colorCount = 128
	options.antiAliasing = yes
	options.artBoardClipping = yes

	options.horizontalScale = 100*scale
	options.verticalScale = 100*scale

	file = new File png_path
	activeDocument.exportFile file, ExportType.PNG24, options
	return





export_png_24_no_alpha = (scale,png_path) ->
	options = new ExportOptionsPNG24
	# options.colorCount = 128
	options.antiAliasing = yes
	options.artBoardClipping = yes
	options.transparency = no

	options.horizontalScale = 100*scale
	options.verticalScale = 100*scale

	file = new File png_path
	activeDocument.exportFile file, ExportType.PNG24, options
	return





export_jpeg = (scale,path) ->
	options = new ExportOptionsJPEG
	# options.colorCount = 128
	options.antiAliasing = yes
	options.artBoardClipping = yes
	options.qualitySetting = 100
	options.horizontalScale = 100*scale
	options.verticalScale = 100*scale

	file = new File path
	activeDocument.exportFile file, ExportType.JPEG, options
	return





ios_app = () ->

	find_path_of_file = (file_name, start_path) ->	
		if  new File("#{start_path}/#{file_name}").exists
			return start_path
		parts = start_path.split '/'
		if parts.length < 2
			return null 
		find_path_of_file file_name, parts.slice(0, -1).join('/')

	rep = (s,o,n) -> 
		s.toString().split(o).join n

	path = find_path_of_file 'ios_app.js', rep(rep(activeDocument.path, '%20', ' '), '\\', '/')
	if path is null
		alert "ios_app.js not found"
		return null

	file = new File "#{path}/ios_app.js"
	file.open 'r'
	script = "(function(){var app={};#{file.read()};return app})();"
	file.close()

	app = eval script
	
	prop = (name, get_value) -> 
		if not (name of app)
			app[name] = get_value()
		return

	prop 'name', () -> activeDocument.name.toString().replace /\..*/g, ''
	prop 'path',  () -> path
	prop 'images_path', () -> "#{app.path}/#{app.name}/Assets/Images"
	prop 'icons_path', () -> "#{app.images_path}/Icons"
	prop 'launch_images_path', () -> "#{app.images_path}/Launch"
	prop 'itc_snapshots_path', () -> "#{app.path}/itc/snapshots"

	app





exports =
	active_ab: active_ab
	index_of_ab: index_of_ab
	set_active_ab: set_active_ab
	rect_from_array: rect_from_array
	array_from_rect: array_from_rect
	get_ab_rect: get_ab_rect
	set_ab_rect: set_ab_rect
	get_pi_rect: get_pi_rect
	active_document_path: active_document_path
	active_document_name: active_document_name
	export_jpeg: export_jpeg
	export_png_24: export_png_24
	export_png_24_no_alpha: export_png_24_no_alpha
	ios_app: ios_app





