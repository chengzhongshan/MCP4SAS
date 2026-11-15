/* Test-only namespaced definition from FileOrDirExist.sas; original SHA256 4e37b547e3db4d597cde1bcf59fd90bdcf2e5e085b73164e5923f53fde39a135. */
%macro n26_FileOrDirExist(dir) ; 
   %LOCAL rc fileref return; 

   %*arbitrarily assign value 0 to output if dir is empty;
   %*This will avoid of error message issued by fexist later;
   %if %length(&dir)=0 %then %do;
          0
    %end;
	%*It is necessary to add else do macro statement here, otherwise, even if the above is true, later codes will still run by sas;
    %else %do;

   %let rc = %sysfunc(filename(fileref,&dir)) ; 
/*    %if &rc=0 and %sysfunc(fexist(&fileref))  %then %let return=1;     */
/*    %else %let return=0; */
/*    &return */
%*The above failed in SAS OnDemand but works in Windows;
%*The reason is because the sas funciton will return these sas comments if not escaped by %;
%*Note: it is necessary to assign &fileref but not fileref to fexist here!;
   %if %sysevalf(&rc=0 and %symexist(fileref) and %sysfunc(fexist(&fileref)))  %then %do;
       1
   %end;
   %else %do;
       0
   %end;
%end;

%mend;
