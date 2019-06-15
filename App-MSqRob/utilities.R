
#A function to prompt a folder chooser under Mac OS X,
#normal choose.dir sometimes gives just NA because system has no access to finder
choose.dir2 <- function(default = NA, caption = NA) {
  command = 'osascript'

  #Dit was het:
  #args = "-e 'tell application \"Finder\"' -e 'activate' -e 'POSIX path of (choose folder{{prompt}}{{default}})' -e 'end tell'"
  #'-e "POSIX path of (choose folder{{prompt}}{{default}})"'

  #osascript -e 'tell application "Terminal" to return POSIX path of (choose file)'

  #Find App that is in front
  args1 = "-e 'tell application \"System Events\"' -e 'set frontApp to name of first application process whose frontmost is true' -e 'end tell'"
  suppressWarnings({
    frontApp = system2(command, args = args1, stderr = TRUE)
  })

  #The application that is in front should open the  file choose window
  args = paste0("-e 'tell application \"",frontApp,"\" to return POSIX path of (choose folder{{prompt}}{{default}})'")

  #system2('osascript', args = "-e 'tell application \"Finder\"' -e 'POSIX path of (choose folder{{prompt}}{{default}})' -e 'end tell'", stderr = TRUE)

  if (!is.null(caption) && !is.na(caption) && nzchar(caption)) {
    prompt = sprintf(' with prompt \\"%s\\"', caption)
  } else {
    prompt = ''
  }
  args = sub('{{prompt}}', prompt, args, fixed = TRUE)

  if (!is.null(default) && !is.na(default) && nzchar(default)) {
    default = sprintf(' default location \\"%s\\"', path.expand(default))
  } else {
    default = ''
  }
  args = sub('{{default}}', default, args, fixed = TRUE)

  suppressWarnings({
    path = system2(command, args = args, stderr = TRUE)
  })
  if (!is.null(attr(path, 'status')) && attr(path, 'status')) {
    # user canceled
    path = NA
  }

  return(path)
}

choose.dir_Linux <- function(default = NA, caption = NA) {

  command = "zenity"

  args1 = "--file-selection --directory"

  if (!is.null(caption) && !is.na(caption) && nzchar(caption)) {
    prompt = sprintf(' with prompt \\"%s\\"', caption)
  } else {
    prompt = ''
  }

  if (!is.null(default) && !is.na(default) && nzchar(default)) {
    default = path.expand(default) #sprintf(' default location \\"%s\\"', path.expand(default))
  } else {
    default = "/dev/null"
  }

  suppressWarnings({
    path = system2(command, args = args1, stderr = default, stdout=TRUE)
  })

  if (!is.null(attr(path, 'status')) && attr(path, 'status')) {
    # user canceled
    path = NA
  }

  return(path)
}


#Function to convert data paths if on windows
getDataPath <- function(datapath){
  if(Sys.info()['sysname']=="Windows"){
    datapath <- gsub("\\","/",datapath, fixed=TRUE)
  }
  return(datapath)
}


#Function to plot densities
plotDens=function(eset, densAll, xlim=NULL, ylim=NULL, colors=1, las=1, frame.plot=FALSE, ...)
{
      plot(densAll[[1]],col=colors[1],xlim=xlim,ylim=ylim, las=las, frame.plot=frame.plot, ...)
      if (length(colors)>1) for (i in 2:ncol(eset)) lines(densAll[[i]],col=colors[i])
      else for (i in 2:ncol(eset)) lines(densAll[[i]],col=colors)
}

#Function to check and process input
processInput <- function(input){

    if(isTRUE(input$onlysite) && is.null(input$proteingroups$datapath)){stop("Please provide a protein groups file or untick the box \"Remove proteins that are only identified by modified peptides\".")}

#    if(input$save==2 && is.null(input$loadmodel$datapath)){stop("Please provide a saved RData file or don't choose the option \"Upload an existing model\" under \"Save/load options\".")}

    type_annot <- NULL

    if(isTRUE(as.logical(grep(".xlsx[/\\]*$",input$annotation$name)))){type_annot <- "xlsx"}

    proteins <- input$proteins
    annotations <- input$annotations
    filter <- input$filter

    if(!is.null(proteins)){proteins <- gsub(" ",".",proteins)}
    if(!is.null(annotations)){annotations <- gsub(" ",".",annotations)}
    if(!is.null(filter)){filter <- gsub(" ",".",filter)}

    peptides <- input$peptides

    peptides$datapath <- getDataPath(as.character(peptides$datapath))

    processedvals <- list("proteins"=proteins, "peptides"=peptides, "annotations"=annotations,"filter"=filter, "type_annot"=type_annot)
    return(processedvals)

  }


