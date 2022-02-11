/*
 * Ballistics model is based on GNU Ballistics library (v0.201)
 * and licensed with GNU GPL. The original library can be found at
 * https://sourceforge.net/projects/ballisticslib/
 */
using BallisticUnitConversions as BUC;
using Toybox.Math as Math;
using BallisticsModel as BM;

module BallisticsModel {

	const GRAVITY = -32.194; // unit feet / (sec^2)
	const BCOMP_MAXRANGE = 1100.0;
	const DRAG_G1 = "G1";
	const DRAG_G2 = "G2";
	const DRAG_G5 = "G5";
	const DRAG_G6 = "G6";
	const DRAG_G7 = "G7";
	const DRAG_G8 = "G8";


	 
    // calculates number of clicks the sight needs to be adjusted
	function calculateClickCorrection(corrMoa, sightClickMoa) 
	{
        var fullClicks = (corrMoa.abs() / sightClickMoa.abs()).toNumber(); // only decimal part is returned
        if(((corrMoa.abs() / sightClickMoa.abs()) - fullClicks) > 0.5) {
        	fullClicks = fullClicks+1;
    	}
    	if(corrMoa < 0) {
    		fullClicks = fullClicks * -1;
		}
    	return fullClicks;
	}
	// Athmospheric corrections
	/// ############ Functions for correcting for atmosphere.
	function calcFR(temperature, pressure, relHumid){
		var VPw = 4e-6 * Math.pow(temperature,3) - 0.0004*Math.pow(temperature,2) + 0.0234 * temperature-0.2517;
		var FRH = 0.995 * (pressure / (pressure - (0.3783) * (relHumid) * VPw));
		return FRH;
	}
	
	function calcFP(pressure){
		return (pressure-29.53) / (29.53); // 29.53 = Pstd in-hg
	}
	
	function calcFT(temperature, altitude){
		var Tstd = -0.0036 * altitude+59;
		return (temperature - Tstd) / (459.6 + Tstd);
	}
	
	function calcFA(altitude){
		var fa = -4e-15 *Math.pow(altitude,3) + 4e-10 * Math.pow(altitude,2) - 3e-5*altitude+1;
		return (1/fa);
	}
// A function to correct a "standard" Drag Coefficient for differing atmospheric conditions.
// Returns the corrected drag coefficient for supplied drag coefficient and atmospheric conditions.
/* Arguments:
		dragCoefficient:  The coefficient of drag for a given projectile.
		altitude:  The altitude above sea level in feet.  Standard altitude is 0 feet above sea level.
		pressure:  The barometric pressure in inches of mercury (in Hg).
					This is not "absolute" pressure, it is the "standardized" pressure reported in the papers and news.
					Standard pressure is 29.53 in Hg.
		temperature:  The temperature in Fahrenheit.  Standard temperature is 59 degrees.
		relHumidity:  The relative humidity fraction.  Ranges from 0.00 to 1.00, with 0.50 being 50% relative humidity.
							Standard humidity is 78%

	Return Value:
		The function returns a ballistic coefficient, corrected for the supplied atmospheric conditions.
*/
	function atmCorrect(dragCoefficient, altitude, pressure, temperature, relHumidity){
	
		var FA = calcFA(altitude);
		var FT = calcFT(temperature, altitude);
		var FR = calcFR(temperature, pressure, relHumidity);
		var FP = calcFP(pressure);
	
		// Calculate the atmospheric correction factor
		var CD = (FA*(1+FT-FP)*FR);
		return dragCoefficient*CD;
	}

	// Headwind is positive at WindAngle=0
	function headWind(windSpeed, windAngle){
		var wAngle = degToRad(windAngle);
		return (Math.cos(wAngle)*windSpeed);
	}
	
	// Positive is from Shooter's Right to Left (Wind from 90 degree)
	function crossWind(windSpeed, windAngle){
		var wAngle = degToRad(windAngle);
		return (Math.sin(wAngle)*windSpeed);
	}
	
	// Specialty angular conversion functions
	function degToRad(deg) {
		return deg*Math.PI/180;
	}
	
