require_modules = {}


require = (name) ->
	module = require_modules[name]
	if not module is undefined
		return module
	file = new File "#{$.scripts_path}/#{name}.js"
	if not file.exists
		$.write "module '#{name}' not found"
		return null
	file.open 'r'
	script = "(function(){var exports={};#{file.read()};return exports})();"
	file.close()
	module = eval script
	require_modules[name] = module
	module
		




bridge_intruder = (scripts_path,command) ->
	$.scripts_path = scripts_path
	$.evalFile (new File "#{scripts_path}/require.js"), 100000

	split = (s,d) -> p = s.indexOf d; if p >=0 then [s.substr(0, p), s.substr(p + 1)] else [s, undefined]

	a = split command, ' '
	b = split a[0], '.'
	module_name = b[0]
	action_name = b[1]
	args = a[1]
	module = require module_name
	if not module
		alert "module '#{module_name}' not found"
		return
	if action_name is undefined
		action = module
	else
		action = module[action_name]
		if not action
			alert "module '#{module_name}' does not contains action '#{action_name}'"
			return

	action args
	''




bridge_run = (app, command) ->
	scripts_path = (new File $.fileName).path
	call = new BridgeTalk
	call.target = app
	call.body = "(#{bridge_intruder.toString()})('#{scripts_path}','#{command}');"
	call.onError = (error) -> alert "Error = #{error.body}"; return
	call.send()
	return





ai_run = (command) -> 
	bridge_run 'illustrator', command
	return





create_palette_window = (win_title,def) ->
	win = new Window "palette { text: '#{win_title}', resizeable: true }"
	for grp_title, grp_def of def
		grp = win.add 'group { orientation: "row", alignChildren: "fill", alignment: ["fill", "top"] }'
		for title, command of grp_def
			btn = grp.add "button {text: \"#{title}\", alignment: \"fill\" }"
			btn.onClick = ((cmd) -> () -> ai_run cmd)(command)
	win.onResizing = win.onResize = () -> @layout.resize()
	win.onShow = () -> win.minimumSize = win.size
	win.onClose = () -> yes
	win.show()
	win





class Progress
	constructor: (title, totals) ->
		@win = new Window 'palette', title, [150, 150, 600, 200]
		@win.progress_label = @win.add 'statictext', [10, 10, 320, 25], "iPhone export"
		@win.progress = @win.add 'progressbar', [8, 28, 440, 38], 0, totals
		@win.show()
		return

	next: (message) ->
		++@win.progress.value
		@win.progress_label.text = message
		@win.update()
		return

	close: () ->
		@win.close()
		delete @win
		return




