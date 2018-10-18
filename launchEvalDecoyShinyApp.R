#Line below has to be commented out when users are not working with Rstudio
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

maxFileSize=100
options(shiny.maxRequestSize=maxFileSize*1024^2)
options(shiny.launch.browser = .rs.invokeShinyWindowExternal)
shiny::runApp("App-evalDecoys/")