	function MOAToRad(moa) {
		return moa/60*Math.PI/180;
	}
	function radToDeg(rad) {
		return rad*180/Math.PI;
	}
	function radToMOA(rad) {
		return rad*60*180/Math.PI;
	}
		// ############ Functions for correcting for ballistic drag.
	function retard(dragFunction, dragCoefficient, velocity){
		
	
		var vp = velocity;	
		var val = -1.0;
		var A = -1.0;
		var M = -1.0;
		if(dragFunction.equals(DRAG_G1)) {
			if (vp > 4230) { A = 1.477404177730177e-4; M = 1.9565; }
			else if (vp> 3680) { A = 1.920339268755614e-4; M = 1.925 ; }
			else if (vp> 3450) { A = 2.894751026819746e-4; M = 1.875 ; }
			else if (vp> 3295) { A = 4.349905111115636e-4; M = 1.825 ; }
			else if (vp> 3130) { A = 6.520421871892662e-4; M = 1.775 ; }
			else if (vp> 2960) { A = 9.748073694078696e-4; M = 1.725 ; }
			else if (vp> 2830) { A = 1.453721560187286e-3; M = 1.675 ; }
			else if (vp> 2680) { A = 2.162887202930376e-3; M = 1.625 ; }
			else if (vp> 2460) { A = 3.209559783129881e-3; M = 1.575 ; }
			else if (vp> 2225) { A = 3.904368218691249e-3; M = 1.55  ; }
			else if (vp> 2015) { A = 3.222942271262336e-3; M = 1.575 ; }
			else if (vp> 1890) { A = 2.203329542297809e-3; M = 1.625 ; }
			else if (vp> 1810) { A = 1.511001028891904e-3; M = 1.675 ; }
			else if (vp> 1730) { A = 8.609957592468259e-4; M = 1.75  ; }
			else if (vp> 1595) { A = 4.086146797305117e-4; M = 1.85  ; }
			else if (vp> 1520) { A = 1.954473210037398e-4; M = 1.95  ; }
			else if (vp> 1420) { A = 5.431896266462351e-5; M = 2.125 ; }
			else if (vp> 1360) { A = 8.847742581674416e-6; M = 2.375 ; }
			else if (vp> 1315) { A = 1.456922328720298e-6; M = 2.625 ; }
			else if (vp> 1280) { A = 2.419485191895565e-7; M = 2.875 ; }
			else if (vp> 1220) { A = 1.657956321067612e-8; M = 3.25  ; }
			else if (vp> 1185) { A = 4.745469537157371e-10; M = 3.75  ; }
			else if (vp> 1150) { A = 1.379746590025088e-11; M = 4.25  ; }
			else if (vp> 1100) { A = 4.070157961147882e-13; M = 4.75  ; }
			else if (vp> 1060) { A = 2.938236954847331e-14; M = 5.125 ; }
			else if (vp> 1025) { A = 1.228597370774746e-14; M = 5.25  ; }
			else if (vp>  980) { A = 2.916938264100495e-14; M = 5.125 ; }
			else if (vp>  945) { A = 3.855099424807451e-13; M = 4.75  ; }
			else if (vp>  905) { A = 1.185097045689854e-11; M = 4.25  ; }
			else if (vp>  860) { A = 3.566129470974951e-10; M = 3.75  ; }
			else if (vp>  810) { A = 1.045513263966272e-8; M = 3.25  ; }
			else if (vp>  780) { A = 1.291159200846216e-7; M = 2.875 ; }
			else if (vp>  750) { A = 6.824429329105383e-7; M = 2.625 ; }
			else if (vp>  700) { A = 3.569169672385163e-6; M = 2.375 ; }
			else if (vp>  640) { A = 1.839015095899579e-5; M = 2.125 ; }
			else if (vp>  600) { A = 5.71117468873424e-5 ; M = 1.950 ; }
			else if (vp>  550) { A = 9.226557091973427e-5; M = 1.875 ; }
			else if (vp>  250) { A = 9.337991957131389e-5; M = 1.875 ; }
			else if (vp>  100) { A = 7.225247327590413e-5; M = 1.925 ; }
			else if (vp>   65) { A = 5.792684957074546e-5; M = 1.975 ; }
			else if (vp>    0) { A = 5.206214107320588e-5; M = 2.000 ; }
		} else if(dragFunction.equals(DRAG_G2)) {
			if (vp> 1674 ) { A = .0079470052136733   ;  M = 1.36999902851493; }
			else if (vp> 1172 ) { A = 1.00419763721974e-3;  M = 1.65392237010294; }
			else if (vp> 1060 ) { A = 7.15571228255369e-23;  M = 7.91913562392361; }
			else if (vp>  949 ) { A = 1.39589807205091e-10;  M = 3.81439537623717; }
			else if (vp>  670 ) { A = 2.34364342818625e-4;  M = 1.71869536324748; }
			else if (vp>  335 ) { A = 1.77962438921838e-4;  M = 1.76877550388679; }
			else if (vp>    0 ) { A = 5.18033561289704e-5;  M = 1.98160270524632; }
		}  else if(dragFunction.equals(DRAG_G5)) {
			if (vp> 1730 ){ A = 7.24854775171929e-3; M = 1.41538574492812; }
			else if (vp> 1228 ){ A = 3.50563361516117e-5; M = 2.13077307854948; }
			else if (vp> 1116 ){ A = 1.84029481181151e-13; M = 4.81927320350395; }
			else if (vp> 1004 ){ A = 1.34713064017409e-22; M = 7.8100555281422 ; }
			else if (vp>  837 ){ A = 1.03965974081168e-7; M = 2.84204791809926; }
			else if (vp>  335 ){ A = 1.09301593869823e-4; M = 1.81096361579504; }
			else if (vp>    0 ){ A = 3.51963178524273e-5; M = 2.00477856801111; }	
		} else if(dragFunction.equals(DRAG_G6)) {
			if (vp> 3236 ) { A = 0.0455384883480781   ; M = 1.15997674041274; }
			else if (vp> 2065 ) { A = 7.167261849653769e-2; M = 1.10704436538885; }
			else if (vp> 1311 ) { A = 1.66676386084348e-3 ; M = 1.60085100195952; }
			else if (vp> 1144 ) { A = 1.01482730119215e-7 ; M = 2.9569674731838 ; }
			else if (vp> 1004 ) { A = 4.31542773103552e-18 ; M = 6.34106317069757; }
			else if (vp>  670 ) { A = 2.04835650496866e-5 ; M = 2.11688446325998; }
			else if (vp>    0 ) { A = 7.50912466084823e-5 ; M = 1.92031057847052; }
		} else if(dragFunction.equals(DRAG_G7)) {
			if (vp> 4200 ) { A = 1.29081656775919e-9; M = 3.24121295355962; }
			else if (vp> 3000 ) { A = 0.0171422231434847  ; M = 1.27907168025204; }
			else if (vp> 1470 ) { A = 2.33355948302505e-3; M = 1.52693913274526; }
			else if (vp> 1260 ) { A = 7.97592111627665e-4; M = 1.67688974440324; }
			else if (vp> 1110 ) { A = 5.71086414289273e-12; M = 4.3212826264889 ; }
			else if (vp>  960 ) { A = 3.02865108244904e-17; M = 5.99074203776707; }
			else if (vp>  670 ) { A = 7.52285155782535e-6; M = 2.1738019851075 ; }
			else if (vp>  540 ) { A = 1.31766281225189e-5; M = 2.08774690257991; }
			else if (vp>    0 ) { A = 1.34504843776525e-5; M = 2.08702306738884; }
		} else if(dragFunction.equals(DRAG_G8)) {
			if (vp> 3571 ) { A = .0112263766252305   ; M = 1.33207346655961; }
			else if (vp> 1841 ) { A = .0167252613732636   ; M = 1.28662041261785; }
			else if (vp> 1120 ) { A = 2.20172456619625e-3; M = 1.55636358091189; }
			else if (vp> 1088 ) { A = 2.0538037167098e-16 ; M = 5.80410776994789; }
			else if (vp>  976 ) { A = 5.92182174254121e-12; M = 4.29275576134191; }
			else if (vp>    0 ) { A = 4.3917343795117e-5 ; M = 1.99978116283334; }
		}
	
		if (A!=-1 && M!=-1 && vp>0 && vp<10000){
			val=A*Math.pow(vp,M)/dragCoefficient;
			return val;
		} else {
			return -1;
		}
	}
	// abs implementation
	function fabs(val) {
		if(val < 0) {
			return -1 * val;
		}
		return val;
	}
	
