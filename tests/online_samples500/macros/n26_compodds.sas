/* Test-only namespaced definition from Integrading Results through Meta analytic review using sas software.txt; original SHA256 f63cfce2d421001032ac4d02d46bce886b5da4aca1149083dc7ddecf9e3bac37. */
%macro n26_compodds(indata,outdata);
/********************************************************/
/*  INDATA:                                             */
/*     N11: Sample frequency  for cell (1,1)            */
/*     N12: Sample frequency  for cell (1,2)            */
/*     N21: Sample frequency  for cell (2,1)            */
/*     N22: Sample frequency  for cell (2,2)            */
/*                                                      */
/*  OUTDATA:                                            */
/*     TYPE:                                            */
/*        TYPE=1:       Log odds ratio                  */
/*        TYPE=2:       Odds ratio                      */
/*        TYPE=3:       Amended log odds ratio          */
/*        TYPE=4:       Amended odds ratio              */
/*     ESTIAMTE: Sample estimate for given TYPE         */
/*     LOWER:  Lower bound for 95% confidence interval  */
/*     UPPER:  Upper bound for 95% confidence interval  */
/*     VARIANCE:                                        */
/********************************************************/
data &outdata; set &indata;
   if (n11 = 0 or n12 = 0 or n21 = 0 or n22 = 0) then do;
      odds = .;
      logodds = .;
      variance = .;
      std = .;
      end;
   else do;
      odds = (n11*n22)/(n12*n21);
      variance = 1/n11+1/n12+1/n21+1/n22;
      logodds = log(odds);
      std = sqrt(variance);
   end;
   type = 1;
   estimate = logodds;
   lower = logodds + probit(0.025) * std;
   upper = logodds + probit(0.975) * std;
   output;
   type = 2;
   estimate = odds;
   lower = exp(lower);
   upper = exp(upper);
   variance = .;
   output;
   odds = (n11+.5)*(n22+.5)/((n12+.5)*(n21+.5));
   variance = 1/(n11+.5)+1/(n12+.5)+1/(n21+.5)+1/(n22+.5);
   std = sqrt(variance);
   type = 3;
   estimate = log(odds);
   lower = estimate + probit(.025)*std;
   upper = estimate + probit(.975)*std;
   output;
   type = 4;
   estimate = odds;
   lower = exp(lower);
   upper = exp(upper);
   variance = .;
   output;
   keep type estimate lower upper variance;
%mend n26_compodds;
