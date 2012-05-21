GPolyline.prototype.GetPointAtDistance	=	function(metres)	{
	if	(metres	==	0)	
		return	this.getVertex(0);
	if	(metres	<	0)	
		return	null;
	var	dist=0;
	var	olddist=0;
	for	(var	i=1;	(i	<	this.getVertexCount()	&&	dist	<	metres);	i++)	{
		olddist	=	dist;
		dist	+=	this.getVertex(i).distanceFrom(this.getVertex(i-1));
	}
	if	(dist	<	metres)	
		{return	null;}
	var	p1=	this.getVertex(i-2);
	var	p2=	this.getVertex(i-1);
	var	m	=	(metres-olddist)/(dist-olddist);
	return	new	GLatLng(	p1.lat()	+	(p2.lat()-p1.lat())*m,	p1.lng()	+	(p2.lng()-p1.lng())*m);
}

GGMap = {

	distance : 0,

	travelledline : null,
	
	journeyline : null,
	
	map : null,
	
	bounds: null,
	
	marker : null,
	
	destination : null,
	
	startPoint : null,
	
//Bibliotek UiO	59.941234,10.724909
	cities: [
		["Oslo Sentrum",	[59.912582,10.734152],	3230.931],
		["Bergen",		[60.408173,5.322704],	303488.64446650003],
		["Copenhagen",	[55.676169,12.568316],	487159.3898823857],
		["Amsterdam",		[52.376045,4.897821],	915523.1243772663],
		["Paris",			[48.852771,2.350259],	1345937.212610403],
		["Venezia",		[45.43417,12.338644],	1618464.5879345008],
		["New York",		[40.758863,-73.985147],	5913998.019628801],
		["Tokyo",			[35.689701,139.691752],	8413043.496044075],
		["Singapore",		[1.349134,103.945084],	10068187.993528241],
		["Sydney",		[-33.856669,151.21493],	15966304.930280805]
	],
	
	getCity : function(distance) {
		var c = GGMap.cities;
		var d;
		for ( var i = 0; i < c.length; i++) {
			if (c[i][2] > distance) {
				d = c[i];
				break;
			}
		}
		return d;
	},	
	
	midLineArrows : function(points)	{
		points = [GGMap.travelledline.getVertex(0),GGMap.travelledline.getVertex(1)];
		var	arrowIcon	=	new	GIcon();
		arrowIcon.iconSize	=	new	GSize(36,36);
		arrowIcon.shadowSize	=	new	GSize(1,1);
		arrowIcon.iconAnchor	=	new	GPoint(18,18);
		arrowIcon.infoWindowAnchor	=	new	GPoint(0,0);
		for	(var	i=0;	i<points.length-1;	i++)	{	
			var	p1=points[i];
			var	p2=points[i+1];
			var	p3=new	GLatLng((p1.lat()+p2.lat())/2,(p1.lng()+p2.lng())/2);
		
			var	dir	=	GGMap.bearing(p1,p2);
			var	dir	=	Math.round(dir/3)	*	3;
			while	(dir	>=	120){
				dir	-=	120;
			}
			arrowIcon.image	=	"http://www.google.com/intl/en_ALL/mapfiles/dir_"+dir+".png";
			GGMap.createMarker(p3,	arrowIcon);
		}
	},	
	
	endArrows : function(points) {
		points = [GGMap.travelledline.getVertex(0),GGMap.travelledline.getVertex(1)];
        // == obtain the bearing between the last two points
		var	arrowIcon	=	new	GIcon();
		arrowIcon.iconSize	=	new	GSize(36,36);
		arrowIcon.shadowSize	=	new	GSize(1,1);
		arrowIcon.iconAnchor	=	new	GPoint(18,18);
		arrowIcon.infoWindowAnchor	=	new	GPoint(0,0);		
        var p1=points[points.length-1];
        var p2=points[points.length-2];
        var dir = GGMap.bearing(p2,p1);
        // == round it to a multiple of 3 and cast out 120s
        var dir = Math.round(dir/3) * 3;
        while (dir >= 120) {dir -= 120;}
        // == use the corresponding triangle marker 
        arrowIcon.image = "http://www.google.com/intl/en_ALL/mapfiles/dir_"+dir+".png";
        GGMap.createMarker(p1, arrowIcon);
      },
	
	centerMap : function() {
		GGMap.map.setZoom(GGMap.map.getBoundsZoomLevel(GGMap.bounds)	);
		GGMap.map.setCenter(GGMap.bounds.getCenter());
	},
	
	drawMap : function(start,end,distance) {
		var	map	=	new	GMap2(document.getElementById("GGMap"));
		GGMap.map = map;
		map.setCenter(new	GLatLng(0,0),0);
		var	bounds	=	new	GLatLngBounds();

		var	point1	=	new	GLatLng(start[0],start[1]);
		
		bounds.extend(point1);
		
		var	point2	=	new	GLatLng(end[0],end[1]);
		bounds.extend(point2);
		GGMap.startPoint = point2;
		GGMap.bounds = bounds;
		GGMap.centerMap();
			var	polyline	=	new	GPolyline([
				point2,
				point1
			],	"#333",	6,0.5);
		map.addOverlay(polyline);
		GGMap.journeyline = polyline;

		var	pos	=	polyline.GetPointAtDistance(distance);
		var	posline	=	new	GPolyline([
					point2,
					pos
					],
					"#ff0000",10,0.7);
		map.addOverlay(posline);
		GGMap.travelledline = posline;
			

		//GGMap.midLineArrows([point2,pos]);
		//GGMap.endArrows();
	},
	
	createMarker : function (point,icon)	{
		GGMap.marker	=	new	GMarker(point,icon);
		GGMap.map.addOverlay(GGMap.marker)
	},
	
	degreesPerRadian : 180.0	/	Math.PI,
	
	bearing: function(	from,	to	)	{
		var	lat1	=	from.latRadians();
		var	lon1	=	from.lngRadians();
		var	lat2	=	to.latRadians();
		var	lon2	=	to.lngRadians();

		var	angle	=	-	Math.atan2(	Math.sin(	lon1	-	lon2	)	*	Math.cos(	lat2	),	Math.cos(	lat1	)	*	Math.sin(	lat2	)	-	Math.sin(	lat1	)	*	Math.cos(	lat2	)	*	Math.cos(	lon1	-	lon2	)	);
		if	(	angle	<	0.0	)
		angle	+=	Math.PI	*	2.0;
		
		angle	=	angle	*	GGMap.degreesPerRadian;
		angle	=	angle.toFixed(1);

		return	angle;
	},
	
	updateTravelled : function (distance) {
		var l = GGMap.travelledline;
		l.deleteVertex(1);
		l.insertVertex(1,GGMap.journeyline.GetPointAtDistance(distance));
	},
	
	changeDestination : function (destination, distance) {
		var travelled = GGMap.travelledline;
		var journey = GGMap.journeyline;
		journey.deleteVertex(1);
		var des = new GLatLng(destination[0],destination[1]);
		journey.insertVertex(1,des);
		//GGMap.map.removeOverlay(GGMap.marker);
		window.setTimeout(function(){
			GGMap.updateTravelled(distance);
			//GGMap.midLineArrows(travelled.getVertex(0),travelled.getVertex(1));
			//GGMap.updateTravelled(4000)
			GGMap.bounds	=	new	GLatLngBounds();
			GGMap.bounds.extend(GGMap.startPoint);
			GGMap.bounds.extend(des);
			GGMap.centerMap();
		},150);
	},
	
	update : function (distance) {
		if (GGMap.distance == distance)
			return;
		GGMap.distance = distance;
		var city = GGMap.getCity(distance);
		//console.log(city[0]);
		//console.log(GGMap.destination[0]);
		if (city[0] != GGMap.destination[0]) {
			//changeDestination
			GGMap.destination = city;
			GGMap.changeDestination(city[1],distance);
		} else {
			//console.log("updateTravelled");
			GGMap.updateTravelled(distance);
		}
	},
	
	//distance travelled	
	init : function(distance) {
		if (GGMap.distance == distance)
			return;	
		GGMap.distance = distance;
		var city = GGMap.getCity(distance);
		GGMap.destination = city;
		GGMap.drawMap(city[1],[59.911557,10.750659],distance);
	} 
}