	function windage(windSpeed, Vi, xx, t){
		var Vw = windSpeed*17.60; // Convert to inches per second.
		return (Vw*(t-xx/Vi));
	}

	// This function is not used, it's an one-function implementation of ZeroAngleSolver
	function getZeroAngle(DragFunction, DragCoefficient, Vi, SightHeight, ZeroRange, yIntercept) {
		var t = 0.0;
		var dt = 1.0/Vi; // The solution accuracy generally doesn't suffer if its within a foot for each second of time.
		var y = -1 * SightHeight/12.0;
		var x = 0.0;
		var da; // The change in the bore angle used to iterate in on the correct zero angle.

		// State variables for each integration loop.
		var v = 0.0;
		var vx = 0.0;
		var vy = 0.0; // velocity
		var vx1 = 0.0;
		var vy1 = 0.0; // Last frame's velocity, used for computing average velocity.
		var dv = 0.0;
		var dvx = 0.0;
		var dvy = 0.0; // acceleration
		var Gx = 0.0;
		var Gy = 0.0; // Gravitational acceleration
		var angle = 0.0; // The actual angle of the bore.
		var quit = 0; // We know it's time to quit our successive approximation loop when this is 1.
		
		da = BM.degToRad(14);

		for(angle = 0; quit == 0; angle = angle+da) {
			var sinAngle = Math.sin(angle);
			var cosAngle = Math.cos(angle);
			vy=Vi*sinAngle;
			vx=Vi*cosAngle;
			Gx=BM.GRAVITY*sinAngle;
			Gy=BM.GRAVITY*cosAngle;
			for(t=0,x=0,y=-1*SightHeight/12.0; x <= ZeroRange*3; t=t+dt) {
				vy1=vy;
				vx1=vx;
				v=Math.pow((Math.pow(vx,2)+Math.pow(vy,2)),0.5);
				dt=1/v;
				
				dv = BM.retard(DragFunction, DragCoefficient, v);
				
				dvy = -dv*vy/v*dt;
				dvx = -dv*vx/v*dt;
		
				vx=vx+dvx;
				vy=vy+dvy;
				vy=vy+dt*Gy;
				vx=vx+dt*Gx;
				
				x=x+dt*(vx+vx1)/2;
				y=y+dt*(vy+vy1)/2;
				
				// Break early to save CPU time if we won't find a solution.
				if (vy<0 && y<yIntercept) {
					break;
				}
				if (vy>3*vx) {
					break;
				}
			}	
			if (y>yIntercept && da>0){
				da = -1 * da/2;
			}
	
			if (y<yIntercept && da<0){
				da = -1 * da/2;
			}
	
			if (BM.fabs(da) < BM.MOAToRad(0.01)) {
				quit=1; // If our accuracy is sufficient, we can stop approximating.
			}
			if (angle > BM.degToRad(45.0)) {
				quit=1; // If we exceed the 45 degree launch angle, then the projectile just won't get there, so we stop trying.
			}
		}
		return BM.radToDeg(angle);

	}
	
}
class ZeroAngleResolver 
{
	var t = 0.0;
	var dt; // The solution accuracy generally doesn't suffer if its within a foot for each second of time.
	var y, x=0.0;
	var da; // The change in the bore angle used to iterate in on the correct zero angle.

