// $Id: unquadify.m,v 1.3 2013/02/16 16:11:44 rok Exp $
// Usage: $ARG[0] -r rows -c columns -i INPUTFILE [-o OUTFILE]

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreImage.h>

CGFloat rows = 0.0, columns = 0.0;
NSString *infile = nil;
NSString *outbase = nil;
BOOL quicktime = NO;

void
usage()
{
    NSLog(@"Usage: $ARG[0] [-q BOOL] [-r rows -c columns] [-o OUTPUTFILE]  -i INPUTFILE\n");
}

void
getOpt()
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    rows = [defaults  floatForKey: @"r"];
    columns = [defaults  floatForKey: @"c"];
    // check values for left, top, width, heigh, right, bottom HERE!
    infile = [defaults stringForKey: @"i"];
    outbase = [defaults stringForKey: @"o"];
    quicktime = [defaults boolForKey: @"q"];
}

CGPoint
getRowsAndColumns(CIImage *image)
{
    CGFloat r, c;
    CGRect imageRect = [image extent];
    CGSize size = imageRect.size;
    CGPoint ret = {1.0, 1.0};			// temporarily set value for debug
    return ret;
}

NSData *
bitmapDataForCroppedImageWithRCAtXY(
    CIImage *image,
    int r, int c, int x, int y
){
    CGRect rect = [image extent];
    CGFloat width = rect.size.width / c;
    CGFloat height = rect.size.height / r;
    CGRect croppingRect = {{ x * width, rect.size.height - (y + 1) * height },
			   { width, height }};
    CIImage *croppedImage = [image imageByCroppingToRect: croppingRect];
    NSBitmapImageRep *bitmapRep = 
	[[NSBitmapImageRep alloc] initWithCIImage: croppedImage];
    NSData *data = [bitmapRep representationUsingType: NSBitmapImageFileTypeJPEG
	properties: [NSDictionary dictionary]];
    [bitmapRep release];
    return data;
}

int
main(int argc, char *argv[])
{
    int i;
    NSURL *url = nil;
    CGFloat width, height;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    getOpt();

    if(infile)
	url = [NSURL fileURLWithPath: infile];
    else{
	usage();
	exit(1);
    }
    if(!url){
	exit(1);
    }
	
    if(!outbase){
	// only last .jpg must be deleted ...
	outbase = [infile stringByReplacingOccurrencesOfString: @".jpg" 
	    withString: @""];
	outbase = [outbase stringByReplacingOccurrencesOfString: @".JPG" 
	    withString: @""];
    }

    NSFileManager *fm = [NSFileManager defaultManager];
    CIImage *ciimage = [CIImage imageWithContentsOfURL: url];
    if(!ciimage){
	exit(2);
    }

    int x, y;
    NSString *outPath;
    for(y = 0; y < rows; y++){
	for(x = 0; x < columns; x++){
	    NSData *data = 
		bitmapDataForCroppedImageWithRCAtXY(ciimage, rows, columns, x, y);
	    if(quicktime)
		outPath = [outbase stringByAppendingFormat: @"-%d%d.jpg",(int)y,(int)x];
	    else
		outPath = [outbase stringByAppendingFormat: @"-%dx%d.jpg",(int)y,(int)x];
// NSLog(outPath);
	    if([fm createFileAtPath: outPath contents: nil attributes: nil]){
		NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath: outPath];
		[fh writeData: data];
		[fh closeFile];
	    }
	}
    }

    [pool release];
    return 0;
}
