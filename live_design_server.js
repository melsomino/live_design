const fs = require('fs');
const urls = require('url');
const paths = require('path');
const http = require('http');
const EventEmitter = require('events').EventEmitter;
const os=require('os');

const concat = (x,y) => x.concat(y)

const flatMap = (f,xs) => xs.map(f).reduce(concat, [])

Array.prototype.flatMap = function(f) {
  return flatMap(f,this);
}

function get_ip() {
	const ipv4 = Object.values(os.networkInterfaces())
		.flatMap(x => x)
		.find(x => x.family === 'IPv4' && !x.internal);
	return ipv4 && ipv4.address;
}


const settings = {
	host: get_ip(),
	port: 8081,
	sources: []
};

const sources_changes = new EventEmitter();

const mime_types = {
	'.png': 'image/png',
	'.jpg': 'image/jpeg',
	'.jpeg': 'image/jpeg',
	'.json': 'application/json'
};


function ext_is(expected, file_name) {
	return file_name.splice(-expected.length).toLowerCase() === expected.toLowerCase();
}


// Server

function live_design_server(req, res) {
	const url = urls.parse(req.url, true);
	let sources_changes_listener = null;
	const finish_source_changes_listener = () => {
		if (sources_changes_listener) {
			sources_changes.removeListener('did_change', sources_changes_listener);
			sources_changes_listener = null;
		}
	};
	const finish_req = () => {
		finish_source_changes_listener();
		if (url.pathname !== '' && url.pathname !== '/') {
			const file_name = settings.sources
				.map(x => paths.join(x, url.pathname))
				.find(x => fs.existsSync(x));
			if (file_name) {
				const ext = paths.extname(file_name.toLowerCase());
				res.writeHead(200, {
					'Content-Type': mime_types[ext] || 'text/plain'
				});
				res.end(fs.readFileSync(file_name));
				return;
			}
		}
		res.writeHead(404, {
			'Content-Type': 'text/plain'
		});
		res.end(`404 Not Found [${url.pathname}]`);
	};
	if ('wait' in url.query) {
		sources_changes_listener = (event, file_name) => {
			finish_req();
		};
		sources_changes.addListener('did_change', sources_changes_listener);
		req.on('close', () => {
			finish_source_changes_listener();
		});
	} else {
		finish_req();
	}
};

let last_emit_id = 0;


function start_sources_changes_watcher() {
	const emit_time = null;
	const watcher = (event, file_name) => {
		const emit_id = ++last_emit_id;
		setTimeout(() => {
			if (last_emit_id === emit_id) {
				sources_changes.emit('did_change', event, file_name);
			}
		}, 500);
	};
	settings.sources.forEach((source) => {
		fs.watch(source, watcher);
	})
}


function override_settings(file_name) {
	let file_path = paths.join(process.cwd(), file_name);
	const ext = paths.extname(file_path).toLowerCase();
	if (ext === '') {
		file_path = file_path + '.json';
	} else if (ext !== '.json') {
		return false;
	}
	if (!fs.existsSync(file_path)) {
		return false;
	}
	console.log(`Load settings from: ${file_path}`);
	const overrides = JSON.parse(fs.readFileSync(file_path, {encoding: 'utf8'}));
	if (overrides.sources) {
		overrides.sources = overrides.sources.map((source) => {
			if (paths.isAbsolute(source)) {
				return source;
			}
			const fixed = paths.join(process.cwd(), source);
			if (!fs.existsSync(fixed)) {
				throw new Error(`Path does not [${fixed}] exist.`);
			}
			return fixed;
		});
	}
	Object.assign(settings, overrides);
	return true;
}


function prepare_settings(overrides) {
	Object.assign(settings, overrides);
	process.argv.splice(2).forEach((arg) => {
		let value_separator_pos = arg.indexOf('=');
		if (value_separator_pos < 0) {
			value_separator_pos = arg.indexOf(':');
		}
		if (value_separator_pos < 0) {
			if (!override_settings(arg)) {
				settings.sources.push(arg);
			}
		} else {
			const n = arg.substr(0, value_separator_pos);
			const v = arg.substr(value_separator_pos + 1);
			settings[n] = v;
		}
	});
	console.log(settings);
}


function start_server(host) {
	http.createServer(live_design_server).listen(settings.port, host);
	return console.log(`lds running at http://${host}:${settings.port}`);
}


exports.run = (settings_overrides) => {
	prepare_settings(settings_overrides);
	start_server("127.0.0.1");
	start_server(settings.host);
	return start_sources_changes_watcher();
};