	// State variables for each integration loop.
	var v = 0.0;
	var vx = 0.0;
	var vy = 0.0; // velocity
	var vx1 = 0.0;
	var vy1 = 0.0; // Last frame's velocity, used for computing average velocity.
	var dv = 0.0;
	var dvx = 0.0;
	var dvy = 0.0; // acceleration
	var Gx = 0.0;
	var Gy = 0.0; // Gravitational acceleration
	var angle = 0.0; // The actual angle of the bore.
	var quit = 0; // We know it's time to quit our successive approximation loop when this is 1.
	
	var dragFunction, dragCoefficient, Vi, sightHeight, zeroRange, yIntercept;
	
	// outer loop state
	var sinAngle, cosAngle;
	
	var outerLoop = true;
	
	//Arguments: 
	//	DragFunction:  The drag function to use (G1, G2, G3, G5, G6, G7, G8)
	//	DragCoefficient:  The coefficient of drag for the projectile, for the supplied drag function.
	//	Vi:  The initial velocity of the projectile, in feet/s
	//	SightHeight:  The height of the sighting system above the bore centerline, in inches. 
	//				  Most scopes fall in the 1.6 to 2.0 inch range.
	//	ZeroRange:  The range in yards, at which you wish the projectile to intersect yIntercept.
	//	yIntercept:  The height, in inches, you wish for the projectile to be when it crosses ZeroRange yards.
	//				This is usually 0 for a target zero, but could be any number.  For example if you wish
	//				to sight your rifle in 1.5" high at 100 yds, then you would set yIntercept to 1.5, and ZeroRange to 100
	//				
	//Return Value:
	//	Returns the angle of the bore relative to the sighting system, in degrees.
	
