/* Test-only namespaced definition from Integrading Results through Meta analytic review using sas software.txt; original SHA256 f63cfce2d421001032ac4d02d46bce886b5da4aca1149083dc7ddecf9e3bac37. */
%macro n26_wavgeff(indata,outdata,level);
/********************************************************/
/*  INDATA:  The input data set name                    */
/*    The macro assumes that the:                       */
/*       (1) variable name for the effect-size estimate */
/*    is EFF                                            */
/*    Note that EFF can be any of the following effect  */
/*    size estimators: Hedges' g, Hedges' gu, Cohen's d, */
/*    point-biseral correlation, or Fisher's z.         */
/*       (2) variable name for the corresponding        */
/*    variance is VEFF                                  */
/*                                                      */
/*  OUTDATA: The output data file name                  */
/*  The output data file contains four variables        */
/*                                                      */
/*      (1) ESTIMATE:  Combined estimate for the effect */
/*              size                                    */
/*      (2) LOWER: Lower bound for confidence interval  */
/*      (3) UPPER: Upper bound for confidence interval  */
/*      (4) LEVEL: Level of confidence for the          */
/*      confidence interval.                            */
/*                                                      */
/*    LEVEL:  Level of the confidence of the confidence */
/*            interval                                  */
/********************************************************/
data;
   set &indata;
   weight = 1 / veff;
   keep eff veff weight &varlist;
proc sort;
   by &varlist;
proc means noprint;
   var eff;
   weight weight;
   by &varlist;
   output out=&outdata mean=meff sumwgt=invvar;
run;
data &outdata;
   set &outdata;
   estimate = meff;
   level=&level;
   variance = 1 / invvar;
   std = sqrt(1/invvar);
   lower = estimate + probit(.5-.5*level)*std;
   upper = estimate + probit(.5+.5*level)*std;
   keep &varlist estimate variance level lower upper;
run;
%mend n26_wavgeff;
