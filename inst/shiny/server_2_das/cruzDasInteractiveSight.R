# cruzDasInteractiveSight for CruzPlot


observeEvent(input$sight_hover, {
  sight$hover <- c(input$sight_hover$x, input$sight_hover$y)
})

observeEvent(input$sight_click, {
  sight$click <- c(sight$click, input$sight_click$x, input$sight_click$y)
  sight$miss <- FALSE

  len <- length(sight$click)
  curr <- c(sight$click[len-1], sight$click[len])
  data.sight <- cruzDasSightRange()$data.sight

  param.unit <- cruzMapParam()$param.unit
  param.unit.diff <- c(param.unit[2]-param.unit[1], param.unit[4]-param.unit[3]) # Works because for world2 map, x range is 0, 360
  param.inch <- cruzMapParam()$param.inch
  x.ratio <- param.inch[1]/param.unit.diff[1]
  y.ratio <- param.inch[2]/param.unit.diff[2]

  # Determine closest point
  sight.type <- cruzDasSightRange()$sight.type
  if(sight.type == 1) close.info <- cruzClosestPt(curr, data.sight, 2)    # 2 means mammal sighting for function cruzClosestPt
  if(sight.type  > 1) close.info <- cruzClosestPt(curr, data.sight, 4)    # 4 means non-mammal sighting for function cruzClosestPt
  dist.inch <- sqrt((as.numeric(close.info[1])*x.ratio)^2 +
                      (as.numeric(close.info[2])*y.ratio)^2)
  if(dist.inch <= 0.2) {
    isolate(sight$lab <- c(sight$lab, close.info[3]))
  }
  if(dist.inch > 0.2) {
    sight$click <- sight$click[1:(length(sight$click)-2)]
    sight$miss <- TRUE
  }
})

observeEvent(input$das.sight.interactive.reset.last, {
  # Remove last point
  if(length(sight$click)==2) sight$click <- NULL
  else sight$click <- sight$click[1:(length(sight$click)-2)]

  if(length(sight$lab)==1) sight$lab <- NULL
  else sight$lab <- sight$lab[1:(length(sight$lab)-1)]

  sight$miss <- FALSE
})


observeEvent(input$das.sight.interactive.reset.all, {
  # Remove all points
  sight$click <- NULL
  sight$lab <- NULL
  sight$miss <- FALSE
})

# Make sure interactively labeled sightings are still present
# ***Has some bug in it
cruzDasInteractiveSightCheck <- reactive({
  data.sight <- cruzDasSightRange()$data.sight
  sight.type <- cruzDasSightRange()$sight.type

  # Only need to do checks when data.sight changes
  isolate(sight.lab <- sight$lab)
  browser()
  if(!is.null(sight.lab)) {
    sight.num <- gsub(" ", "", substr(sight.lab, 3, 6))
    if(sight.type == 1) keep.pt <- which(sight.num %in% data.sight$Data1)
    if(sight.type > 1) keep.pt <- which(sight.num %in% data.sight$Data2)
    if(length(keep.pt) == 0) isolate(sight$click <- sight$lab <- NULL)
    else {
      keep.click <- sort(c(2*keep.pt, (2*keep.pt)-1))
      isolate(sight$click <- sight$click[keep.click])
      isolate(sight$lab <- sight$lab[keep.pt])
    }
  }
})