#' Folder Upload Control
#'
#' Create a folder upload control that can be used to upload one or more filepaths pointing to folders. Strongly based on Shiny's File Upload Control.
#'
#' Whenever a folder upload completes, the corresponding input variable is set
#' to a character path.
#'
#' @family input elements
#'
#' @param inputId	The \code{input} slot that will be used to access the value.
#' @param label	Display label for the control, or \code{NULL} for no label.
#' @param value	Initial value.
#' @param width	The width of the input, e.g. \code{'400px'}, or \code{'100%'}; see \code{\link{validateCssUnit}}.
#' @param placeholder	A character string giving the user a hint as to what can be entered into the control. Internet Explorer 8 and 9 do not support this option.
#' @param multiple Whether the user should be allowed to select and upload
#'   multiple folders at once. \bold{Does not work on older browsers, including
#'   Internet Explorer 9 and earlier.}
#' @param accept A character vector of MIME types; gives the browser a hint of
#'   what kind of folders the server is expecting.
#' @param style The style attribute for the HTML tag. Used to hide/unhide the progress bar.
#'
#' @examples
#' ## Only run examples in interactive R sessions
#' if (interactive()) {
#'
#' ui <- fluidPage(
#'   sidebarLayout(
#'     sidebarPanel(
#'       fileInput("file1", "Choose CSV File",
#'         accept = c(
#'           "text/csv",
#'           "text/comma-separated-values,text/plain",
#'           ".csv")
#'         ),
#'       tags$hr(),
#'       checkboxInput("header", "Header", TRUE)
#'     ),
#'     mainPanel(
#'       tableOutput("contents")
#'     )
#'   )
#' )
#'
#' server <- function(input, output) {
#'   output$contents <- renderTable({
#'     # input$file1 will be NULL initially. After the user selects
#'     # and uploads a file, it will be a data frame with 'name',
#'     # 'size', 'type', and 'datapath' columns. The 'datapath'
#'     # column will contain the local filenames where the data can
#'     # be found.
#'     inFile <- input$file1
#'
#'     if (is.null(inFile))
#'       return(NULL)
#'
#'     read.csv(inFile$datapath, header = input$header)
#'   })
#' }
#'
#' shinyApp(ui, server)
#' }
#' @export
folderInput <- function(inputId, label, value = NA, multiple = FALSE, accept = NULL,
                        width = NULL, style="") {

  restoredValue <- restoreInput(id = inputId, default = NULL)

  # Catch potential edge case - ensure that it's either NULL or a data frame.
  if (!is.null(restoredValue) && !dir.exists(restoredValue)) {
    warning("Restored value for ", inputId, " has incorrect format.")
    restoredValue <- NULL
  }

  if (!is.null(restoredValue)) {
    restoredValue <- toJSON(restoredValue, strict_atomic = FALSE)
  }

  inputTag <- tags$input(
    id = inputId,
    name = inputId,
    type = "button",
    style = "display: none;",
    `data-restore` = restoredValue,
    class = "btn action-button"
    # webkitdirectory = NA,
    # directory = NA
  )

  if (multiple)
    inputTag$attribs$multiple <- "multiple"
  if (length(accept) > 0)
    inputTag$attribs$accept <- paste(accept, collapse=',')


  div(class = "form-group shiny-input-container",
      style = if (!is.null(width)) paste0("width: ", validateCssUnit(width), ";"),
      shiny:::`%AND%`(label, tags$label(label)),

      div(class = "input-group",
          tags$label(class = "input-group-btn",
                     span(id = paste(inputId, "_label", sep = ""), class = "btn btn-default btn-file",
                          "Browse...",
                          inputTag
                     )
          ),
          tags$input(type = "text", class = "form-control", value=value,
                     placeholder = "No folder selected", readonly = "readonly"
          )
      ),

      tags$div(
        id=paste(inputId, "_progress", sep=""),
        class="progress progress-striped active shiny-file-input-progress", style=style, #"visibility: visible;"
        tags$div(class="progress-bar", style="width: 100%;","Folder selected")
      )
  )
}





