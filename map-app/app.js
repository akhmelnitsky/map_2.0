//general app.js
var express=require('express');
var app=express();
var port=80;
var pagemap=require('./lib/page-map/app.js');
var pointsapi=require('./lib/api-points/app.js');
var staticlib=require('./lib/misc-static/app.js');
var pointtypesapi=require('./lib/api-pointtypes/app.js');

app.use(pagemap);
app.use(pointsapi);
app.use(staticlib);
app.use(pointtypesapi);

app.listen(port);
console.log('listening...');
