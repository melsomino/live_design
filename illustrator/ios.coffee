ai = require 'ai'


create_palette = () ->
	old_palette = Window.find '', 'iOS Tools'
	if old_palette
		old_palette.close()

	alert 'iOS helper started'
	create_palette_window 'iOS Tools',
		images:
			'4 png': 'ios.export_4_png'
			'icons': 'ios.export_app_icons'
			'launch': 'ios.export_launch_images'
		itc_paste_replace:
			'paste': 'ios.paste_replace'
			'with replace': 'ios.paste_replace replace'
		itc_lang_gen_1:
			ru: 'itc.set_lang ru'
			en: 'itc.set_lang en'
			de: 'itc.set_lang de'
			es: 'itc.set_lang es'
		itc_lang_gen_2:
			fr: 'itc.set_lang fr'
			it: 'itc.set_lang it'
			ja: 'itc.set_lang ja'
			ko: 'itc.set_lang ko'
		itc_lang_gen_3:
			zh_hans: 'itc.set_lang zh_hans'
			zh_hant: 'itc.set_lang zh_hant'
			gen: 'itc.export_snapshots'
		sys:
			'reload palette': 'ios.create_palette'

	return

  
phone_assets_scale = 1
pad_assets_scale = 5/4

 
export_4_png = () ->
	app = ai.ios_app()
	ab = ai.active_ab()
	
	resolutions =
		'phone': 1*phone_assets_scale, 
		'phone@2x': 2*phone_assets_scale,
		'phone@3x': 3*phone_assets_scale,
		'pad': pad_assets_scale,
		'pad@2x': 2*pad_assets_scale

	progress = new Progress 'Export 4 Png', 5

	for resolution of resolutions
		progress.next resolution
		ai.export_png_24 resolutions[resolution] / 10, "#{app.images_path}/#{ab.name}_#{resolution}.png"

	progress.close()
	return





export_app_icons = () ->
	app = ai.ios_app()
	ab = activeDocument.artboards.getByName 'app_icon'

	sizes = [57,72,76,114,120,144,152,167,180]
	progress = new Progress 'Export App Icons', sizes.length
	try
		for size in sizes
			progress.next "#{size}x#{size}"
			ai.export_png_24 size/1024.0, "#{app.icons_path}/appicon#{size}x#{size}.png"
	finally
		progress.close()

	return





export_launch_images = () ->

	image_defs = 
		'Default': { width: 320, height: 480, ratio: '2x3' } # iPhone Portrait 1x
		'Default~iphone': { width: 640, height: 960, ratio: '2x3' } # iPhone Portrait Retina 4
		'Default-568h@2x': { width: 640, height: 1136, ratio: '40x71' } # iPhone Portrait Retina 4

		'Default~ipad': { width: 768, height: 1004, ratio: '192x251' } # iPad Portrait Without Status Bar 1x
		'Default-Portrait@2x~ipad': { width: 1536, height: 2008, ratio: '192x251' } # iPad Portrait Without Status Bar 2x
		'Default-Landscape~ipad': { width: 1024, height: 748, ratio: '256x187' } # iPad Landscape Without Status Bar 1x
		'Default-Landscape@2x~ipad': { width: 2048, height: 1496, ratio: '256x187' } # iPad Landscape Without Status Bar 2x

		'launch768x1024': { width: 768, height: 1024, ratio: '3x4' } # iPad Portrait 1x
		'launch768x1024@2x': { width: 1536, height: 2048, ratio: '3x4' } # iPad Portrait 2x
		'launch1024x768': { width: 1024, height: 768, ratio: '4x3' } # iPad Landscape 1x
		'launch1024x768@2x': { width: 2048, height: 1536, ratio: '4x3' } # iPad Landscape 2x

		'launch1242x2208@3x': { width: 1242, height: 2208, ratio: '9x16' } # iPhone Portrait Retina HD 5.5
		'launch750x1334@2x': { width: 750, height: 1334, ratio: '375x667' } # iPhone Portrait Retina HD 4.7
		'launch2208x1242@3x': { width: 2208, height: 1242, ratio: '16x9' } # iPhone Landscape Retina HD 5.5

	app = ai.ios_app()
	ab = activeDocument.artboards.getByName 'launch_image'
	ai.set_active_ab ab
	save_ab_rect = ai.get_ab_rect ab
	
	totals = 0
	for name, def of image_defs
		++totals

	progress = new Progress 'Export Launch Images', totals
	try
		for name, def of image_defs
			progress.next name
			frame = activeDocument.pageItems.getByName def.ratio
			if not frame
				alert "#{name} not found"
				return
			r = ai.get_pi_rect frame
			ai.set_ab_rect ab, r
			ai.export_png_24_no_alpha def.width / r.w, "#{app.launch_images_path}/#{name}.png"
	finally
		progress.close()

	ai.set_ab_rect ab, save_ab_rect
	return





paste_replace = (args) ->
	if activeDocument.selection.length isnt 1
		alert 'Single element must be selected'
		return ''
	
	replaced = activeDocument.selection[0]
	app.paste()
	pasted = activeDocument.selection[0]
	pasted.left = replaced.left
	pasted.top = replaced.top
	pasted.width = replaced.width
	pasted.height = replaced.height
	pasted.name = replaced.name
	pasted.move replaced, ElementPlacement.PLACEBEFORE
	if args is 'replace'
		replaced.remove()
	return ''





exports.create_palette = create_palette
exports.export_4_png = export_4_png
exports.export_app_icons = export_app_icons
exports.export_launch_images = export_launch_images
exports.paste_replace = paste_replace






