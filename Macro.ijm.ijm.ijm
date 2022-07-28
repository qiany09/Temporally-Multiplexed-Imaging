for (var i = 0; i < roiManager("count"); i++){

roiManager("Select", i);
getSelectionCoordinates(x,y);
roiManager("measure");
//Array.print(x);
//Array.print(y);
Array.getStatistics(x, minx, maxx, meanx, stdDevx);
Array.getStatistics(y, miny, maxy, meany, stdDevy);
var channel, slice, frame;
Stack.getPosition(channel, slice, frame);
print(meanx, meany, frame);
run("Make Band...", "band=2");
roiManager("update");
roiManager("measure");
}