const gakubu = require('./coursecompass-fetch/lib/gakubu');
const classes = require('./coursecompass-fetch/lib/class');

const dbsettings = require('./settings/database.json');

let mongoClient = require('mongodb').MongoClient;

function connectDB(callback) {
	mongoClient.connect("mongodb://localhost:" + dbsettings.port + "/" + dbsettings.dbname, function(err, db) {
		if (err) {
			console.log("db connection error: " + err);
		} else {
			callback(db);
		}
	});
}

function register(classList) {
	connectDB((db) => {
		let collection = db.collection('classes');
		console.log("Adding " + classList.length + " data...");
		for (let cl of classList) {
			collection.update({pKey: cl.pKey}, cl, {upsert: true});
		}
		process.exit(0);
	});
}

let gidList = [];
let pidList = [];
process.stdin.resume();
let str = "", ind;
process.stdin.on('data', function(chunk) {
	str += chunk;
	while ((ind = str.indexOf("\n")) > -1) {
		let line = str.slice(0, ind);
		str = str.slice(ind + 1);
		gidList.push(line);
	}
});
process.stdin.on('end', function() {
	if (str) {
		gidList.push(str);
	}
	console.log(gidList);
	let classList = [];
	let nextStep = (function loop() {
		let pid = pidList.shift();
		if (!pid) {
			register(classList);
			return;
		}
		process.stderr.write("fetching page " + pid + "...\n");
		classes.fetch(pid, function(data){
			if (data) {
				classList.push(data);
				if (pidList.length) {
					loop();
				} else {
					register(classList);
				}
			} else {
				process.stderr.write("error: some error occurs when fetching or parsing " + pid + "\n");
			}
		});
	});
	(function loop() {
		let gid = gidList.shift();
		if (!gid) {
			nextStep();
			return;
		}
		if (gid[0] == '"' && gid[gid.length - 1] == '"') {
			gid = gid.slice(1, gid.length - 1);
			console.log(gid);
		}
		process.stderr.write("fetching gakubu " + gid + "...\n");
		if (!gakubu.getPageIDList(gid, function(data){
			for (let record of data) pidList.push(record);
			if (gidList.length) {
				loop();
			} else {
				nextStep();
			}
		}, 2017)) {
			process.stderr.write("error: " + gid + " not found\n");
		}
	})();
});
