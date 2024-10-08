#' Export data for StreamThermal package
#'
#' Creates a date frame (and file export) from Continuous Data in the format
#' used by the StreamThermal package.
#'
#' Required fields are StationID, Date, dailyMax, dailyMin, and dailyMean
#' The fields are named "siteID", "Date", "MaxT", "MinT", and "MeanT".
#'
#' The StreamThermal package is available on GitHub.  It can be installed with
#' the devtools package:
#'
#' library(devtools)
#'
#' install_github("tsangyp/StreamThermal")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Erik.Leppo@tetratech.com (EWL)
# 20170920
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @param fun.myDF User data that has been through the QC process of ContDataQC.
#'   Required fields are SiteID, Date, Water.Temp.C (or as defined in config.R).
#' @param fun.col.SiteID Column name for SiteID.
#' Default = SiteID (as defined in config.R)
#' @param fun.col.Date Column name for SiteID.
#' Default = Date (as defined in config.R)
#' @param fun.col.Temp Column name for SiteID.
#' Default = Water.Temp.C (as defined in config.R)
#' @return Returns a data frame formatted for use with the R library
#' StreamThermal (SiteID, Date, MaxT, MinT, MeanT).  Statistics are calculated
#' in the function.
#' @keywords continuous data, StreamThermal
#' @examples
#' #~~~~~~~~~~~~~~~~~~~~~~
#' # Example 1, USGS data
#' #~~~~~~~~~~~~~~~~~~~~~~
#' library(dataRetrieval)
#' # 1.1. Get USGS data
#' # code from StreamThermal T_frequency example
#' ExUSGSStreamTemp<-readNWISdv("01382310","00010","2011-01-01","2011-12-31"
#'                              ,c("00001","00002","00003"))
#' sitedata<-subset(ExUSGSStreamTemp, select=c("site_no","Date"
#'                  ,"X_00010_00001","X_00010_00002","X_00010_00003"))
#' names(sitedata)<-c("siteID","Date","MaxT","MinT","MeanT")
#' #
#' # 1.2. Run StreamThermal
#' # Library (install if needed)
#' # devtools::install_github("tsangyp/StreamThermal")
#' # Library (load)
#' require(StreamThermal)
#' #~~~~~
#' # StreamThermal
#' (ST.freq <- T_frequency(sitedata))
#' (ST.mag  <- T_magnitude(sitedata))
#' (ST.roc  <- T_rateofchange(sitedata))
#' (ST.tim  <- T_timing(sitedata))
#' (ST.var  <- T_variability(sitedata)) # example in package doesn't work
#' #
#' #~~~~~~~~~~~~~~~~~~~~~~
#' # Example 2, ContDataQC Summary Stats Data
#' #~~~~~~~~~~~~~~~~~~~~~~
#' # 2.1. Load ContDataQC file that has been processed with SummaryStats
#' myFile <- "DATA_test2_Aw_20130101_20141231.csv"
#' myData <- read.csv(file.path(path.package("ContDataQC"),"extdata",myFile)
#'                    , stringsAsFactors=FALSE)
#' # Subset
#' Col.Keep <- c("SiteID", "Date", "Water.Temp.C")
#' sitedata <- myData[,Col.Keep]
#' #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' sitedata <- Export.StreamThermal(myData)
#' #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' # 2.2. Run StreamThermal
#' require(StreamThermal)
#' #~~~~~
#' # StreamThermal
#' (ST.freq <- T_frequency(sitedata))
#' (ST.mag  <- T_magnitude(sitedata))
#' (ST.roc  <- T_rateofchange(sitedata))
#' (ST.tim  <- T_timing(sitedata))
#' (ST.var  <- T_variability(sitedata))
#'
#'
#' #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' # Save Results to Excel (each group on its own worksheet)
#' #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' library(XLConnect)
#' # Descriptions
#' #
#' Desc.freq <- "Frequency metrics indicate numbers of days in months or seasons
#' that key events exceed user-defined temperatures. "
#' #
#' Desc.mag <- "Magnitude metrics characterize monthly and seasonal averages and
#' the maximum and minimum from daily temperatures as well as 3-, 7-, 14-, 21-,
#' and 30-day moving averages for mean and maximum daily temperatures."
#' #
#' Desc.roc <- "Rate of change metrics include monthly and seasonal rate of
#' change, which indicates the difference in magnitude of maximum and minimum
#' temperatures divided by number of days between these events."
#' #
#' Desc.tim <- "Timing metrics indicate Julian days of key events including
#' mean, maximum, and minimum temperatures; they also indicate Julian days of
#' mean, maximum, and minimum values over moving windows of specified size."
#' #
#' Desc.var <- "Variability metrics summarize monthly and seasonal range in
#' daily mean temperatures as well as monthly coefficient of variation of daily
#' mean, maximum, and minimum temperatures. Variability metrics also include
#' moving averages for daily ranges and moving variability in extreme
#' temperatures, calculated from differences in average high and low
#' temperatures over various time periods"
#' #
#' Group.Desc <- c(Desc.freq, Desc.mag, Desc.roc, Desc.tim, Desc.var)
#' df.Groups <- as.data.frame(cbind(c("freq","mag","roc","tim","var")
#'                            ,Group.Desc))
#' #
#' SiteID <- sitedata[1,1]
#' myDate <- format(Sys.Date(),"%Y%m%d")
#' myTime <- format(Sys.time(),"%H%M%S")
#' Notes.User <- Sys.getenv("USERNAME")
#' # Notes section (add min/max dates)
#' Notes.Names <- c("Dataset (SiteID)", "Analysis.Date (YYYYMMDD)"
#'                  , "Analysis.Time (HHMMSS)", "Analysis.User")
#' Notes.Data <- c(SiteID, myDate, myTime, Notes.User)
#' df.Notes <- as.data.frame(cbind(Notes.Names, Notes.Data))
#' Notes.Summary <- summary(sitedata)
#' # Open/Create file
#' ## New File Name
#' myFile.XLSX <- paste("StreamThermal"
#'                      , SiteID
#'                      , myDate
#'                      , myTime
#'                      , "xlsx"
#'                      , sep=".")
#' ## Copy over template with Metric Definitions
#' file.copy(file.path(path.package("ContDataQC")
#'                                  ,"extdata"
#'                                  ,"StreamThermal_MetricList.xlsx")
#'           , myFile.XLSX)
#' ## load workbook, create if not existing
#' wb <- loadWorkbook(myFile.XLSX, create = TRUE)
#' # create sheets
#' createSheet(wb, name = "NOTES")
#' createSheet(wb, name = "freq")
#' createSheet(wb, name = "mag")
#' createSheet(wb, name = "roc")
#' createSheet(wb, name = "tim")
#' createSheet(wb, name = "var")
#' # write to worksheet
#' writeWorksheet(wb, df.Notes, sheet = "NOTES", startRow=1)
#' writeWorksheet(wb, df.Groups, sheet="NOTES", startRow=10)
#' writeWorksheet(wb, Notes.Summary, sheet = "NOTES", startRow=20)
#' writeWorksheet(wb, ST.freq, sheet = "freq")
#' writeWorksheet(wb, ST.mag, sheet = "mag")
#' writeWorksheet(wb, ST.roc, sheet = "roc")
#' writeWorksheet(wb, ST.tim, sheet = "tim")
#' writeWorksheet(wb, ST.var, sheet = "var")
#' # save workbook
#' saveWorkbook(wb, myFile.XLSX)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# # QC Function
# myData         <- DATA_period_test2_Aw_20130101_20141231
# fun.myDF       <- myData
# fun.col.SiteID <- "SiteID"
# fun.col.Date   <- "Date"
# fun.col.Temp   <- "Water.Temp.C"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @export
Export.StreamThermal <- function(fun.myDF
                                 ,fun.col.SiteID=ContData.env$myName.SiteID
                                 ,fun.col.Date=ContData.env$myName.Date
                                 ,fun.col.Temp=ContData.env$myName.WaterTemp
                                  )
{##FUNCTION.Export.StreamThermal.START
  #
  # Calculate stats (max, min, mean) for SiteID and Date
  agg.stats <- stats::aggregate(fun.myDF[,fun.col.Temp] ~
                                  fun.myDF[,fun.col.SiteID] +
                                  fun.myDF[,fun.col.Date]
                         , FUN=function(x) c(MaxT=max(x)
                                             , MinT=min(x)
                                             , MeanT=mean(x) ) )
  # Convert to DF
  df.stats <- do.call(data.frame, agg.stats)
  # rename columns
  Names.ST <- c("SiteID", "Date", "MaxT", "MinT", "MeanT")
  names(df.stats) <- Names.ST
  # update column classes
  df.stats[,Names.ST[1]] <- as.character(df.stats[,Names.ST[1]])
  df.stats[,Names.ST[2]] <- as.Date(df.stats[,Names.ST[2]])
  # return DF to user
  return(df.stats)
}##FUNCTION.Export.StreamThermal.END
