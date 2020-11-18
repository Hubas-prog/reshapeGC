########################### R SCRIPT ################################
# GC data processing
# Corresponding author : cedric.hubas@mnhn.fr
# Credits : Script = C.H.
########################### R SCRIPT ################################

#####################
# PACKAGES
#####################
library(reshape)

#####################
# DATA UPLOAD
#####################

# file extraction and upload ####################
files <- list.files(pattern="*.txt") # if path changed use argument path = path
List <- lapply(files, function(x) read.table(x,skip=1)[,c(2,4)])

# Modify list names ####################
pos.point <- regexpr(".",files,fix=T) # use regular expression to find position of symbol "."
new.file.name <- substr(files, 1, pos.point-1)
names(List) <- new.file.name 
List

#####################
# DATA PROCESSING
#####################

# Remove internal standard (IS) ####################
List.WithoutC23 <- lapply(List, function(x)
	{vector=x[,1]!="23:0"
	x[vector,]
	})

# Caculate percentages ####################
percent <- lapply(List.WithoutC23, function(x)
	{fa=x[,2]
	total=sum(fa)
	data.frame(FA=x[,1],percent=fa/total*100)
	})

# Filter: remove peaks with percentage < threshold ####################
threshold <- 0
V <- lapply(percent,function(x) # identify peaks < threshold, generate TRUE/FALSE vector "V"
		{vector=x[,2]>= threshold
		})
super.list <- mapply(cbind, List.WithoutC23, V, SIMPLIFY=FALSE) # merge both lists

List.WithoutC23.WithoutThreshold <- lapply(super.list, function(x)
	{vector=x[,3]== TRUE
	x[vector,]
	})

# Caculate percentages again ####################
percent2 <- lapply(List.WithoutC23.WithoutThreshold, function(x)
	{fa=x[,2]
	total=sum(fa)
	data.frame(FA=x[,1],percent=fa/total*100)
	})

# Filter verification ####################
unlist(lapply(percent2, function(x) return(sum(x$percent/sum(x$percent)*100)))) # must give 100% 

#####################
# PERCENTAGES
#####################

dat <- do.call(rbind,percent2) # equivalent to function unlist
pos.point2 <- regexpr(".",rownames(dat),fix=T) # use regular expression to find position of symbol "."
new.file.name2 <- substr(rownames(dat), 1, pos.point2-1) # retrieve sample names
dat2 <- data.frame(dat,group=new.file.name2)
data.m <- melt(dat2,id=c(1,3),measure=c(2)) 
table <- cast(data.m, group ~ FA,sum)
table[is.na(table)] <- 0 ; table
colnames(table) <- gsub("w","n-",colnames(table))

# Optional ####################
#write.table(table,paste(getwd(),"/tables/FA.table.percent.txt",sep=""))

#####################
# CONCENTRATIONS
#####################

C.FA <- do.call(rbind,List)
pos.point3 <- regexpr(".",rownames(C.FA),fix=T) # use regular expression to find position of symbol "."
new.CFA.name <- substr(rownames(C.FA), 1, pos.point3-1) # retrieve sample names
C.FA2 <- data.frame(C.FA,group=new.CFA.name) 
C.FA2.m <- melt(C.FA2,id=c(1,3),measure=c(2)) 
table.C.FA=cast(C.FA2.m, group ~ V2,sum) 
table.C.FA[is.na(table.C.FA)] <- 0 ; table.C.FA
fill.C23 <- data.frame(names=table.C.FA$group,C23mg=NA,Echmg=NA)
write.table(fill.C23,paste(getwd(),"/tables/fill.C23.txt",sep=""))

# Import IS table ####################
# fill and import fill.C23copy.txt file
imported.C23 <- read.table(paste(getwd(),"/tables/fill.C23copy.txt",sep=""),h=T) 

column <- colnames(table.C.FA)!="23:0" # remove IS column
inv.column <- colnames(table.C.FA)=="23:0" # retreive IS column
Final.table.C.FA <- table.C.FA[,column] 
VectorC23 <- table.C.FA[,inv.column] # extract IS column
Concentration <- (imported.C23$C23mg*Final.table.C.FA[,-1])*1000/(VectorC23*imported.C23$Echmg) # calculate concentrations
Concentration$group <- table$group
colnames(Concentration) <- gsub("w","n-",colnames(Concentration))

# Optional ####################
#write.table(Concentration,paste(getwd(),"/tables/FA.table.conc.txt",sep=""))
