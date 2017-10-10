"use strict";

let express = require('express');
let www = express();
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

function createSearchQuery(q) {
	let splitChars = ["[", "]", "(", ")", " ", "　"];
	let fields = ["courseTitle", "instructor", "category", "academyDisciplines", 
	    "content.outline", "content.objective", "content.studyBeforeOrAfter", 
	    "content.schedule", "content.textbooks", "content.reference", "content.evaluation", 
	    "content.note", "subtitle", "classroom"];
	let words = [];
	let s = "", i = 0;
	for (i = 0; i < q.length; i++) {
		let c = q[i];
		if (c == '"') {
			if (s.length > 0) words.push(s);
			s = "";
			for (;;) {
				c = q[++i];
				if (c == '"') {
					if (q[i + 1] != '"') break;
					c = q[++i];
				}
				if (i >= q.length) break;
				s += c;
			}
			if (s.length > 0) words.push(s);
			s = "";
		} else if (splitChars.indexOf(c) >= 0) {
			if (s.length > 0) words.push(s);
			s = "";
		} else {
			s += c;
		}
	}
	if (s.length > 0) words.push(s);
	let ret = [];
	for (let word of words) {
		let list = [];
		for (let field of fields) {
			let obj = {};
			obj[field] = new RegExp(word, 'i');
			list.push(obj);
		}
		ret.push({$or: list});
	}
	return {$and: ret};
}

www.set('x-powered-by', false);
www.set('views', ROOT_DIR + '/views');
www.set('view engine', 'ejs');

www.get('/', function(req, res) {
	//res.send("hello");
	res.render('index');
});
www.get('/search', function(req, res) {
	let results = [];
	if (req.query.q) {
		console.log("q");
		let q = req.query.q;
		if (!q) {
			res.redirect('/');
			return;
		}
		let rgx = new RegExp(q, "i");
		connectDB((db)=>{
			let collection = db.collection('classes');
			collection.find(createSearchQuery(q)).toArray((err, docs)=>{
				if (err) {
					console.log("find error: " + err);
				} else {
					res.render('search', {
						results: docs,
						q:	q
					});
					
				}


			});
			
		});
	}

});

www.use(function(req, res, next) {
	res.status(404)
	   .render('404');
});
www.use(function(err, req, res, next) {
	res.status(500)
	   .render('500');
});

module.exports = www;
