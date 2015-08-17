// page-map/app.js
var express = require('express');
var app = module.exports = express();
//app.use(express.static())

app.get('/map', function(req,res) {
	res.sendFile(__dirname + '/page-map.html');
});