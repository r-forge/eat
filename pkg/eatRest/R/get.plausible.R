####################################################################################################################
#
# get.plausible
# liest von Conquest erzeugte plausible values (*.pv) als R-Objekte ein
#
# Version: 	2.5.0
# Depends: reshape
# Imports: reshape
# Published:
# Author:  Sebastian Weirich
# Maintainer:
#
#
# Change log:
#
# 2011-12-05 SW
# FIXED: get.plausible() now reads files with negatives values < -10
# 0000-00-00 AA
#
#
# 25.11.2011, SW: "cat" durch "eatTools:::sunk" ersetzt
# * zu 1.0.2 (2011-10-04, NH): bugfix: kann jetzt wieder ein- und mehrdimensionale Skalierungen lesen
# * zu 1.0.1 (2011-10-03, NH): liest Dimensionsnamen aus lab file, wenn lab file im Arbeitsordner liegt.
#
# 20.10.2011 SW/MH: auf development gesetzt da buggy
# 20.10.2011 MH: library statement auskommentiert
# 12.10.2011 MH: auf stable gesetzt wegen besserer sourcebarkeit
# 08.08.2011 MH: auf stable gesetzt wegen besserer sourcebarkeit
# 14.01.2011, SW: Funktion �bernimmt nun auch IDs, sofern sie im von Conquest
#                 erzeugten pv-File enthalten sind.
#
####################################################################################################################

get.plausible <- function (file) {
    funVersion <- "get.plausible_2.5.0"

	# if (!exists("melt")) {
        # library(reshape)
    # }
	
# input <- read.table(file, sep = "", header = FALSE, fill = TRUE, stringsAsFactors = FALSE)
	input           <- scan(file,what="character",sep="\n",quiet=TRUE)
  input           <- crop(gsub("-"," -",input) )              ### crop dauert hier zu lange
  input           <- strsplit(input," +")                     ### Untere Zeile gibt die maximale Spaltenanzahl
  n.spalten       <- max ( sapply(input,FUN=function(ii){ length(ii) }) )
  input           <- data.frame( matrix( t( sapply(input,FUN=function(ii){ ii[1:n.spalten] }) ),length(input),byrow=F), stringsAsFactors=F)

	# find number of PVs per person
    nPersonPVs <- sum(input[-1, 1] == 1:(nrow(input) - 1))
    
	# find number of persons
	nPerson <- nrow(input)/(nPersonPVs + 3)
    
	# keep only rows which contain PVs
	isPVrow <- c ( FALSE, rep ( rep ( c(TRUE, FALSE), times = c ( nPersonPVs, 3 )), nPerson))
	isPVrow <- isPVrow [ - length(isPVrow) ]
	output <- input [ isPVrow, ]
	
	# find number of dimensions and dimension names from lab file
### MH 1.3.12 
### das ist hier suboptimal, wenn der plausible values file nicht die Endung "pvl" hat, crasht das alles sp�ter
### die Idee ist aber gut, ich versuche das zu optimieren
#	lab.file <- gsub("pvl", "lab", file ) 
	lab.file <- gsub ( "\\.[^\\.]+$" , ".lab", file )


	
	# set default
	dimNames <- NULL
  if(!file.exists(lab.file)) {
    eatTools:::sunk(paste(funVersion, ": Expected label file '",lab.file,"' was not found. Dimension(s) will be labeled by default as 'dim'.\n",sep=""))
  }  
  # if label file exists, default will be replaced

### MH 1.3.12
### jobFolder auf getwd() setzen ist hochgradig gef�hrlich!!!
### Trennung von wd und lab.file falls lab.file mit path, man kann/sollte auch nicht davon ausgehen, das lab.file in getwd() ist
# wd <- gsub ( "(.*)/[^/]+$" , "\\1", lab.file )
# if ( identical ( wd , file ) ) wd <- getwd()
# lab.file <- gsub ( "(.*)/([^/]+)$" , "\\2", lab.file )

  if (file.exists(lab.file)) {	
		# dimNames <- getDimensionNames (lab.file = lab.file, jobFolder = getwd(), lab.file.only = TRUE ) 
		dimensionNames <- getDimnamesFromLabfile (lab.file = lab.file ) 
		nDimensions <- length(dimensionNames)
	}
	
	if (is.null(dimensionNames)) {
		nDimensions <- ncol(output) - 1
		dimensionNames <- paste (rep("dim", nDimensions), 1:nDimensions , sep = ".")
	}
    eatTools:::sunk(paste(funVersion, ": Found ", nPerson, " person(s) and ", nDimensions, " dimension(s).\n",sep=""))
    eatTools:::sunk(paste(funVersion, ": Found ", nPersonPVs, " plausible values for each person and each dimension.\n",sep=""))
	

	# name output cols
	output         <- data.frame(sapply(output, FUN=function(ii) {as.numeric(ii)}),stringsAsFactors=FALSE)
	outputColNames <- c("PVno", paste ( rep( "pv", nDimensions), dimensionNames, sep = ".") )
	colnames(output) <- outputColNames
    
	# find case IDs - every (nPersonPVs + 3) rows
	isCaseIDrow <- c ( TRUE, rep( rep ( c(FALSE, TRUE), times = c ( nPersonPVs + 2, 1)), nPerson )) 
	isCaseIDrow <- isCaseIDrow [ - length(isCaseIDrow) ]
	cases <- input[isCaseIDrow, 1:2]
	colnames(cases) <-  c( "case", "ID")
	cases$case <- as.numeric(cases$case)
	
	# find EAPs and posterior standard deviations - all rows that have not been used before
	isIDorPVrow <- isCaseIDrow + isPVrow  
  posteriorStats <- input [ ! isIDorPVrow , 1:nDimensions,drop=FALSE]
  posteriorStats <- data.frame(sapply(posteriorStats, FUN=function(ii) {as.numeric(ii)}),stringsAsFactors=FALSE)
  if ( mode (posteriorStats) == "numeric" ) {
	 posteriorStats <- matrix (posteriorStats, ncol=nDimensions, byrow=TRUE  )
 }
	posteriorStatsColNames <- dimensionNames 
	colnames(posteriorStats) <- posteriorStatsColNames
	posteriorStats <- data.frame ( case = rep ( cases [ , 1], each = 2), parameter =  c ( "eap", "eap.se" ), posteriorStats , stringsAsFactors = FALSE)  
	posteriorStats <- melt ( posteriorStats, id.vars = c("case", "parameter") )
	posteriorStats$variable = paste ( posteriorStats$parameter, posteriorStats$variable, sep = ".")
	posteriorStats <- cast (posteriorStats, case ~ variable)
	
	# repeat each row in cases nPersonPVs times
	options (warn = -1)
	cases <- do.call ( "rbind" , mapply ( function ( n , d ) d , 1:nPersonPVs , MoreArgs = list ( cases ) , SIMPLIFY = FALSE ) )
	cases <- cases [ order ( cases$case ) , ]
	
	if ( all ( is.na ( cases$ID ) ) )  {
		cases$ID <- gsub(" ", "0", formatC ( cases$case , width = max ( nchar ( cases$case ) ) ) )
	}
	options (warn = 0)
	output <- data.frame ( cases, output, stringsAsFactors = FALSE )
 	
	# reshape output
	output <- recast(output, id.var = c( "case", "ID", "PVno"), formula = case + ID ~ variable + PVno)

	# merge output & posteriorStats
	output <- merge ( output, posteriorStats, by = "case", all = TRUE ) 

    return(output)
}