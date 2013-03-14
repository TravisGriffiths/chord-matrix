// Generated by CoffeeScript 1.3.3
(function() {
  var Matrix;

  Matrix = (function() {

    function Matrix() {}

    Matrix.prototype.setTitle = function(title) {
      this.title = title;
    };

    Matrix.prototype.setTarget = function(target) {
      this.target = target;
    };

    Matrix.prototype.makeHistogram = function(data) {
      var a, barspace, barwidth, chart, hist_data, i, leftmargin, local_max, max, value, _i, _j, _k, _len, _len1, _ref, _ref1, _ref2, _ref3;
      jQuery('div.segmentInfo svg').remove();
      jQuery('tr.value').attr('style', false);
      jQuery('td.xaxis').attr('style', false);
      jQuery('td.highlight').removeClass('highlight');
      jQuery("div.segmentInfo h3").remove();
      jQuery("div.segmentInfo").append("<h3>" + this.title + "</h3>");
      $($('table.matrix tr')[data[0].index]).find('td.left').addClass('highlight');
      for (i = _i = _ref = data[0].index, _ref1 = data.length; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; i = _ref <= _ref1 ? ++_i : --_i) {
        $($($('table.matrix tr')[i + 1]).find('td.left')[data[0].index + 1]).addClass('highlight');
      }
      hist_data = [];
      local_max = [];
      _ref2 = this.data.data;
      for (_j = 0, _len = _ref2.length; _j < _len; _j++) {
        a = _ref2[_j];
        local_max.push(d3.max(a));
      }
      max = d3.max(local_max);
      _ref3 = data.slice(1);
      for (i = _k = 0, _len1 = _ref3.length; _k < _len1; i = ++_k) {
        value = _ref3[i];
        if (value.value) {
          hist_data.push({
            'value': value.value,
            'label': this.data.groups[i],
            'max': max,
            'color': value.color
          });
        }
      }
      barwidth = 30;
      barspace = 10;
      leftmargin = 5;
      chart = d3.select('div.segmentInfo').append('svg').attr('height', 350).attr('width', 400).selectAll('rect.hist').data(hist_data).enter().append('rect').classed("hist", true).attr("x", function(d, i) {
        return leftmargin + (barwidth + barspace) * i;
      }).attr("y", function(d, i) {
        return 310 - ((300 / d.max) * d.value);
      }).attr("height", function(d) {
        return (300 / d.max) * d.value;
      }).attr("width", barwidth).attr("fill", function(d, i) {
        return d.color;
      });
      d3.select('div.segmentInfo svg').selectAll('text.xaxis').data(hist_data).enter().append("text").classed("xaxis", true).attr("x", function(d, i) {
        return -335;
      }).attr("y", function(d, i) {
        return 20 + leftmargin + (barwidth + barspace) * i;
      }).attr("dx", barwidth).attr("text-anchor", "start").attr("transform", "rotate(-90)").text(function(d, i) {
        return d.label;
      });
      return d3.select('div.segmentInfo svg').selectAll('text.xvalue').data(hist_data).enter().append("text").classed("xvalue", true).attr("x", function(d, i) {
        return leftmargin + ((barwidth + barspace) * i);
      }).attr("y", 330).attr("dx", barwidth).attr("text-anchor", "end").text(function(d, i) {
        return utilities.toHumanInt(d.value);
      });
    };

    Matrix.prototype.plot = function() {
      var a, c, cell, fill, getColor, grey, h, i, labeled_matrix, labels, local_max, r0, r1, rank, rankArray, raw, right_of_zero, row, table, w, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
      raw = this.raw;
      $(this.target).children('svg').remove();
      w = this.fullWidth;
      if (w > 900) {
        _ref = [900, 900], h = _ref[0], w = _ref[1];
      } else {
        h = w;
      }
      r0 = Math.min(w, h) * 0.29;
      r1 = r0 * 1.1;
      fill = paletteFactory.getPalette('warm');
      grey = paletteFactory.getPalette('greyscale');
      c = utilities.counter(0);
      local_max = [];
      _ref1 = this.data.data;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        a = _ref1[_i];
        local_max.push(d3.max(a));
      }
      getColor = function(value) {
        return d3.interpolateRgb("#FFF", "#009700")(value / d3.max(local_max)).toString();
      };
      rankArray = _.uniq(_.flatten(this.data.data)).sort(function(a, b) {
        return a - b;
      }).reverse();
      rank = function(value) {
        if (value === 0) {
          return 0;
        }
        return _.indexOf(rankArray, value) + 1;
      };
      jQuery('table.matrix').remove();
      if (jQuery('table.matrix').length) {
        return;
      }
      table = d3.select(this.target).append("table").classed("matrix", true);
      labels = _.clone(this.data.groups);
      labels.unshift(" ");
      labeled_matrix = [];
      right_of_zero = false;
      _ref2 = this.data.data;
      for (i = _j = 0, _len1 = _ref2.length; _j < _len1; i = ++_j) {
        row = _ref2[i];
        labeled_matrix.push([
          {
            'value': this.data.groups[i],
            'color': null,
            'index': i
          }
        ]);
        right_of_zero = false;
        for (_k = 0, _len2 = row.length; _k < _len2; _k++) {
          cell = row[_k];
          if (cell === 0) {
            right_of_zero = true;
          }
          _.last(labeled_matrix).push({
            'value': cell,
            'color': getColor(cell),
            'rank': rank(cell),
            'right': right_of_zero,
            'index': i
          });
        }
      }
      return table.selectAll("tr.value").data(labeled_matrix).enter().append("tr").classed("value tableRow", true).on('mouseover', function(d) {
        d3.select(this).classed('highlight', true);
        return dispatcher.trigger("histogram:request", d);
      }).on('mouseout', function(d) {
        return d3.select(this).classed('highlight', false);
      }).attr("id", function(d, i) {
        return "matrix_" + i;
      }).selectAll('td').data(function(d) {
        return d;
      }).enter().append('td').classed('right', function(d) {
        return d.right;
      }).classed('left', function(d) {
        return !d.right;
      }).style('background-color', function(d) {
        if (d.color) {
          return d.color;
        } else {
          return 'none';
        }
      }).text(function(d) {
        if (_.isNumber(d.value)) {
          if (d.rank === 0) {
            return "-";
          } else {
            return String(d.rank);
          }
        } else {
          return String(d.value);
        }
      });
    };

    table.append("tr").selectAll('td.xaxis').data(labels).enter().append("td").classed("xaxis left", true).html(function(d) {
      return d;
    });

    return Matrix;

  })();

  window.matrix = Matrix;

  window.chart_data = JSON.parse("[\n[0,1012, 1967, 2918, 1684, 1016, 1744, 973, 2318],\n[1012, 0, 1192, 1688, 1000, 603, 1128, 526, 1338],\n[1967, 1192, 0, 3374, 1984, 1183, 2053, 1143, 2671],\n[2918, 1688, 3374, 0, 2744, 1726, 3043, 1633, 3914],\n[1684, 1000, 1984, 2744, 0, 983, 1674, 949, 2131],\n[1016, 603, 1183, 1726, 983, 0, 1023, 577, 1336],\n[1744, 1128, 2053, 3043, 1674, 1023, 0, 978, 2332],\n[973, 526, 1143, 1633, 949, 577, 978, 0, 1254]\n] ");

}).call(this);