	function initialize(pDragFunction, pDragCoefficient, pVi, pSightHeight, pZeroRange, pYIntercept) 
	{
	
		// Numerical Integration variables
		dt = 1.0/pVi; // The solution accuracy generally doesn't suffer if its within a foot for each second of time.
		y = -1 * pSightHeight/12.0;
		dragFunction = pDragFunction;
		dragCoefficient = pDragCoefficient;
		Vi = pVi;
		sightHeight = pSightHeight;
		zeroRange = pZeroRange;
		yIntercept = pYIntercept;

		// Start with a very coarse angular change, to quickly solve even large launch angle problems.
		da = BM.degToRad(14);
		
		outerLoop = true;

	}
	
	function solve() {

	}

	function iterate() 
	{
		if(outerLoop) {
			sinAngle = Math.sin(angle);
			cosAngle = Math.cos(angle);
			vy=Vi*sinAngle;
			vx=Vi*cosAngle;
			Gx=BM.GRAVITY*sinAngle;
			Gy=BM.GRAVITY*cosAngle;
			t=0;
			x=0; 
			y=-1*sightHeight/12.0;
			outerLoop = false;
		}
		// inner loop
			vy1=vy;
			vx1=vx;
			v=Math.pow((Math.pow(vx,2)+Math.pow(vy,2)),0.5);
			dt=1/v;
			
			dv = BM.retard(dragFunction, dragCoefficient, v);
			
			dvy = -dv*vy/v*dt;
			dvx = -dv*vx/v*dt;
	
			vx=vx+dvx;
			vy=vy+dvy;
			vy=vy+dt*Gy;
			vx=vx+dt*Gx;
			
			x=x+dt*(vx+vx1)/2;
			y=y+dt*(vy+vy1)/2;
			
			// Break early to save CPU time if we won't find a solution.
			if (vy<0 && y<yIntercept) {
				outerLoop = true;
				//break;
			}
			if (vy>3*vx && !outerLoop) {
				outerLoop = true;
				//break;
			}
		// inner loop ends
		
		// is next loop inner / outer
		// iteration condition
		if(!outerLoop && x>zeroRange*3.0) {
			outerLoop = true;
		} else {
			// iteration increment (inner loop)
			t=t+dt;
		}
		// inner loop finished, execute remainder of outer
		if(outerLoop) {
			
			if (y>yIntercept && da>0){
				da = -1 * da/2;
			}
	
			if (y<yIntercept && da<0){
				da = -1 * da/2;
			}
	
			if (BM.fabs(da) < BM.MOAToRad(0.01)) {
				quit=1; // If our accuracy is sufficient, we can stop approximating.
			}
			if (angle > BM.degToRad(45.0)) {
				quit=1; // If we exceed the 45 degree launch angle, then the projectile just won't get there, so we stop trying.
			}
		}
		
		
		if(!quit && outerLoop) {
			angle = angle + da;
		}
		return quit; // return true if result ready
	}
	
	function getResult() {
		return BM.radToDeg(angle); // Convert to degrees for return value.
	}
}

class RangeResolver 
{
	
	hidden var dragFunction; 
	hidden var dragCoefficient; 
	hidden var Vi; 
	
	var t=0.0; // time (s)
	var dt;
	var v=0.0; // speed
	var vx=0.0;
	var vx1=0.0;
	var vy=0.0;
	var vy1=0.0;
	var dv=0.0;
	var dvx=0.0;
	var dvy=0.0;
	var x=0.0;
	var y=0.0;
	var headwind;
	var crosswind;
	var Gy;
	var Gx;
	var n;
	
	var result = null;
	
