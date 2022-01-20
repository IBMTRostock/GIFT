/* The General Image Fiber Tool (GIFT) was designed to automate the measurement of fiber diameters of electrospun fibers in SEM images. 
 * The method was originally described and validated in A. Götz, V. Senz, W. Schmidt, J. Huling, N. Grabow, S. Illner, Measurement 177 (2021) 109265.
 * GIFT was developed at the Institute for Bioengineering at the University of Rostock Medical Center. 
 * For more informatin see https://github.com/IBMTRostock/GIFT */
 
var dCmds = newMenu("GIFTmacro Menu Tool",  newArray("Process Single Open Image", "Batch Process")); 

macro "GIFTmacro Menu Tool - C000D37D38D39D3cD3dD3eD47D48D49D4cD4dD4eD58D5cD5dD5eD87D88D8dD96D97D98D99D9cD9eDa6Da7Da8Da9DacDadDb6Db7Db8Db9DbcDbdDbeC000D57D95Da5Db5Dc5C000C111C000D15D16D25D26D27D28D29D2bD2fD31D32D35D36D3bD3fD41D42D43D45D46D4bD4fD52D53D54D55D56D59D5bD5fD63D64D65D67D68D69D6bD6cD6dD6fD83D84D8bD8cD8fD92D93D94D9bD9dD9fDa1Da2Da3DabDaeDafDb1Db2DbbDbfDc6Dc7Dc8Dc9DcbDccDcdDceDcfC000C011C000Dd5C001C000D2cD2dD2eDd6C000D85D89C000C011C001C000C111C000C111D91C111C000C111C000C001C000C001C011C000C111C000C111C112C122D51C122D33C122C223C233C223C233C222C233C223C233C223D82C223C233Db3C223Da0C233D22C234C334C234C334C234C334D40C234C345C344C345D44C345D30C345Da4C345C344C445C456D62C456C457C456C446C456D21Dc2C456Db0C457C456C457C467C567C467C567C578D74C568C578C568C578C568C578C568C679Dc1C679D23C678C679C689C68aC79bC68aC79bC78aC68aC78aC79bC78aC79bC78aC79bC68aC79bC78aC79bC78aC79aC78aC79aC78aC79bC68aC89bC89cC8adD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D11D12D13D14D17D18D19D1aD1bD1cD1dD1eD1fD20D24D2aD34D3aD4aD50D5aD60D61D66D6aD6eD70D71D72D73D75D76D77D78D79D7aD7bD7cD7dD7eD7fD80D81D86D8aD8eD90D9aDaaDb4DbaDc0Dc3Dc4DcaDd0Dd1Dd2Dd3Dd4Dd7Dd8Dd9DdaDdbDdcDddDdeDdfDe0De1De2De3De4De5De6De7De8De9DeaDebDecDedDeeDef" 
{

//code for the single image mode:
cmd = getArgument();       
if (cmd=="Process Single Open Image") 
{ 
	run("Clear Results"); 
	run("Set Measurements...", "nan redirect=None decimal=3");


	// Creating the initial dialog GUI so the user can input directory locations, setting and image processing parameters
	Dialog.create("New Analysis");
			
	Dialog.setInsets(0, 0, 0);
	Dialog.addMessage("Set Parameters for GIFT:",12,"627791");
	Dialog.addNumber("Degrees of rotation:", 45);
	Dialog.setInsets(0,0,0);
	Dialog.addNumber("Line Length:", 8);
	Dialog.setInsets(0, 0, 0);
	Dialog.addNumber("Enter the threshold value (percent of pixels to include):", 5);
	Dialog.setInsets(0, 60, 0);
	Dialog.addCheckbox("Or check to manually set image thresholding in the next step", false);
	Dialog.addNumber("Set bin size for diameter histograms:", 1);

	Dialog.setInsets(0, 0, 0);
	Dialog.addMessage("Set image parameters:",12,"627791");
	Dialog.setInsets(0, 20, 0);
	Dialog.addMessage("Set the image's scale with known values, enter 1 for both values to measure in pixels or check the box to manually set scale on image.");
	Dialog.addNumber("Distance in pixels:", "1");
	Dialog.addNumber("Known distance:", "1");
	Dialog.setInsets(0, 60, 0);
	Dialog.addCheckbox("Manually set scale in next step", false);
	
	Dialog.setInsets(0, 20, 0);
	Dialog.addMessage("To crop out the image enter the height of the area to be analysed, measured from top of image. Or check box to crop manually.");
	Dialog.setInsets(0, 60, 0);
	Dialog.addCheckbox("Define image area to be analysed by known height", false);
	Dialog.setInsets(0, 60, 0);
	Dialog.addNumber("Height of imaged area (pixels):", "");
		
	Dialog.setInsets(0, 60, 0);
	Dialog.addCheckbox("Check to manually select the area to be analysed in next step", false);

	Dialog.setInsets(0, 0, 0);
	Dialog.addMessage("Fiber Orientation measurement:",12,"627791");
	Dialog.setInsets(0, 20, 0);
	Dialog.addMessage("GIFT can run existing ImageJ Plugins for orientation measurement during analysis for convienence.");
	options = newArray("None","OrientationJ","Directionality");
	Dialog.addChoice("Choose plugin", options, options[0]);
	
	
	Dialog.show();
	
	//assign variables based on user input
	degreeStep = Dialog.getNumber();
	lineLength = Dialog.getNumber();
	thresholdPercent = Dialog.getNumber();
	thresholdChoice = Dialog.getCheckbox();
	binSize=Dialog.getNumber();
	pixelDistance = Dialog.getNumber();
	knownDistance = Dialog.getNumber();
	scaleChoice = Dialog.getCheckbox();
	cropHeightChoice = Dialog.getCheckbox();
	cropSize = Dialog.getNumber();
	cropChoice = Dialog.getCheckbox();
	directionChoice = Dialog.getChoice();

	//check to make sure variable are not missing and are appropriate (i.e. negative) 
	if (isNaN(degreeStep) || degreeStep < 0) 
	{
		exit("Invalid value for degree of rotation (must be positive)");
	}
	if (isNaN(lineLength) || lineLength < 0) 
	{
		exit("Invalid value for line length (must be positive)");
	}
	if (isNaN(thresholdPercent) || thresholdPercent < 0) 
	{
		exit("Invalid value for threshold value (must be positive)");
	}
	if (isNaN(binSize) || binSize < 0) 
	{
		exit("Invalid value for bin size (must be positive)");
	}


	scaleFactor = pixelDistance/knownDistance; 


	//Additional user interactions if manual cropping, scale or threshold is selected.
	if (cropHeightChoice == true && cropChoice == true)
	{
		exit("User selected both cropping methods, please selection only one.");
	}
		
	else if (cropHeightChoice == false && cropChoice == true)
	{
		setTool(0);
	    waitForUser("Please select the area of the image to be analysed. Click OK when done");

		if (is("area")==false)
		{
			exit("no crop area selection made");
		}
		
		getSelectionCoordinates(xpoints, ypoints);	
	}
	else if (cropHeightChoice == true && cropChoice == false)
	{
		if (isNaN(cropSize) || cropSize < 1)
		{
				
			exit("Invalid height value entered");
		}
	
		xpoints=newArray(1);//leave this as a dummy arry for now. Later x values based on image size.  
		ypoints=newArray(0, cropSize);
	}
	
	else 
	{
		xpoints=newArray(1);//if no cropping needed these dummy arrays are created. 
		ypoints=newArray(1);
	}
	
	
	if (scaleChoice == true)
	{
		
		setTool("Line");
		waitForUser("Please select the length of the scalebar. Click OK when done");
		
		if (is("line")==false)
		{
			exit("no line selecion made");
		}
		
		getLine(x1, y1, x2, y2, lineWidth);	
		scaleLength = abs(x2-x1);

		Dialog.create("Enter Scale");
		Dialog.addNumber("Scalebar length:", "");
		Dialog.show();
		pixelLength = Dialog.getNumber();
	
		if (isNaN(pixelLength) || pixelLength < 0) 
		{
			exit("Invalid value for scale length (must be positive)");
		}
		
		scaleFactor = scaleLength/pixelLength;
	}
	
	if (thresholdChoice == true)
	{
		if (cropChoice == true) //Its important to remove any scale bar area before determining threshold levels
		{
			setTool("rectangle");  
			makeRectangle(xpoints[0],ypoints[0], xpoints[1]-xpoints[0], ypoints[3]-ypoints[0]);  //upper left corner, width, height, based on previously user defined rectangle
			run("Crop"); 	
		}
	
		else if (cropHeightChoice == true)
		{
			setTool("rectangle");  
			makeRectangle(0,ypoints[0], getWidth(), ypoints[1]);  //upper left corner, width, height, based on previously user defined rectangle
			run("Crop"); 
		}
		
		run("8-bit");   
		run("Colors...", "foreground=black background=black selection=yellow");  
		run("Find Edges");   	
		
		run("Threshold..."); 
		getHistogram(ImageHistValues, ImageHistCounts, 255);
		
		Array.getStatistics(ImageHistCounts, min, max, ImageHistMean);
		ImageHistTotal = ImageHistMean*ImageHistCounts.length;
		
		setThreshold(100, 255, "red");
		waitForUser("Adjust min/max sliders to desired levels. \n Adjust so that the edges are highlighted with clean red lines. \n Click OK when done. \n IMPORTANT: Do not click set or adjust.");
		getThreshold(min, max);
		binSum = 0;
	
		for (bin = min; bin < 255; bin++) 
		{
			binSum = binSum + ImageHistCounts[bin];
		}
	
		thresholdPercent = binSum/ImageHistTotal*100;
		
	}
	
	else 
	{
		min=200; //default settings
		max=255;
	}
	
//ends user input

//Begins image processes for single image mode:
currentImage = getTitle();
selectImage(currentImage); 
processImageSingle(degreeStep, lineLength, scaleFactor, cropChoice, cropHeightChoice, cropSize, xpoints, ypoints, thresholdPercent, thresholdChoice, min, max, binSize, directionChoice);

Dialog.create("Process Status"); //creates a little pop up to let the user know that the process has finished
	Dialog.addMessage("Image Processing Complete");
	Dialog.show();

	selectWindow("Results"); //records parameters at the end of the results table so the user can easily keep track of them
		setResult("Label", nResults, "");
		setResult("Label", nResults, "Analysis Parameters:");
		setResult("Label", nResults, "Degrees of Rotation:"+ degreeStep);
		setResult("Label", nResults, "Line Length:"+ lineLength +" px");
		setResult("Label", nResults, "Threshold Settings:"+ thresholdPercent+ "%");
		setResult("Label", nResults, "Orientation Measurement: "+ directionChoice);


//Main image processing function
function processImageSingle(degreeStep, lineLength, scaleFactor, cropChoice, cropHeightChoice, cropSize, xpoints, ypoints, thresholdPercent, thresholdChoice, min, max, binSize, directionChoice)
	{
    originalFileName = getTitle();
    filename = getTitle(); //get file title and remove the .tif so we can use it later as the new saved name
		filename = replace(filename, ".tif", ""); 
		filename = replace(filename, ".jpg", "");
		filename = replace(filename, ".png", "");
		filename = replace(filename, ".bmp", "");
	
	//creating blank variables tables that will be needed later
	allDistances= newArray();
    Table.create("CompleteDataFile");
	Table.setLocationAndSize(100,100,400,400);
	Table.create("CompleteFrequencyData");
	selectWindow("CompleteFrequencyData"); 
	Table.setLocationAndSize(150,150,400,400);
	Table.set("distance", 0,0);	
	if (directionChoice == "OrientationJ" || directionChoice == "Directionality") 
	{
		Table.create("CompleteOrientationData");
		Table.setLocationAndSize(200,200,400,400);
	}
	    

    for (i=0; i<180; i=i+degreeStep) //for each image, goes through the image processing steps a set number of time, based on selected rotation angle
	{	
		selectImage(originalFileName);
		run("Duplicate...", " ");
		
		if (cropChoice == true) //only happens if user indictated cropping is necessary. 
		{
			setTool("rectangle");  
			makeRectangle(xpoints[0],ypoints[0], xpoints[1]-xpoints[0], ypoints[3]-ypoints[0]);  //upper left corner, width, height, based on previously user defined rectangle
			run("Crop"); 	
		}

		else if (cropHeightChoice == true)
		{
			setTool("rectangle");  
			makeRectangle(0,ypoints[0], getWidth(), ypoints[1]);  //upper left corner, width, height, based on previously user defined rectangle
			run("Crop"); 
			
		}
	
		//ensures basic image characteristics are correct
		run("8-bit");   
		run("Colors...", "foreground=black background=black selection=yellow");  
		
		//runs optional orientation analysis based off of existing plugins
		if (i == 0 && directionChoice == "Directionality") 
		{
			run("Directionality", "method=[Fourier components] nbins=90 histogram_start=-90 histogram_end=90 display_table");
			
			shortFilename = replace(filename, " ", "");
			dirTableName = "Directionality histograms for "+shortFilename+"-1 (using Fourier components)";
			selectWindow(dirTableName);
			directionX = Table.getColumn("Direction ("+fromCharCode(176)+")");
			directionY = Table.getColumn(shortFilename+"-1");
			directionFit = Table.getColumn(shortFilename+"-1-fit");

			selectWindow("CompleteOrientationData");
			Table.setColumn("Direction ("+fromCharCode(176)+")", directionX); 
			Table.setColumn(filename+"_Frequency", directionY); 
			Table.setColumn(filename+"_Fit", directionFit); 
			
			Fit.doFit("gaussian", directionX, directionY);
						
			directionValue= Fit.p(2);
			dispersionValue= Fit.p(3);
			goodnessValue= Fit.rSquared;

		}

		if (i == 0 && directionChoice == "OrientationJ") 
		{
				currentDuplicate = getTitle();
				run("OrientationJ Distribution", "log=0.0 tensor=9.0 gradient=0 min-coherency=5.0 min-energy=0.0 s-distribution=on hue=Gradient-X sat=Gradient-X bri=Gradient-X ");
				Plot.getValues(directionX, directionY);
				Fit.doFit("gaussian", directionX, directionY);
				Fit.plot;
				Plot.getValues(xpointsOther, directionFit);
				close("S-Distribution-1");
				selectWindow("y = a + (b-a)*exp(-(x-c)*(x-c)/(2*d*d))");
				rename(filename + "_Orientation _Histogram");
				
				selectWindow("CompleteOrientationData");
				Table.setColumn("Direction (degree)", directionX); 
				Table.setColumn(filename+ "_Frequency", directionY); 
				Table.setColumn(filename+"_Fit", directionFit); 
						
				directionValue= Fit.p(2);
				dispersionValue= Fit.p(3);
				goodnessValue= Fit.rSquared;

				selectImage(currentDuplicate);

		}
		
		//finds edges and then thresholds to black and white
		run("Find Edges");   
		run("Threshold...");
		
		//Thresholding is calculated for each image individually, based on user-provided percentage of included pixels
		getHistogram(ImageHistValues, ImageHistCounts, 256);
		Array.getStatistics(ImageHistCounts, min, max, ImageHistMean);
		ImageHistTotal = ImageHistMean*ImageHistCounts.length;
		ThresholdTotal = (thresholdPercent*0.01)*ImageHistTotal;
		CumulativeTotal = 0;
		ThresholdBin = 255;

		while (CumulativeTotal < ThresholdTotal) 
		{
			CumulativeTotal = CumulativeTotal + ImageHistCounts[ThresholdBin];
			ThresholdBin=ThresholdBin-1;
		}

		ThresholdMinBin = ThresholdBin+1;
		setThreshold(ThresholdMinBin, 255);
		run("Convert to Mask");
		close("Threshold");
		//thresholdImage = getTitle();
		rename(filename +"_"+ i +"_thresholded");
			
		//rotates the thresholded image to the current angle (always starts with 0°)
		run("Rotate...", "angle="+i+" grid=1 interpolation=None fill"); 

		//Runs a morphological filter on the rotated, thresholded image. aA horizontal line of a user-defined length is used for first erosion and then dilation
		//!!! "Morphological Filters" is a Plugin that needs to be added to imageJ for this to work
		run("Morphological Filters", "operation=Erosion element=[Horizontal Line] radius=" + lineLength);
		erosionImage = getTitle();
		run("Morphological Filters", "operation=Dilation element=[Horizontal Line] radius=" + lineLength);
		close(erosionImage);
		rename(filename + "_"+ i +"_filtered");
		

		ImageWidth = getWidth();
		for (ii = 0; ii < getWidth(); ii++) //Loop to scans through each pixel column. 
		{
			makeLine(ii, 0, ii, getHeight());//draws a vertical line through a single columm of pixels. 
			profile = getProfile();//this returns the grayscale values for each pixel in the current column and saves as an array	
			peaks = newArray();//the peak locations will be saved
			
			peaks = Array.findMaxima(profile, 1);//this function finds the pixel location of each peak from the profile. 
			
			if (peaks.length > 1) //some columns might not have any pixels or only 1. We only care if there are at least 2 peaks present to represent a measurable distance. 
			{
				
				tempDistances = newArray(peaks.length-1); //this temp array stores the distances just from the current image. 
			
				for (j = 0; j < tempDistances.length; j++) //measures the pixel distance between each peak and saves it as 1 distance measurement
				{
			    	tempDistances[j] = (peaks[j]-peaks[j+1])*(1/scaleFactor);
				}
			
				allDistances = Array.concat(allDistances,tempDistances); //adds the distances measured in this rotated image to the all of the previous from the same image at other rotations
			}					
		}		    
	}
		
	selectWindow("CompleteDataFile"); 
	Table.setColumn(filename+"_allDistances", allDistances);

	//makes a histogram from all of the vertical distance measurements. This histogram is used to calculate the mean fiber diamter. 
	Plot.create("Histogram", "measured value", "frequency");
	Plot.addHistogram(allDistances,binSize);
	Plot.show();
		
	Plot.getValues(xpoints, ypoints);
	run("Close");
		
	selectWindow("CompleteFrequencyData"); 

	if (Table.size < xpoints.length) 
	{
		Table.setColumn("distance", xpoints);	
	}
		
	Table.setColumn(filename, ypoints);

	Fit.doFit("gaussian", xpoints, ypoints); //fitting the histogram data with a gaussian model
	Fit.plot;
		
	PlotLimit = (ImageWidth/scaleFactor)/4; //sets the plot width as a quarter of the image width.
	Plot.setLimits(0, PlotLimit , 0, NaN);
		
	Plot.setColor("black");
	Plot.add("bars",xpoints, ypoints);
	Plot.setXYLabels("Units", "Frequency");
				
	Plot.getValues(xpoints2, fitValues);
	selectWindow("CompleteFrequencyData"); 
	Table.setColumn(filename + "_Fit", fitValues);
	//Gaussian fit parameters:
	a = Fit.p(0);
	b = Fit.p(1);
	c = Fit.p(2); //mean (peak centerpoint)
	d = Fit.p(3); //standard deviation (peak width)
	r = Fit.rSquared;

	//puts the results into the results table 	
	setResult("Diameter Mean", 0, c);
	setResult("Diameter SDEV", 0, d);
	setResult("Diameter Rsqr", 0, r);
	setResult("# of Observations", 0, allDistances.length); 
	setResult("Label", 0, filename);
		
	if (directionChoice == "OrientationJ" || directionChoice == "Directionality") //only adds orientation results to table is necessary
	{
		setResult("Orientation Mean (degree)", 0, directionValue);
		setResult("Orientation SDEV (degree)", 0, dispersionValue);
		setResult("Orientation Rsqr", 0, goodnessValue);
	}
	updateResults();
}	
}  //end of single image mode code    





//code for batch processing mode, macro runs through a directory of images and processes each one. Results are saved in an output folder
else if (cmd=="Batch Process") 
{
run("Clear Results"); 
run("Set Measurements...", "nan redirect=None decimal=3");

// Batch mode is necessary so all of the processing steps aren't actually shown. makes the program much faster.
setBatchMode(true); 

// Creating the initial dialog GUI so the user can input directory locations, setting and image processing parameters
Dialog.create("New Analysis");
Dialog.setInsets(0, 0, 0);
Dialog.addMessage("Select the locations of the Input and Output folders:",12,"627791");
Dialog.setInsets(0, 20, 0);
Dialog.addDirectory("Choose Input Directory",""); 
Dialog.addDirectory("Choose Output Directory",""); 
Dialog.setInsets(0, 60, 0);
Dialog.addCheckbox("Save image processing intermediates (edge detection & morphological filtering)", true);	
Dialog.addString("Add the following label to all saved file names:","");
	
Dialog.setInsets(0, 0, 0);
Dialog.addMessage("Set parameters for GIFT:",12,"627791");
Dialog.addNumber("Degree of rotation:", 45);
Dialog.setInsets(0,0,0);
Dialog.addNumber("Filter Line Length:", 8);
Dialog.setInsets(0, 0, 0);
Dialog.addNumber("Enter the threshold percent value:", 5);
Dialog.setInsets(0, 60, 0);
Dialog.addCheckbox("Or check to manually set image thresholding based on the first image in the folder", false);
Dialog.addNumber("Set bin size for distance histograms:", 1);

Dialog.setInsets(0, 0, 0);
Dialog.addMessage("Set image parameters:",12,"627791");
Dialog.setInsets(0, 20, 0);
Dialog.addMessage("Set the image's scale with known values, enter 1 for both values to measure in pixels or check the box to manually set scale on image.");
Dialog.addNumber("Distance in pixels:", "1");
Dialog.addNumber("Known distance:", "1");
Dialog.setInsets(0, 60, 0);
Dialog.addCheckbox("Manually set scale based on the first image in the folder", false);
	
Dialog.setInsets(0, 20, 0);
Dialog.addMessage("To crop the image enter the height of the area to be analysed, measured from top of image. Or check box to crop manually.");
Dialog.setInsets(0, 60, 0);
Dialog.addCheckbox("Define image area to be analysed by known height", false);
Dialog.setInsets(0, 60, 0);
Dialog.addNumber("Height of imaged area (pixels):", "");
		
Dialog.setInsets(0, 60, 0);
Dialog.addCheckbox("Check to manually select the area to be analysed", false);

Dialog.setInsets(0, 0, 0);
Dialog.addMessage("Fiber orientation measurement:",12,"627791");
Dialog.setInsets(0, 20, 0);
Dialog.addMessage("GIFT can run existing ImageJ Plugins for orientation measurement during analysis for convienence. (Longer run time)");
options = newArray("None","OrientationJ","Directionality");
Dialog.addChoice("Choose plugin", options, options[0]);
	
Dialog.show();
	
//assign variables based on user input
inputDirectory = Dialog.getString();
outputDirectory = Dialog.getString();
outputChoice = Dialog.getCheckbox();
labelString = Dialog.getString();
degreeStep = Dialog.getNumber();
lineLength = Dialog.getNumber();
thresholdPercent = Dialog.getNumber();
thresholdChoice = Dialog.getCheckbox();
binSize=Dialog.getNumber();
pixelDistance = Dialog.getNumber();
knownDistance = Dialog.getNumber();
scaleChoice = Dialog.getCheckbox();
cropHeightChoice = Dialog.getCheckbox();
cropSize = Dialog.getNumber();
cropChoice = Dialog.getCheckbox();
directionChoice = Dialog.getChoice();

if (labelString != "") //adding a "_" to the label string so it can be easily added to saved filenames later
{
	labelString=labelString +"_";
}

//check to make sure variable are not missing and are appropriate (i.e. negative) 
if (inputDirectory == "" || outputDirectory == "") 
{
	exit("No input or output directory selected");
}
if (isNaN(degreeStep) || degreeStep < 0) 
{
	exit("Invalid value for degree of rotation (must be positive)");
}
if (isNaN(lineLength) || lineLength < 0) 
{
	exit("Invalid value for line length (must be positive)");
}
if (isNaN(thresholdPercent) || thresholdPercent < 0) 
{
	exit("Invalid value for threshold value (must be positive)");
}
if (isNaN(binSize) || binSize < 0) 
{
	exit("Invalid value for bin size (must be positive)");
}

// Get the list of files from the input directory
// NOTE: if there are non-image files in this directory, it may cause the macro to crash. 
fileList = getFileList(inputDirectory);
scaleFactor = pixelDistance/knownDistance; 

//Additional user interactions if manual cropping, scale or threshold is selected.
if (cropHeightChoice == true && cropChoice == true)
{
	exit("User selected both cropping methods, please selection only one.");
}
	
else if (cropHeightChoice == false && cropChoice == true)
{
	
	setBatchMode(false);//need to turn off batch mode temporarily.
	open(inputDirectory + File.separator + fileList[0]); //offers the user the first image in the directory to select the crop area
	setTool(0);
	waitForUser("Please select the area of the image to be analysed. Click OK when done");
	
	if (is("area")==false)
	{
		exit("no crop area selection made");
	}
	
	getSelectionCoordinates(xpoints, ypoints);	
	close();
	setBatchMode(true);
}
else if (cropHeightChoice == true && cropChoice == false)
{
	if (isNaN(cropSize) || cropSize < 1)
	{
		exit("Invalid height value entered");
	}

	xpoints=newArray(1);//leave this as a dummy arry for now. Later x values based on image size.  
	ypoints=newArray(0, cropSize);
}

else 
{
	xpoints=newArray(1);//if no cropping needed these dummy arrays are created. 
	ypoints=newArray(1);
}

if (scaleChoice == true)
{
	setBatchMode(false);
	open(inputDirectory + File.separator + fileList[0]); //offers the user the first image in the directory to select the scale
	setBatchMode("Show");
	setTool("Line");
	waitForUser("Please select the length of the scalebar. Click OK when done");
	
	if (is("line")==false)
	{
		exit("no line selecion made");
	}

	getLine(x1, y1, x2, y2, lineWidth);	
	scaleLength = abs(x2-x1);
	
	Dialog.create("Enter Scale");
	Dialog.addNumber("Scalebar length:", "");
	Dialog.show();
	pixelLength = Dialog.getNumber();

	if (isNaN(pixelLength) || pixelLength < 0) 
	{
		exit("Invalid value for scale length (must be positive)");
	}
	
	scaleFactor = scaleLength/pixelLength;
	close();
	setBatchMode(true);
}

if (thresholdChoice == true)
{
	open(inputDirectory + File.separator + fileList[0]); //offers the user the first image in the directory to set threshold
	setBatchMode("Show");

	if (cropChoice == true) //Its important to remove any scale bar area before determining threshold levels
	{
		setTool("rectangle");  
		makeRectangle(xpoints[0],ypoints[0], xpoints[1]-xpoints[0], ypoints[3]-ypoints[0]);  //upper left corner, width, height, based on previously user defined rectangle
		run("Crop"); 	
	}

	else if (cropHeightChoice == true)
	{
		setTool("rectangle");  
		makeRectangle(0,ypoints[0], getWidth(), ypoints[1]);  //upper left corner, width, height, based on previously user defined rectangle
		run("Crop"); 
	}
	
	run("8-bit");   
	run("Colors...", "foreground=black background=black selection=yellow");  
	run("Find Edges");   	
	 
	run("Threshold..."); 
	getHistogram(ImageHistValues, ImageHistCounts, 255);
	Array.getStatistics(ImageHistCounts, min, max, ImageHistMean);
	ImageHistTotal = ImageHistMean*ImageHistCounts.length;
	setThreshold(100, 255, "red");
	waitForUser("Adjust min/max sliders to desired levels. \n Adjust so that the edges are highlighted with clean red lines. \n Click OK when done. \n IMPORTANT: Do not click set or adjust.");
	//getMinAndMax(min, max);
	getThreshold(min, max);
	binSum = 0;

	for (bin = min; bin < 255; bin++) 
	{
		binSum = binSum + ImageHistCounts[bin];
	}

	thresholdPercent = binSum/ImageHistTotal*100;
	
}

else 
{
	min=200; //default settings
	max=255;
}

close("*");
//ends user input


//Loop opens every image in the input directory and sends it to the processImage function. Passes all the user input variables.
for (i = 0; i < fileList.length; i++)
	{
    processImage(inputDirectory, outputDirectory, fileList[i], i, degreeStep, lineLength, scaleFactor, cropChoice, cropHeightChoice, cropSize, xpoints, ypoints, thresholdPercent, thresholdChoice, min, max, binSize, outputChoice, labelString, directionChoice);
	}

setBatchMode(false); 

Dialog.create("Process Status"); //creates a little pop up to let the user know that the process has finished and five saving options
Dialog.addMessage("Image Processing Complete");
Dialog.addMessage("Would you like to save the your results?");
items =newArray("Don't Save","Save as .txt","Save as .CSV","Save as .xls");
Dialog.addChoice("Save options", items);
Dialog.show();
saveChoice = Dialog.getChoice();

selectWindow("Results"); //records parameters at the end of the results table so the user can easily keep track of them
setResult("Label", nResults, "");
setResult("Label", nResults, "Analysis Parameters:");
setResult("Label", nResults, "Degrees of Rotation:"+ degreeStep);
setResult("Label", nResults, "Line Length:"+ lineLength +" px");
setResult("Label", nResults, "Threshold Settings:"+ thresholdPercent +"%");
setResult("Label", nResults, "Orientation Measurement: "+ directionChoice);

if (saveChoice == "Save as .txt") 
{
	selectWindow("Results");
	saveAs("Text", outputDirectory + File.separator + labelString + "BatchResults.txt");
			
	selectWindow("CompleteDataFile");
	saveAs("Text", outputDirectory + File.separator + labelString + "CompleteDataFile.txt");
			
	selectWindow("CompleteFrequencyData");
	saveAs("Text", outputDirectory + File.separator + labelString + "CompleteFrequencyFile.txt");

	if (directionChoice != "None")
	{
		selectWindow("CompleteOrientationData");
		saveAs("Text", outputDirectory + File.separator + labelString + "CompleteOrientationFile.txt");
	}

}

if (saveChoice == "Save as .CSV") 
{
	selectWindow("Results");
	saveAs("Text", outputDirectory + File.separator + labelString + "BatchResults.csv");
			
	selectWindow("CompleteDataFile");
	saveAs("Text", outputDirectory + File.separator + labelString + "CompleteDataFile.csv");

	selectWindow("CompleteFrequencyData");
	saveAs("Text", outputDirectory + File.separator + labelString + "CompleteFrequencyFile.csv");

	if (directionChoice != "None")
	{
		selectWindow("CompleteOrientationData");
		saveAs("Text", outputDirectory + File.separator + labelString + "CompleteOrientationFile.csv");
	}
		
}
	
if (saveChoice == "Save as .xls") 
{
	selectWindow("Results");
		
	saveAs("Text", outputDirectory + File.separator + labelString + "BatchResults.xls");
			
	selectWindow("CompleteDataFile");
	saveAs("Text", outputDirectory + File.separator + labelString + "CompleteDataFile.xls");

	selectWindow("CompleteFrequencyData");
	saveAs("Text", outputDirectory + File.separator + labelString + "CompleteFrequencyFile.xls");
		
	if (directionChoice != "None")
	{
		selectWindow("CompleteOrientationData");
		saveAs("Text", outputDirectory + File.separator + labelString + "CompleteOrientationFile.xls");
	}	
}


//Main image processing function, which is run on every image in the input directory
function processImage(inputDirectory, outputDirectory, imageFile, imageCount, degreeStep, lineLength, scaleFactor, cropChoice, cropHeightChoice, cropSize, xpoints, ypoints, thresholdPercent, thresholdChoice, min, max, binSize, outputChoice, labelString, directionChoice)
{
    open(inputDirectory + File.separator + imageFile); //open current image

    filename = getTitle(); //get file title and remove the .tif so we can use it later as the new saved name
	filename = replace(filename, ".tif", ""); 
	filename = replace(filename, ".jpg", "");
	filename = replace(filename, ".png", "");
	filename = replace(filename, ".bmp", "");
	
	allDistances= newArray();
    
    if (imageCount == 0)  //only runs the first time through so it doesn't clear with every loop. Has to be created inside function.
	{
	    Table.create("CompleteDataFile");
	    Table.setLocationAndSize(100,100,400,400);
	    Table.create("CompleteFrequencyData");
	    selectWindow("CompleteFrequencyData"); 
	    Table.setLocationAndSize(150,150,400,400);
		Table.set("distance", 0,0);	

		if (directionChoice == "OrientationJ" || directionChoice == "Directionality") 
		{
			Table.create("CompleteOrientationData");
		    Table.setLocationAndSize(200,200,400,400);
		}
	}

    for (i=0; i<180; i=i+degreeStep) //for each image, goes through the image processing steps a set number of time, based on selected rotation angle
	{	
		open(inputDirectory + File.separator + imageFile); //this line needs to be repeated, so the original image is opened each time, rather than the newly processed one

		if (cropChoice == true) //only happens if user indictated cropping is necessary. 
		{
			setTool("rectangle");  
			makeRectangle(xpoints[0],ypoints[0], xpoints[1]-xpoints[0], ypoints[3]-ypoints[0]);  //upper left corner, width, height, based on previously user defined rectangle
			run("Crop"); 	
		}

		else if (cropHeightChoice == true)
		{
			setTool("rectangle");  
			makeRectangle(0,ypoints[0], getWidth(), ypoints[1]); 
			run("Crop"); 
			
		}
	
		//ensures basic image characteristics are correct
		run("8-bit");   
		run("Colors...", "foreground=black background=black selection=yellow");  
		
		//runs optional orientation analysis based off of existing plugins
		if (i == 0 && directionChoice == "Directionality") 
		{
			run("Directionality", "method=[Fourier components] nbins=90 histogram_start=-90 histogram_end=90 display_table");
			
			shortFilename = replace(filename, " ", "");
			dirTableName = "Directionality histograms for "+shortFilename+" (using Fourier components)";
			selectWindow(dirTableName);
			directionX = Table.getColumn("Direction ("+fromCharCode(176)+")");
			directionY = Table.getColumn(shortFilename);
			directionFit = Table.getColumn(shortFilename+"-fit");
	
			selectWindow("CompleteOrientationData");
			Table.setColumn("Direction ("+fromCharCode(176)+")", directionX); 
			Table.setColumn(filename+"_Frequency", directionY); 
			Table.setColumn(filename+"_Fit", directionFit); 
			
			Fit.doFit("gaussian", directionX, directionY);
						
			directionValue= Fit.p(2);
			dispersionValue= Fit.p(3);
			goodnessValue= Fit.rSquared;
		}

		if (i == 0 && directionChoice == "OrientationJ") 
		{
				run("OrientationJ Distribution", "log=0.0 tensor=9.0 gradient=0 min-coherency=5.0 min-energy=0.0 s-distribution=on hue=Gradient-X sat=Gradient-X bri=Gradient-X ");
				Plot.getValues(directionX, directionY);
				Fit.doFit("gaussian", directionX, directionY);
				Fit.plot;
				Plot.getValues(xpointsOther, directionFit);
				close("S-Distribution-1");
				close("y = a + (b-a)*exp(-(x-c)*(x-c)/(2*d*d))");

				selectWindow("CompleteOrientationData");
				Table.setColumn("Direction (degree)", directionX); 
				Table.setColumn(filename+ "_Frequency", directionY); 
				Table.setColumn(filename+"_Fit", directionFit); 
						
				directionValue= Fit.p(2);
				dispersionValue= Fit.p(3);
				goodnessValue= Fit.rSquared;

		}
		
		//finds edges and then thresholds to black and white
		run("Find Edges");   
		run("Threshold...");
		
		//thresholding calculated for each image, based on user-provided percentage of included pixels
		getHistogram(ImageHistValues, ImageHistCounts, 256);
		Array.getStatistics(ImageHistCounts, min, max, ImageHistMean);
		ImageHistTotal = ImageHistMean*ImageHistCounts.length;
		ThresholdTotal = (thresholdPercent*0.01)*ImageHistTotal;
		CumulativeTotal = 0;
		ThresholdBin = 255;

		while (CumulativeTotal < ThresholdTotal) 
		{
			CumulativeTotal = CumulativeTotal + ImageHistCounts[ThresholdBin];
			ThresholdBin=ThresholdBin-1;
		}

		ThresholdMinBin = ThresholdBin+1;
		setThreshold(ThresholdMinBin, 255);
		run("Convert to Mask");
		close("Threshold");
			
		//rotates the thresholded image to the current angle (always starts with 0°) and saves 
		run("Rotate...", "angle="+i+" grid=1 interpolation=None fill"); 

		if (outputChoice == true) //only happens if user decided to save intermediate images. 
		{
			saveAs("Tiff", outputDirectory + File.separator + labelString + filename + "_Edges_" +i);
		}
		

		//Runs a morphological filter on the rotated, thresholded image. a horizontal line of a userdefined length is used for first erosion and then dilation
		//!!! "Morphological Filters" is a Plugin that needs to be added to imageJ for this to work
		run("Morphological Filters", "operation=Erosion element=[Horizontal Line] radius=" + lineLength);
		run("Morphological Filters", "operation=Dilation element=[Horizontal Line] radius=" + lineLength);

		if (outputChoice == true) //only happens if user decided to save images. 
		{
			saveAs("Tiff", outputDirectory + File.separator + labelString + filename + "_Filtered_" +i); //file names end with the rotation angle
		}
		
		ImageWidth = getWidth();
		for (ii = 0; ii < getWidth(); ii++) //Loop to scans through each pixel column. Right its a manual number (so 1000 columns), but later that will be set to fit the input image width.
		{
			makeLine(ii, 0, ii, getHeight());//draws a vertical line through a single columm of pixels. 
			profile = getProfile();//this returns the grayscale values for each pixel in the current column and saves as an array	
			peaks = newArray();//this is where the peak locations will be saved, needs to be cleared out for each repetition
			peaks = Array.findMaxima(profile, 1);//this function finds the pixel location of each peak from the profile. 
			
			if (peaks.length > 1) //some columns might not have any pixels or only 1. We only care if there are at least 2 peaks present to represent a measurable distance. 
			{
				tempDistances = newArray(peaks.length-1); //this temp array stores the distances just from the current image. 
			
				for (j = 0; j < tempDistances.length; j++) //measures the pixel distance between each peak and saves it as 1 distance measurement
				{
			    	tempDistances[j] = (peaks[j]-peaks[j+1])*(1/scaleFactor);
				}
			
				allDistances = Array.concat(allDistances,tempDistances); //adds the distances measured in this rotated image to the all of the previous from the same image at other rotations
			}							
		}		    
	}

		selectWindow("CompleteDataFile"); 
		Table.setColumn(filename+"_allDistances", allDistances);
	
		//Creates hitogram from all measured distances. this histogram is used to calculate mean fiber diameter.
		Plot.create("Histogram", "measured value", "frequency");
		Plot.addHistogram(allDistances,binSize);
		Plot.show();
		
		Plot.getValues(xpoints, ypoints);
		close("*");
		selectWindow("CompleteFrequencyData"); 

		if (Table.size < xpoints.length) 
			{
			Table.setColumn("distance", xpoints);	
			}
		
		Table.setColumn(filename, ypoints);
		
		Fit.doFit("gaussian", xpoints, ypoints);
		Fit.plot;
		
		PlotLimit = (ImageWidth/scaleFactor)/4;//plot width set to a quarter of the image size
		Plot.setLimits(0, PlotLimit , 0, NaN);
		Plot.setColor("black");
		Plot.add("bars",xpoints, ypoints);
		Plot.setXYLabels("Units", "Frequency");
		
		saveAs("Tiff", outputDirectory + File.separator + labelString + "Histogram_modifiable_" + filename); //Tiff file type can be opened in ImageJ and edits and altered, but does not open as an image
		saveAs("PNG", outputDirectory + File.separator + labelString +"Histogram_" + filename); //PNG can be opened in a normal image viewer and used for pulications, but can't be modified in imageJ 
					
		Plot.getValues(xpoints2, fitValues);
		selectWindow("CompleteFrequencyData"); 
		Table.setColumn(filename + "_Fit", fitValues);
		
		//gaussian fit parameters		
		a = Fit.p(0);
		b = Fit.p(1);
		c = Fit.p(2); //mean (peak centerpoint)
		d = Fit.p(3); //standard deviation (peak width)
		r = Fit.rSquared;
		
		//add results to the results table		
		setResult("Diameter Mean", imageCount, c);
		setResult("Diameter SDEV", imageCount, d);
		setResult("Diameter Rsqr", imageCount, r);
		setResult("# of Observations", imageCount, allDistances.length); 
		setResult("Label", imageCount, filename);
		
		if (directionChoice == "OrientationJ" || directionChoice == "Directionality") //adds orientation results if necessary
			{
			setResult("Orientation Mean (degree)", imageCount, directionValue);
			setResult("Orientation SDEV (degree)", imageCount, dispersionValue);
			setResult("Orientation Rsqr", imageCount, goodnessValue);
			}
	updateResults();
		
    close("*");  // Closes all images
 
} //end of processImage function
} //end Batch process option from tool
} //end of menu tool
