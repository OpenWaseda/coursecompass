"use strict";

const express = require('express'),
	  morgan = require('morgan'),
      bodyParser = require('body-parser'),
      methodOverride = require('method-override'),
      cookieParser = require('cookie-parser'),
      expressSession = require('express-session'),
      csrf = require('csurf');

global['ROOT_DIR'] = __dirname;
global['dbsettings'] = require('./settings/database.json');
global['websettings'] = require('./settings/web.json');

const www = require('./app/www');

process.on('SIGINT', () => {
	console.log("Interrupted.");
	process.exit(0);
});

process.stdin.resume();
process.stdin.on('end', () => {
	process.exit(0);
});

const app = express();
const server = app.listen(websettings.port, ()=>{
	console.log("coursecompass is available at http://localhost:" + websettings.port + "/");
});

app.set('views', ROOT_DIR + '/views');
app.set('view engine', 'ejs');

app.use(morgan('combind'));
app.use('/', www);
app.use(express.static(ROOT_DIR + '/public'));


