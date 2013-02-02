class Matrix

  makeChart: (data) ->
    jQuery("table.bar_chart").remove()
    jQuery("div#browser_update_notice").remove()

    table = d3.select("#bar-chart-target")
      .append("table")
      .classed("bar_chart", true)

    table.append("tr")
      .html("<th class='table_title'>#{@data.Dist} Achievement Gap</th><th class='table_title'>%</th>")

    #Draw the table entries themselves
    table.selectAll("tr.ach")
      .data(data)
      .enter()
      .append("tr")
      .attr("id", (d, i) -> "bar_rect_#{i}")
      .classed("town_datum", (d, i) ->
        return not Boolean(i % 2)
      )
      .classed("state_datum", (d, i) ->
        return Boolean(i % 2)
      )
      .html((d) ->  #Draw the table row
        "<td>#{d.label}</td><td>#{d.current}</td>"
      )

window.matrix = Matrix
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