#'@export
fileInput <- function (inputId, label, multiple = FALSE, accept = NULL, width = NULL)
{
  restoredValue <- restoreInput(id = inputId, default = NULL)
  if (!is.null(restoredValue) && !is.data.frame(restoredValue)) {
    warning("Restored value for ", inputId, " has incorrect format.")
    restoredValue <- NULL
  }
  if (!is.null(restoredValue)) {
    restoredValue <- toJSON(restoredValue, strict_atomic = FALSE)
  }
  inputTag <- tags$input(id = inputId, name = inputId, type = "file",
                         style = "display: none;", `data-restore` = restoredValue)
  if (multiple)
    inputTag$attribs$multiple <- "multiple"
  if (length(accept) > 0)
    inputTag$attribs$accept <- paste(accept, collapse = ",")
  div(class = "form-group shiny-input-container", style = if (!is.null(width))
    paste0("width: ", validateCssUnit(width), ";"),
    shiny:::`%AND%`(label, tags$label(label)),
    div(class = "input-group", tags$label(class = "input-group-btn",
                                                               span(id = paste(inputId, "_label", sep = ""), class = "btn btn-default btn-file", "Browse...",
                                                                    inputTag)), tags$input(type = "text", class = "form-control",
                                                                                           placeholder = "No file selected", readonly = "readonly")),
    tags$div(id = paste(inputId, "_progress", sep = ""),
             class = "progress progress-striped active shiny-file-input-progress",
             tags$div(class = "progress-bar")))
}



preprocess_MaxQuant2<-function (MSnSet, accession = "Proteins", exp_annotation = NULL,
    type_annot = NULL, logtransform = TRUE, base = 2, normalisation = "quantiles",
    weights = NULL, smallestUniqueGroups = TRUE, useful_properties = c("Proteins",
        "Sequence", "PEP"), filter = c("Potential.contaminant",
        "Reverse"), filter_symbol = "+", minIdentified = 2, remove_only_site = FALSE,
    file_proteinGroups = NULL, colClasses = "keep", droplevels = TRUE,
    printProgress = FALSE, shiny = FALSE, message = NULL)
{
    if ("Potential.contaminant" %in% filter && !("Potential.contaminant" %in%
        colnames(Biobase::fData(MSnSet)))) {
        filter[filter == "Potential.contaminant"] <- "Contaminant"
    }
    details <- c("Aggregating peptides", "Log-transforming data",
        "Normalizing data", "Removing overlapping protein groups",
        "Removing contaminants and/or reverse sequences", "Removing proteins only identified by modified peptides",
        "Removing less useful properties", paste0("Removing peptides identified less than ",
            minIdentified, " times"), "Adding experimental annotation")
    external_filter_accession = "Protein.IDs"
    external_filter_column = "Only.identified.by.site"
    if (!isTRUE(remove_only_site)) {
        file_proteinGroups <- NULL
    }
    MSnSet <- preprocess_MSnSet2(MSnSet = MSnSet, accession = accession,
        exp_annotation = exp_annotation, type_annot = type_annot,
        logtransform = logtransform, base = base, normalisation = normalisation,
        weights = weights, smallestUniqueGroups = smallestUniqueGroups,
        split = ";", useful_properties = useful_properties, filter = filter,
        filter_symbol = filter_symbol, minIdentified = minIdentified,
        external_filter_file = file_proteinGroups, external_filter_accession = external_filter_accession,
        external_filter_column = external_filter_column, colClasses = colClasses,
        droplevels = droplevels, printProgress = printProgress,
        shiny = shiny, message = message, details = details)
    if (ncol(pData(MSnSet)) == 0) {
        emptyPData <- data.frame(run = rownames(pData(MSnSet)))
        rownames(emptyPData) <- rownames(pData(MSnSet))
        pData(MSnSet) <- emptyPData
    }
    return(MSnSet)
}


