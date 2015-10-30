(function(){document.addEventListener('DOMContentLoaded', function() {
    function shuffle(o) {
        for(var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
        return o;
    }
    var seed = Math.random();
    Math.random = function() {
    	return Math.sin(seed+=42) / 2 + 0.5;
    }
    //--------


    var NUM_ROWS = 30;
    var NUM_COLS = 30;
    var DISTANCE_THRESHOLD = 0.05;
    var REMOVE_PERCENTAGE = 0.45;
    var CANVAS_ID = "myCanvas";

    var Point = function(r, c, x, y) {
        x = x || 0;
        y = y || 0;

        this.r = r;
        this.c = c;

        this.x = x;
        this.y = y;

        this.isEndPoint = false;
        this.isRemoved = false;
        
        this.left = undefined;
        this.right = undefined;
        this.top = undefined;
        this.bottom = undefined;
    }

    var rows = [];
    var cols = [];
    var grid = [];
    var endPoints = [];
    //var horizontalSegments = [];
    //var verticalSegments = [];
    var segments = [];
    var pigSegments = [];

    var generateLines = function() {
        for (var i = 0; i < NUM_ROWS; i++)
            rows.push(Math.random());
        for (var i = 0; i < NUM_COLS; i++)
            cols.push(Math.random());
        rows.sort();
        cols.sort();
    }

    var removeCloseLines = function(array) {
        for (var i = 0; i < array.length-1; i++) {
            if (array[i+1] - array[i] < DISTANCE_THRESHOLD) {
                array.splice(i+1, 1);
                i--;
            }
        }
    }

    var generateGrid = function() {
        for (var i = 0; i < rows.length; i++) {
            grid[i] = [];
            for (var j = 0; j < cols.length; j++) {
                grid[i][j] = new Point(i, j, rows[i], cols[j]);
            }
        }        
        for (var i = 0; i < rows.length; i++)
            for (var j = 0; j < cols.length; j++) {
                if (i > 0) grid[i][j].top = grid[i-1][j];
                if (j > 0) grid[i][j].left = grid[i][j-1];
                if (i < rows.length-1) grid[i][j].bottom = grid[i+1][j];
                if (j < cols.length-1) grid[i][j].right = grid[i][j+1];
            }
    }

    var selectEndPoints = function() {
        var numEndPoints = ((Math.random() * 3) | 0) + 2;
        console.log(numEndPoints + " end points");

        var samples = [];
        for (var i = 0; i < rows.length; i++)
            samples.push(i, rows.length+i);
        for (var i = 0; i < cols.length; i++)
            samples.push(rows.length*2+i, rows.length*2+cols.length+i);
        shuffle(samples);
        for (var i = 0; i < numEndPoints; i++)
            markAsEndPoint(samples[i]);
        console.log("Samples:", samples);
    }

    var markAsEndPoint = function(index) {
        var endPoint = undefined;
        if (index < rows.length)
            endPoint = grid[index][0];
        else if (index < rows.length*2)
            endPoint = grid[index-rows.length][cols.length-1]
        else if (index < rows.length*2+cols.length)
            endPoint = grid[0][index-rows.length*2];
        else
            endPoint = grid[rows.length-1][index-rows.length*2-cols.length];
        endPoint.isEndPoint = true;
        endPoints.push(endPoint);
    }

    var isKeyPoint = function(keyPoint) {
        for (var endPoint in endPoints)
            if (checkAccessibility(endPoints[endPoint], keyPoint) == false)
                return true;
        return false;
    }

    var checkAccessibility = function(endPoint, keyPoint) {
        var visited = [];
        for (var i = 0; i < rows.length; i++) {
            visited[i] = [];
            for (var j = 0; j < cols.length; j++)
                visited[i][j] = false;
        }

        var stack = [];
        stack.push(endPoint);

        while (stack.length > 0) {
            var point = stack.pop();

            visited[point.r][point.c] = true;

            if (point.top    && !point.top.isRemoved    && point.top != keyPoint    && !visited[point.top.r][point.top.c])
                stack.push(point.top);
            if (point.bottom && !point.bottom.isRemoved && point.bottom != keyPoint && !visited[point.bottom.r][point.bottom.c])
                stack.push(point.bottom);
            if (point.left   && !point.left.isRemoved   && point.left != keyPoint   && !visited[point.left.r][point.left.c])
                stack.push(point.left);
            if (point.right  && !point.right.isRemoved  && point.right != keyPoint  && !visited[point.right.r][point.right.c])
                stack.push(point.right);
        }

        for (var i = 0; i < rows.length; i++)
            for (var j = 0; j < cols.length; j++)
                if (grid[i][j].isRemoved == false && grid[i][j] != keyPoint && visited[i][j] == false)
                    return false;
        return true;
    }
    
    var removePoints = function() {
        var removeCount = ((rows.length * cols.length - endPoints.length) * REMOVE_PERCENTAGE)|0;
        console.log("Remove", removeCount, "intersections");

        var points = [];
        for (var i = 0; i < rows.length; i++)
            for (var j = 0; j < cols.length; j++)
                if (grid[i][j].isEndPoint == false)
                    points.push([i,j]);
        shuffle(points);

        var count = 0;
        for (var i = 0; i < removeCount; i++) {
            var point = grid[points[i][0]][points[i][1]];
            if (!isKeyPoint(point)) {
                point.isRemoved = true;
                //console.log(point, "...is not key point: removed!");
                count++;
            }
        }
        console.log("Removed", count, "intersections");
    }

    var removeCycles = function() {
        for (var i = 1; i < rows.length; i++) {
            for (var j = 1; j < cols.length; j++) {
                if (!grid[i][j].isRemoved && !grid[i-1][j].isRemoved && !grid[i-1][j-1].isRemoved && !grid[i][j-1].isRemoved &&
                        grid[i][j].left != null && grid[i-1][j].left != null && grid[i][j].top != null && grid[i][j-1].top != null) {
                    if (Math.random() < 0.5) {
                        grid[i][j].left = null;
                        grid[i][j-1].right = null;
                        pigSegments.push([grid[i][j].x, grid[i][j].y, grid[i][j-1].x, grid[i][j-1].y]);
                    } else {
                        grid[i][j].top = null;
                        grid[i-1][j].bottom = null;
                        pigSegments.push([grid[i][j].x, grid[i][j].y, grid[i-1][j].x, grid[i-1][j].y]);
                    }
                }
            }
        }
    }

    var buildHSegments = function() {
        for (var i = 0; i < rows.length; i++) {
            var start = -1;
            for (var j = 0; j < cols.length; j++) {
                var point = grid[i][j];
                if ((point.isRemoved || point.left === null) && start != -1) {
                //if (point.isRemoved && start != -1) {
                	//console.log(point);
                    var end = j-1;
                    if (end > start) {
                        //console.log("start: ", start, "end: ", end);
                        //console.log(cols[start], cols[end]);
                        segments.push([rows[i], cols[start], rows[i], cols[end]]);
                    }
                    start = -1;
                }
                if (start == -1 && (point.isRemoved == false && point.right !== null))
                    start = j;
            }
            if (start != -1 && start != cols.length-1) {
                //console.log("start: ", start, "end: ", cols.length-1);
                //console.log(cols[start], cols[cols.length-1]);
                segments.push([rows[i], cols[start], rows[i], cols[cols.length-1]]);
            }
        }
    }
    var buildVSegments = function() {
        for (var i = 0; i < cols.length; i++) {
            var start = -1;
            for (var j = 0; j < rows.length; j++) {
                var point = grid[j][i];
                //console.log(point);
                if ((point.isRemoved || point.top === null) && start != -1) {
                    var end = j-1;
                    if (end > start) {
                        //console.log("start: ", start, "end: ", end);
                        //console.log(rows[start], rows[end]);
                        segments.push([rows[start], cols[i], rows[end], cols[i]]);
                    }
                    start = -1;
                }
                if (start == -1 && (point.isRemoved == false && point.bottom !== null))
                    start = j;
            }
            if (start != -1 && start < rows.length-1) {
                //console.log("start: ", start, "end: ", rows.length-1);
                //console.log(rows[start], rows[rows.length-1]);
                segments.push([rows[start], cols[i], rows[rows.length-1], cols[i]]);
            }
        }
    }

	var transformCoord = function(x, size) {
		var MARGIN = 0.1;
		var margin = size * MARGIN;		
		return x * (1 - MARGIN)+margin/2;
	}

    var drawSegments = function() {
        var canvas = document.getElementById(CANVAS_ID); 
        var width = canvas.width;
        var height = canvas.height;

        var context = canvas.getContext("2d");

        for (var i in segments) {
            var seg = segments[i];

            context.beginPath();
            context.moveTo(transformCoord(seg[1]*width, width), transformCoord(seg[0]*height, height));
            context.lineTo(transformCoord(seg[3]*width, width), transformCoord(seg[2]*height, height));
            context.stroke();
            
            /*var x1 = transformCoord(seg[0]*width, width);
            var x2 = transformCoord(seg[2]*width, width);
            var y1 = transformCoord(seg[1]*width, width);
            var y2 = transformCoord(seg[3]*width, width);
            console.log(x1, x2, y1, y2);
			context.fillRect(x1, y1, x2-x1+1, y2-y1+1);*/
        }
        for (var i in endPoints) {
            var endPoint = endPoints[i];
            context.fillRect(transformCoord(endPoint.y*width, width) - 5, transformCoord(endPoint.x*height, height) - 5, 10, 10);
        }
        /*for (var i in pigSegments) {
        	var seg = pigSegments[i];
        	context.strokeStyle="#FF0000";
        	context.beginPath();
            context.moveTo(transformCoord(seg[1]*width, width), transformCoord(seg[0]*height, height));
            context.lineTo(transformCoord(seg[3]*width, width), transformCoord(seg[2]*height, height));
            context.stroke();
        }*/
    }

    generateLines();
    removeCloseLines(rows);
    removeCloseLines(cols);
    generateGrid();
    selectEndPoints();
    removePoints();
    removeCycles();
    buildHSegments();
    buildVSegments();
    drawSegments();

    console.log("Grid: ", grid);
    console.log("EndPoints:", endPoints);
    //console.log("HSegments: ", horizontalSegments);
    //console.log("VSegments: ", verticalSegments);
}, false)})();
