


ai = require 'ai'


devs =
	ph4: { title: 'iPhone 4', file: '3.5-Inch', device: 'phone' }
	ph5: { title: 'iPhone 5', file: '4-Inch', device: 'phone' }
	ph6: { title: 'iPhone 6', file: '4.7-Inch', device: 'phone' }
	ph6p: { title: 'iPhone 6+', file: '5.5-Inch', device: 'phone6p' }
	pd:  { title: 'iPad', file: 'iPad', device: 'pad' }

langs =
	de: { title: 'German', file: 'German', style: 'roman' }
	en: { title: 'English', file: 'English', style: 'roman' }
	es: { title: 'Spanish', file: 'Spanish', style: 'roman' }
	fr: { title: 'French', file: 'French', style: 'roman' }
	it: { title: 'Italian', file: 'Italian', style: 'roman' }
	ja: { title: 'Japan', file: 'Japan', style: 'asian' }
	ko: { title: 'Korean', file: 'Korean', style: 'asian' }
	ru: { title: 'Russian', file: 'Russian', style: 'roman' }
	zh_hans: { title: 'Simplified Chinese', file: 'Simplified_Chinese', style: 'asian' }
	zh_hant: { title: 'Traditional Chinese', file: 'Traditional_Chinese', style: 'asian' }



class Snapshots

	constructor: () ->
		@app = ai.ios_app()
		@errors = []
		return





	set_lang: (lang_name) ->

		loc_visible = (lang_name, dev_name, snapshot_name, name) =>
			has_visible = no
			try_loc = (test_lang_name,expect_lang_name) =>
				n = "#{dev_name} #{snapshot_name} #{name} #{test_lang_name}"
				try
					item = activeDocument.pageItems.getByName n
					is_visible = test_lang_name is expect_lang_name
					item.hidden = not is_visible
					has_visible = has_visible or is_visible
					return yes
				catch e
					@errors.push "#{n} not found"
					return no

			for enum_lang_name of langs
				try_loc enum_lang_name, lang_name

			if not has_visible
				try_loc 'en', 'en'

			return

		loc_contents = (lang_name, dev_name, snapshot_name, name, contents) =>
			name = "#{dev_name} #{snapshot_name} #{name}"
			try
				item = activeDocument.pageItems.getByName name
				item.contents = contents[lang_name]
				style = activeDocument.characterStyles.getByName "#{devs[dev_name].device}_#{langs[lang_name].style}"
				style.applyTo item.textRange, yes
			catch e
				@errors.push "#{name} not found"
			return

		# main

		for dev_name of devs
			for snapshot_name of @app.itc_snapshots
				snapshot = @app.itc_snapshots[snapshot_name]
				for item_name of snapshot
					if item_name is '_v'
						for i in [0 ... snapshot._v.length]
							loc_visible lang_name, dev_name, snapshot_name, snapshot._v[i]
					else
						loc_contents lang_name, dev_name, snapshot_name, item_name, snapshot[item_name]
		return





	export: () ->

		save_image = (lang_name, dev_name, snapshot_name) =>
			artboard_name = "#{dev_name} #{snapshot_name}"
			for artboard_index in [0 ... activeDocument.artboards.length]
				if activeDocument.artboards[artboard_index].name is artboard_name
					activeDocument.artboards.setActiveArtboardIndex artboard_index
					l = langs[lang_name]
					d = devs[dev_name]
					ai.export_jpeg 1, "#{@app.itc_snapshots_path}/#{l.file}  #{d.file}  #{snapshot_name}.jpeg"

					# options = new ExportOptionsPNG8
					# options.colorCount = 128
					# options.antiAliasing = true
					# options.artBoardClipping = true

					# # options.horizontalScale = 100*image.width/(r[2] - r[0]);
					# # options.verticalScale = 100*image.height/(r[1] - r[3]);
					# file = new File "#{app.itc_snapshots_path}/#{l.file}  #{d.file}  #{snapshot_name}.png"
					# activeDocument.exportFile file, ExportType.PNG8, options
			return

		totals = 0



		# for lang_name of langs
		# 	for dev_name of devs
		# 		for snapshot_name of @app.itc_snapshots
		# 			++totals

		# progress = new Progress 'Export App Store Shapshots', totals
		# try
		# 	for lang_name of langs
		# 		@set_lang lang_name
		# 		for dev_name of devs
		# 			for snapshot_name of @app.itc_snapshots
		# 				progress.next "#{langs[lang_name].title}: #{devs[dev_name].title} (#{snapshot_name})"
		# 				save_image lang_name, dev_name, snapshot_name
		# finally
		# 	progress.close()





		for dev_name of devs
			for snapshot_name of @app.itc_snapshots
				++totals

		progress = new Progress 'Export App Store Shapshots', totals
		try
			lang_name = 'ja'
			for dev_name of devs
				for snapshot_name of @app.itc_snapshots
					progress.next "#{langs[lang_name].title}: #{devs[dev_name].title} (#{snapshot_name})"
					save_image lang_name, dev_name, snapshot_name
		finally
			progress.close()

		return





exports.set_lang = (lang) -> 
	(new Snapshots).set_lang lang
	return

exports.export_snapshots = () -> 
	(new Snapshots).export() 
	return