preprocess_MSnSet2 <- function (MSnSet, accession, exp_annotation = NULL, type_annot = NULL,
    aggr_by = NULL, aggr_function = "sum", logtransform = TRUE,
    base = 2, normalisation = "quantiles", weights = NULL, smallestUniqueGroups = TRUE,
    split = NULL, useful_properties = NULL, filter = NULL, filter_symbol = NULL,
    minIdentified = 2, external_filter_file = NULL, external_filter_accession = NULL,
    external_filter_column = NULL, colClasses = "keep", droplevels = TRUE,
    printProgress = FALSE, shiny = FALSE, message = NULL, details = NULL)
{
    accession <- make.names(accession, unique = TRUE)
    useful_properties <- make.names(useful_properties, unique = TRUE)
    if (isTRUE(smallestUniqueGroups) && is.null(split)) {
        stop("Please provide the protein groups separator (split argument) or set the smallestUniqueGroups argument to FALSE.")
    }
    if (!(accession %in% useful_properties)) {
        useful_properties <- c(accession, useful_properties)
    }
    if (!all(useful_properties %in% colnames(Biobase::fData(MSnSet)))) {
        stop("Argument \"useful_properties\" must only contain column names of the featureData slot.")
    }
    if (!all(filter %in% colnames(Biobase::fData(MSnSet)))) {
        stop("One or more elements in the \"filter\" argument are no column names of the featureData slot of the MSnSet object.")
    }
    n <- sum(isTRUE(logtransform), (normalisation != "none"),
        isTRUE(smallestUniqueGroups), !is.null(filter), !is.null(external_filter_file),
        !all(colnames(Biobase::fData(MSnSet)) %in% useful_properties),
        minIdentified > 1, !is.null(exp_annotation))
    if (!is.null(aggr_by)) {
        MSnSet <- aggregateMSnSet(MSnSet, aggr_by = c(aggr_by,
            filter), aggr_function = "sum", split = split, shiny = shiny,
            printProgress = printProgress, message = details[1])
    }
    progress <- NULL
    if (isTRUE(shiny) && n > 0) {
        progress <- shiny::Progress$new()
        on.exit(progress$close())
        progress$set(message = message, value = 0)
    }
    if (isTRUE(logtransform)) {
        updateProgress(progress = progress, detail = details[2],
            n = n, shiny = shiny, print = isTRUE(printProgress &
                logtransform))
        MSnSet <- log(MSnSet, base = base)
    }
    exprs <- Biobase::exprs(MSnSet)
    exprs[is.infinite(exprs)] <- NA
    Biobase::exprs(MSnSet) <- exprs

    if (isTRUE(smallestUniqueGroups)) {
        updateProgress(progress = progress, detail = details[4],
            n = n, shiny = shiny, print = isTRUE(printProgress &
                smallestUniqueGroups))
        groups2 <- smallestUniqueGroups(Biobase::fData(MSnSet)[,
            accession], split = split)
        sel <- Biobase::fData(MSnSet)[, accession] %in% groups2
        MSnSet <- MSnSet[sel]
    }
    if (!is.null(filter)) {
        updateProgress(progress = progress, detail = details[5],
            n = n, shiny = shiny, print = isTRUE(printProgress &
                (length(filter) != 0)))
        filterdata <- Biobase::fData(MSnSet)[, filter, drop = FALSE]
        filterdata[is.na(filterdata)] <- ""
        sel <- rowSums(filterdata != filter_symbol) == length(filter)
        MSnSet <- MSnSet[sel]
    }
    if (!is.null(external_filter_file)) {
        updateProgress(progress = progress, detail = details[6],
            n = n, shiny = shiny, print = isTRUE(printProgress))
        externalFilter <- read.table(external_filter_file, sep = "\t",
            header = TRUE, quote = "", comment.char = "")
        only_site <- externalFilter[[external_filter_column]]
        only_site[is.na(only_site)] <- ""
        removed_proteins <- externalFilter[[external_filter_accession]][only_site ==
            filter_symbol]
        sel <- !(as.character(Biobase::fData(MSnSet)[, accession]) %in%
            as.character(removed_proteins))
        MSnSet <- MSnSet[sel]
    }
    if (!all(colnames(Biobase::fData(MSnSet)) %in% useful_properties)) {
        updateProgress(progress = progress, detail = details[7],
            n = n, shiny = shiny, print = isTRUE(printProgress))
        Biobase::fData(MSnSet) <- Biobase::fData(MSnSet)[, useful_properties,
            drop = FALSE]
    }
    if (minIdentified > 1) {
        updateProgress(progress = progress, detail = details[8],
            n = n, shiny = shiny, print = isTRUE(printProgress))
        keepers <- rowSums(!is.na(Biobase::exprs(MSnSet))) >=
            minIdentified
        MSnSet <- MSnSet[keepers]
    }
    if (normalisation != "none") {
        updateProgress(progress = progress, detail = details[3],
            n = n, shiny = shiny, print = isTRUE(printProgress &
                (normalisation != "none")))
        MSnSet <- normalise(MSnSet, normalisation, weights)
    }
    if (!is.null(exp_annotation)) {
        updateProgress(progress = progress, detail = details[9],
            n = n, shiny = shiny, print = isTRUE(printProgress &
                !is.null(exp_annotation)))
        exprs <- Biobase::exprs(MSnSet)
        pData <- makeAnnotation(exp_annotation = exp_annotation,
            run_names = colnames(exprs), type_annot = type_annot,
            colClasses = colClasses)
        annotation_run <- getAnnotationRun(pData = pData, run_names = colnames(exprs))
        exprs <- exprs[, match(as.character(pData[, annotation_run]),
            colnames(exprs))]
        rownames(pData) <- colnames(exprs)
        MSnSet <- MSnbase::MSnSet(exprs = exprs, fData = Biobase::fData(MSnSet),
            pData = pData)
    }
    if (isTRUE(droplevels)) {
        Biobase::fData(MSnSet) <- droplevels(Biobase::fData(MSnSet))
    }
    return(MSnSet)
}
