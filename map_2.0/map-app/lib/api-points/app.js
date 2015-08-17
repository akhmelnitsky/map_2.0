var express = require('express');
var app = module.exports = express();
var pg = require('pg');
var conString = "postgres://postgres:pr4p21d01@localhost:5432/mapdb";

app.get('/points', function(req,res) {
	pg.connect(conString, function(err, client, done) {
		if (err) {
	    	return console.error('error fetching client from pool', err);
	  	};
	  	console.log("select \"json_build_object\"(\'type\',\'FeatureCollection\',\'features\',\"GetPointsByBounds\"(long1:="+req.query.w+", long2:="+req.query.e+", lat1:="+req.query.s+",lat2:="+req.query.n+", properties:=\'\')) as featurecollection");
	  	client.query("select \"json_build_object\"(\'type\',\'FeatureCollection\',\'features\',\"GetPointsByBounds\"(long1:="+req.query.w+", long2:="+req.query.e+", lat1:="+req.query.s+", lat2:="+req.query.n+", properties:=\'\')) as featurecollection", function(err, result) {
	    	done();
	    	if (err) {
	    		return console.error('error running query', err);
	    	};
	    	res.send(result.rows[0].featurecollection)
	  	});
	});
});