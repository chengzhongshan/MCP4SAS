/* Test-only namespaced definition from Integrading Results through Meta analytic review using sas software.txt; original SHA256 f63cfce2d421001032ac4d02d46bce886b5da4aca1149083dc7ddecf9e3bac37. */
%macro n26_compeff(indata,outdata);
/*****************************************************/
/*  INDATA:  Input data set name                     */
/*  OUTDATA:  Output data set name                   */
/*                                                   */
/*  NE:  Experimental group sample size              */
/*  NC:  Control group sample size                   */
/*  ME:  Experimental group sample mean              */
/*  MC:  Control group sample mean                   */
/*  SE:  Experimental group standard deviation       */
/*  SC:  Control group standard deviation            */
/*                                                   */
/* OUTPUT DATA:                                      */
/*  TYPE:  0 = Glass' delta                          */
/*         1 = Cohen's d                             */
/*         2 = Hedges' g                             */
/*         3 = Hedges' gu                            */
/*         4 = Point biserial correlation rpb        */
/*  ESTIMATE:  Effect-size estimate                  */
/*  STD:  Estimated standard deviation for           */
/*        effect-size estimate                       */
/*  LOWER:  Lower bound of 95% confidence interval   */
/*  UPPER:  Upper bound of 95% confidence interval   */
/*****************************************************/
data &outdata;  set &indata;
   dfd = ne+nc;
   dfg = dfd-2;
/*****************************************************/
/*  Compute Glass's delta                            */
/*****************************************************/
   del = (me-mc)/sc;
   vdel = dfd/(ne*nc)+(del*del)/(2*nc-2);
   sdel = sqrt(vdel);
/*****************************************************/
/*  Compute Cohen's d                                */
/*****************************************************/
   sm = sqrt(((ne-1)*(se*se)+(nc-1)*(sc*sc))/dfd);
   dd = (me-mc)/sm;
   vdd = dfd/(ne*nc)+0.5*dd*dd/dfg;
   sdd = sqrt(vdd);
/*****************************************************/
/*  Compute Hedges' g                                */
/*****************************************************/
   sp = sqrt(((ne-1)*(se*se)+(nc-1)*(sc*sc))/dfg);
   gg = (me-mc)/sp;
   vgg = dfd/(ne*nc)+0.5*gg*gg/dfg;
   sgg = sqrt(vgg);
/*****************************************************/
/*  Compute Hedges' gu                               */
/*****************************************************/
   corrf=exp(lgamma(0.5*dfg)-lgamma(0.5*(dfg-1))
      -log(sqrt(0.5*dfg)));
   gu = gg * corrf;
   vgu = dfd/(ne*nc)+0.5*gu*gu/dfd;
   sgu = sqrt(vgu);
/*****************************************************/
/*  Compute point-biserial correlation rpb           */
/*****************************************************/
   rpb = sqrt((ne*nc*dd*dd)/(ne*nc*dd*dd+dfd*dfd));
   zrpb = 0.5*log((1+rpb)/(1-rpb));
   vzrpb = 1 / (dfd-3);
   szrpb = sqrt(vzrpb);
   type = 0;
   estimate = del;
   std = sdel;
   lower = del + probit(0.025) * sdel;
   upper = del + probit(0.975) * sdel;
   output;
   type = 1;
   estimate = dd;
   std = sdd;
   lower = dd + probit(0.025) * sdd;
   upper = dd + probit(0.975) * sdd;
   output;
   type = 2;
   estimate = gg;
   std = sgg;
   lower = gg + probit(0.025) * sgg;
   upper = gg + probit(0.975) * sgg;
   output;
   type = 3;
   estimate = gu;
   std = sgu;
   lower = gu + probit(0.025) * sgu;
   upper = gu + probit(0.975) * sgu;
   output;
   type = 4;
   estimate = rpb;
   std = szrpb;
   lower = zrpb + probit(0.025) * szrpb;
   upper = zrpb + probit(0.975) * szrpb;
   lower = (exp(2*lower)-1)/(exp(2*lower)+1);
   upper = (exp(2*upper)-1)/(exp(2*upper)+1);
   output;
   keep ne nc me mc se sc type estimate lower upper;
%mend n26_compeff;
