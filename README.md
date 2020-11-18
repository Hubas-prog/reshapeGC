# reshapeGC

Object : Data processing of GC-FID. Give absolute and relative concentrations of fatty acid data from raw .TXT files of Varian GC.

How to use it :

1- Download the zip file and unzip

2- Open reshapeGC.Rproj in R studio

3- Add all raw Varian .txt files to your Rproj directory according to the following format https://github.com/Hubas-prog/Paradendryphiella_traject/blob/master/02LDT18S1.txt

4- open and run the whole gc.process.R script

5- Check the folder "tables". You will find the relative fatty acid concentration table (FA.table.percent.txt) and a file named fill.C23.txt

6- Open fill.C23.txt and add C23 internal standard and sample weights (in mg) and rename the file fill.C23copy.txt

7- open and run the whole gc.process.R script a second time

8- Check the folder "tables". You will find the absolute fatty acid concentration table (A.table.conc.txt)