	//		DragFunction:  The drag function you wish to use for the solution (G1, G2, G3, G5, G6, G7, or G8)
	//		DragCoefficient:  The coefficient of drag for the projectile you wish to model.
	//		Vi:  The projectile initial velocity.
	//		SightHeight:  The height of the sighting system above the bore centerline.  
	//						Most scopes are in the 1.5"-2.0" range.
	//		ShootingAngle:  The uphill or downhill shooting angle, in degrees.  Usually 0, but can be anything from
	//						90 (directly up), to -90 (directly down).
	//		ZeroAngle:  The angle of the sighting system relative to the bore, in degrees.  This can be easily computed
	//					using the ZeroAngle() function documented above.
	//		WindSpeed:  The wind velocity, in mi/hr
	//		WindAngle:  The angle at which the wind is approaching from, in degrees.
	//					0 degrees is a straight headwind
	//					90 degrees is from right to left
	//					180 degrees is a straight tailwind
	//					-90 or 270 degrees is from left to right.
	//		Solution:	A pointer provided for accessing the solution after it has been generated.
	//					Memory for this pointer is allocated in the function, so the user does not need
	//					to worry about it.  This solution can be passed to the retrieval functions to get
	//					useful data from the solution.
	function initialize(pRange_yds, pDragFunction, pDragCoefficient, pVi, pSightHeight, pShootingAngle, pZAngle, pWindSpeed, pWindAngle) {
		
		dragFunction = pDragFunction; 
		dragCoefficient = pDragCoefficient; 
		Vi = pVi; 
		
		dt = 0.5/Vi; // delta Time (s)
		headwind = BM.headWind(pWindSpeed, pWindAngle);
		crosswind = BM.crossWind(pWindSpeed, pWindAngle);
		Gy=BM.GRAVITY * Math.cos(BM.degToRad((pShootingAngle + pZAngle)));
		Gx=BM.GRAVITY * Math.sin(BM.degToRad((pShootingAngle + pZAngle)));
		vx=Vi * Math.cos(BM.degToRad(pZAngle));
		vy=Vi * Math.sin(BM.degToRad(pZAngle));
		y = -1 * pSightHeight/12; // convert to feet
		n=pRange_yds;
	}
	
	function iterate() 
	{
		vx1=vx;
		vy1=vy;	
		v=Math.pow(Math.pow(vx,2)+Math.pow(vy,2),0.5); // sqrt(vx^2+vy^2)
		dt=0.5/v;
	
		// Compute acceleration using the drag function retardation	
		dv = BM.retard(dragFunction,dragCoefficient,v+headwind);		
		dvx = -(vx/v)*dv;
		dvy = -(vy/v)*dv;

		// Compute velocity, including the resolved gravity vectors.	
		vx=vx + dt*dvx + dt*Gx;
		vy=vy + dt*dvy + dt*Gy;

		// x (feet) / 3 = yds
		if (x/3 >= n) {
			var windage_row = BM.windage(crosswind,Vi,x,t+dt); // Windage in inches
			
			//result = {
			//	"range" => x/3, // Range in yds
			//	"path" => y*12, // Path in inches
			//	"corrMOA" => -1 * model.radToMOA(Math.atan(y/x)), // Correction in MOA
			//	"velo" => v,// Velocity (combined)
			//	"velo_x" => vx,// Velocity (x)
			//	"velo_y" => vy,// Velocity (y)
			//	"time" => t+dt, // Time in s
			//	"windage" => windage_row,
			//	"windageMOA" => model.radToMOA(Math.atan((windage_row/12) / x)) // Windage in MOA
			//};
			result = new BUC.ResultFormatter(
				x/3, // Range in yds
				y*12, // Path in inches
				-1 * BM.radToMOA(Math.atan(y/x)), // Correction in MOA
				v,// Velocity (combined)
				vx,// Velocity (x)
				vy,// Velocity (y)
				t+dt, // Time in s
				windage_row,
				BM.radToMOA(Math.atan((windage_row/12) / x)) // Windage in MOA
			);
			return true;
				
		}	
		
		
		// Compute position based on average velocity.
		x=x+dt*(vx+vx1)/2;
		y=y+dt*(vy+vy1)/2;
		
		if (BM.fabs(vy) > BM.fabs(3*vx)) { 
			return false; // won't solve
		}
		if (n>=BM.BCOMP_MAXRANGE+1) {
			return false; // won't solve
		}
		t=t+dt; // loop increment
		return false;
	}
	
	function getResult() {
		return result;
	}
}