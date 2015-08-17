var express = require('express');
var app = module.exports = express();
var pg = require('pg');
var conString = "postgres://postgres:pr4p21d01@localhost:5432/mapdb";

app.get('/pointTypes', function(req,res) {
	pg.connect(conString, function(err, client, done) {
		if (err) {
	    	return console.error('error fetching client from pool', err);
	  	};
	  	console.log("select \"GetPointTypes\"() as point_types");
	  	client.query("select \"GetPointTypes\"() as point_types", function(err, result) {
	    	done();
	    	if (err) {
	    		return console.error('error running query', err);
	    	};
	    	res.send(result.rows[0].point_types)
	  	});
	});
});