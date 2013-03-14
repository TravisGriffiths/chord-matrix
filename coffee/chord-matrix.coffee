class Matrix

  setTitle: (@title) ->

  setTarget: (@target) ->

  makeHistogram: (data) ->
    jQuery('div.segmentInfo svg').remove()
    jQuery('tr.value').attr('style', false)
    jQuery('td.xaxis').attr('style', false)
    jQuery('td.highlight').removeClass('highlight')
    jQuery("div.segmentInfo h3").remove()
    jQuery("div.segmentInfo").append("<h3>#{@title}</h3>")
    $($('table.matrix tr')[data[0].index]).find('td.left').addClass('highlight')
    for i in [data[0].index..(data.length)]
      $($($('table.matrix tr')[i + 1]).find('td.left')[data[0].index + 1]).addClass('highlight')
    hist_data = []
    local_max = []
    local_max.push(d3.max(a)) for a in @data.data
    max = d3.max(local_max)
    for value, i in data[1..]
      if value.value
        hist_data.push({
                       'value': value.value
                       'label': @data.groups[i]
                       'max': max
                       'color': value.color
                       })

    barwidth = 30
    barspace = 10
    leftmargin = 5
    chart = d3.select('div.segmentInfo').append('svg')
      .attr('height', 350)
      .attr('width', 400)
      .selectAll('rect.hist')
      .data(hist_data)
      .enter()
      .append('rect')
      .classed("hist", true)
      .attr("x", (d, i) -> leftmargin + (barwidth + barspace) * i )
      .attr("y", (d, i) -> 310 - ((300 / d.max) * d.value))
      .attr("height", (d) -> (300 / d.max) * d.value)
      .attr("width", barwidth)
      .attr("fill", (d, i) -> d.color)

    d3.select('div.segmentInfo svg').selectAll('text.xaxis')
      .data(hist_data)
      .enter()
      .append("text")
      .classed("xaxis", true)
      .attr("x", (d, i) -> -335)
      .attr("y", (d, i) -> 20 + leftmargin + (barwidth + barspace) * i)#NOTE: Rotated 90 deg e.g left gets applied to y
      .attr("dx", barwidth)
      .attr("text-anchor", "start")
      .attr("transform", "rotate(-90)")
      .text((d, i) -> d.label)

    d3.select('div.segmentInfo svg').selectAll('text.xvalue')
      .data(hist_data)
      .enter()
      .append("text")
      .classed("xvalue", true)
      .attr("x", (d, i) ->  leftmargin + ((barwidth + barspace) * i))
      .attr("y", 330 )
      .attr("dx", barwidth)
      .attr("text-anchor", "end")
      .text((d, i) -> utilities.toHumanInt(d.value))

  plot: ->
    raw = @raw
    $(@target).children('svg').remove() #If this is a redraw, we need to start fresh
    w = @fullWidth
    if w > 900
      [h, w] = [900, 900]
    else
      h = w

    r0 = Math.min(w, h) * 0.29
    r1 = r0 * 1.1
    fill = paletteFactory.getPalette('warm')  #d3.scale.category20c()
    grey = paletteFactory.getPalette('greyscale')
    c = utilities.counter(0)

    #Get the max color
    local_max = []
    local_max.push(d3.max(a)) for a in @data.data
    getColor = (value) -> d3.interpolateRgb("#FFF", "#009700")(value/d3.max(local_max)).toString()
    rankArray = _.uniq(_.flatten(@data.data)).sort((a, b) -> a - b).reverse()
    rank = (value) ->
      return 0 if value == 0
      (_.indexOf(rankArray, value) + 1)


    # Draw The Matrix:
    jQuery('table.matrix').remove()
    return if jQuery('table.matrix').length
    table = d3.select(@target)
      .append("table")
      .classed("matrix", true)

    labels = _.clone(@data.groups)
    labels.unshift(" ")

    labeled_matrix = []
    right_of_zero = false

    for row, i in @data.data
      labeled_matrix.push([{'value': @data.groups[i], 'color': null, 'index': i}])
      right_of_zero = false
      for cell in row
        right_of_zero = true if cell == 0
        _.last(labeled_matrix).push({'value': cell, 'color': getColor(cell), 'rank': rank(cell), 'right': right_of_zero, 'index': i})
    #Draw the table entries themselves

    table.selectAll("tr.value")
      .data(labeled_matrix)
      .enter()
      .append("tr").classed("value tableRow", true)
      .on('mouseover', (d) ->
           d3.select(@).classed('highlight', true)
           dispatcher.trigger("histogram:request", d)
      )
      .on('mouseout', (d) ->
           d3.select(@).classed('highlight', false)
      )
      .attr("id", (d, i) ->
             "matrix_#{i}"
      )
      .selectAll('td')
      .data((d) -> d)
      .enter()
      .append('td')
      .classed('right', (d) -> d.right)
      .classed('left', (d) -> not d.right)
      .style('background-color', (d)->
              if d.color
                d.color
              else
                'none'
            )
      .text((d) ->
             if _.isNumber(d.value)
               if d.rank == 0
                 "-"
               else
                 String(d.rank)
             else
               String(d.value)
           )

    table.append("tr").selectAll('td.xaxis').data(labels).enter()
      .append("td").classed("xaxis left", true)
      .html( (d) ->
             d
           )

window.matrix = Matrix

#This is random test data. Note that for this test data we are assuming we have a data set where given states are
#not self-referencing (i.e. A never implies A).
window.chart_data = JSON.parse("""[
                               [0,1012, 1967, 2918, 1684, 1016, 1744, 973, 2318],
                               [1012, 0, 1192, 1688, 1000, 603, 1128, 526, 1338],
                               [1967, 1192, 0, 3374, 1984, 1183, 2053, 1143, 2671],
                               [2918, 1688, 3374, 0, 2744, 1726, 3043, 1633, 3914],
                               [1684, 1000, 1984, 2744, 0, 983, 1674, 949, 2131],
                               [1016, 603, 1183, 1726, 983, 0, 1023, 577, 1336],
                               [1744, 1128, 2053, 3043, 1674, 1023, 0, 978, 2332],
                               [973, 526, 1143, 1633, 949, 577, 978, 0, 1254]
                               ] """)