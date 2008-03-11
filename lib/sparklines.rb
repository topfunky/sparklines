
require 'rubygems'
require 'RMagick'

=begin rdoc

A library for generating small unmarked graphs (sparklines).

Can be used to write an image to a file or make a web service with Rails or other Ruby CGI apps.

Idea and much of the outline for the source lifted directly from {Joe Gregorio's Python Sparklines web service script}[http://bitworking.org/projects/sparklines].

Requires the RMagick image library.

==Authors

{Dan Nugent}[mailto:nugend@gmail.com] Original port from Python Sparklines library.

{Geoffrey Grosenbach}[mailto:boss@topfunky.com] -- http://nubyonrails.topfunky.com 
-- Conversion to module and further maintenance.

==General Usage and Defaults

To use in a script:

	require 'rubygems'
	require 'sparklines'
	Sparklines.plot([1,25,33,46,89,90,85,77,42], 
	                :type => 'discrete', 
	                :height => 20)

An image blob will be returned which you can print, write to STDOUT, etc.

For use with Ruby on Rails, see the sparklines plugin:

  http://nubyonrails.com/pages/sparklines

In your view, call it like this:

  <%= sparkline_tag [1,2,3,4,5,6] %>

Or specify details:

  <%= sparkline_tag [1,2,3,4,5,6], 
                    :type => 'discrete', 
                    :height => 10, 
                    :upper => 80, 
                    :above_color => 'green', 
                    :below_color => 'blue' %>

Graph types:

 area
 discrete
 pie
 smooth
 bar
 bullet
 whisker

General Defaults:

 :type              => 'smooth'
 :height            => 14px
 :upper             => 50
 :above_color       => 'red'
 :below_color       => 'grey'
 :background_color  => 'white'
 :line_color        => 'lightgrey'

==License

Licensed under the MIT license.

=end
class Sparklines

  VERSION = '0.5.0'

  @@label_margin = 5.0
  @@pointsize = 10.0

  class << self

    ##
    # Plots a sparkline and returns a Magic::Image object.

    def plot_to_image(data=[], options={})
      defaults = {
        :type => 'smooth',
        :height => 14,
        :upper => 50,
        :diameter => 20,
        :step => 2,
        :line_color => 'lightgrey',

        :above_color => 'red',
        :below_color => 'grey',
        :background_color => 'white',
        :share_color => 'red',
        :remain_color => 'lightgrey',
        :min_color => 'blue',
        :max_color => 'green',
        :last_color => 'red',
        :std_dev_color => '#efefef',

        :has_min => false,
        :has_max => false,
        :has_last => false,
        :has_std_dev => false,

        :label => nil
      }

      # HACK for HashWithIndifferentAccess
      options_sym = Hash.new
      options.keys.each do |key|
        options_sym[key.to_sym] = options[key]
      end

      options_sym  = defaults.merge(options_sym)

      # Call the appropriate method for actual plotting.
      sparkline = self.new(data, options_sym)
      if %w(area bar bullet pie smooth discrete whisker).include? options_sym[:type]
        sparkline.send options_sym[:type]
      else
        sparkline.plot_error options_sym
      end
    end

    ##
    # Does the actual plotting of the graph.
    # Calls the appropriate subclass based on the :type argument.
    # Defaults to 'smooth'.
    #
    # Returns a blob.

    def plot(data=[], options={})
      plot_to_image(data, options).to_blob
    end
    
    ##
    # Writes a graph to disk with the specified filename, or "sparklines.png".
    
    def plot_to_file(filename="sparklines.png", data=[], options={})
      File.open( filename, 'wb' ) do |png|
        png << self.plot( data, options)
      end
    end

  end # class methods

  def initialize(data=[], options={})
    @data = Array(data)
    @options = options
    normalize_data
  end

  ##
  # Creates a continuous area sparkline. Relevant options.
  #
  #   :step - An integer that determines the distance between each point on the sparkline.  Defaults to 2.
  #
  #   :height - An integer that determines what the height of the sparkline will be.  Defaults to 14
  #
  #   :upper - An integer that determines the threshold for colorization purposes.  Any value less than upper will be colored using below_color, anything above and equal to upper will use above_color.  Defaults to 50.
  #
  #   :has_min - Determines whether a dot will be drawn at the lowest value or not.  Defaults to false.
  #
  #   :has_max - Determines whether a dot will be drawn at the highest value or not.  Defaults to false.
  #
  #   :has_last - Determines whether a dot will be drawn at the last value or not.  Defaults to false.
  #
  #   :min_color - A string or color code representing the color that the dot drawn at the smallest value will be displayed as.  Defaults to blue.
  #
  #   :max_color - A string or color code representing the color that the dot drawn at the largest value will be displayed as.  Defaults to green.
  #
  #   :last_color - A string or color code representing the color that the dot drawn at the last value will be displayed as.  Defaults to red.
  #
  #   :above_color - A string or color code representing the color to draw values above or equal the upper value.  Defaults to red.
  #
  #   :below_color - A string or color code representing the color to draw values below the upper value. Defaults to gray.

  def area

    step = @options[:step].to_f
    height = @options[:height].to_f
    background_color = @options[:background_color]

    create_canvas((@norm_data.size - 1) * step + 4, height, background_color)

    upper = @options[:upper].to_f

    has_min = @options[:has_min]
    has_max = @options[:has_max]
    has_last = @options[:has_last]

    min_color = @options[:min_color]
    max_color = @options[:max_color]
    last_color = @options[:last_color]
    below_color = @options[:below_color]
    above_color = @options[:above_color]


    coords = [[0,(height - 3 - upper/(101.0/(height-4)))]]
    i=0
    @norm_data.each do |r|
      coords.push [(2 + i), (height - 3 - r/(101.0/(height-4)))]
      i += step
    end
    coords.push [(@norm_data.size - 1) * step + 4, (height - 3 - upper/(101.0/(height-4)))]

    # TODO Refactor! Should take a block and do both.
    #
    # Block off the bottom half of the image and draw the sparkline
    @draw.fill(above_color)
    @draw.define_clip_path('top') do
      @draw.rectangle(0,0,(@norm_data.size - 1) * step + 4,(height - 3 - upper/(101.0/(height-4))))
    end
    @draw.clip_path('top')
    @draw.polygon(*coords.flatten)

    # Block off the top half of the image and draw the sparkline
    @draw.fill(below_color)
    @draw.define_clip_path('bottom') do
      @draw.rectangle(0,(height - 3 - upper/(101.0/(height-4))),(@norm_data.size - 1) * step + 4,height)
    end
    @draw.clip_path('bottom')
    @draw.polygon(*coords.flatten)

    # The sparkline looks kinda nasty if either the above_color or below_color gets the center line
    @draw.fill('black')
    @draw.line(0,(height - 3 - upper/(101.0/(height-4))),(@norm_data.size - 1) * step + 4,(height - 3 - upper/(101.0/(height-4))))

    # After the parts have been masked, we need to let the whole canvas be drawable again
    # so a max dot can be displayed
    @draw.define_clip_path('all') do
      @draw.rectangle(0,0,@canvas.columns,@canvas.rows)
    end
    @draw.clip_path('all')

    drawbox(coords[@norm_data.index(@norm_data.min)+1], 1, min_color) if has_min == true
    drawbox(coords[@norm_data.index(@norm_data.max)+1], 1, max_color) if has_max == true

    drawbox(coords[-2], 1, last_color) if has_last == true

    @draw.draw(@canvas)
    @canvas
  end

  ##
  # A bar graph.

  def bar
    step = @options[:step].to_f
    height = @options[:height].to_f
    background_color = @options[:background_color]

    create_canvas(@norm_data.length * step + 2, height, background_color)

    upper = @options[:upper].to_f
    below_color = @options[:below_color]
    above_color = @options[:above_color]

    i = 1
    @norm_data.each_with_index do |r, index|
      color = (r >= upper) ? above_color : below_color
      @draw.stroke('transparent')
      @draw.fill(color)
      @draw.rectangle( i, @canvas.rows,
      i + step - 2, @canvas.rows - ( (r / @maximum_value) * @canvas.rows) )
      i += step
    end

    @draw.draw(@canvas)
    @canvas
  end


  ##
  # Creates a discretized sparkline
  #
  #   :height - An integer that determines what the height of the sparkline will be.  Defaults to 14
  #
  #   :upper - An integer that determines the threshold for colorization purposes.  Any value less than upper will be colored using below_color, anything above and equal to upper will use above_color.  Defaults to 50.
  #
  #   :above_color - A string or color code representing the color to draw values above or equal the upper value.  Defaults to red.
  #
  #   :below_color - A string or color code representing the color to draw values below the upper value. Defaults to gray.

  def discrete

    height = @options[:height].to_f
    upper = @options[:upper].to_f
    background_color = @options[:background_color]
    step = @options[:step].to_f

    width = @norm_data.size * step - 1

    create_canvas(@norm_data.size * step - 1, height, background_color)

    below_color = @options[:below_color]
    above_color = @options[:above_color]
    std_dev_color = @options[:std_dev_color]

    drawstddevbox(width,height,std_dev_color) if @options[:has_std_dev] == true

    i = 0
    @norm_data.each do |r|
      color = (r >= upper) ? above_color : below_color
      @draw.stroke(color)
      @draw.line(i, (@canvas.rows - r/(101.0/(height-4))-4).to_f,
      i, (@canvas.rows - r/(101.0/(height-4))).to_f)
      i += step
    end

    @draw.draw(@canvas)
    @canvas
  end


  ##
  # Creates a pie-chart sparkline
  #
  #   :diameter - An integer that determines what the size of the sparkline will be.  Defaults to 20
  #
  #   :share_color - A string or color code representing the color to draw the share of the pie represented by percent.  Defaults to red.
  #
  #   :remain_color - A string or color code representing the color to draw the pie not taken by the share color. Defaults to lightgrey.

  def pie
    diameter = @options[:diameter].to_f
    background_color = @options[:background_color]

    create_canvas(diameter, diameter, background_color)

    share_color = @options[:share_color]
    remain_color = @options[:remain_color]
    percent = @norm_data[0]

    # Adjust the radius so there's some edge left in the pie
    r = diameter/2.0 - 2
    @draw.fill(remain_color)
    @draw.ellipse(r + 2, r + 2, r , r , 0, 360)
    @draw.fill(share_color)

    # Special exceptions
    if percent == 0
      # For 0% return blank
      @draw.draw(@canvas)
      return @canvas
    elsif percent == 100
      # For 100% just draw a full circle
      @draw.ellipse(r + 2, r + 2, r , r , 0, 360)
      @draw.draw(@canvas)
      return @canvas
    end

    # Okay, this part is as confusing as hell, so pay attention:
    # This line determines the horizontal portion of the point on the circle where the X-Axis
    # should end.  It's caculated by taking the center of the on-image circle and adding that
    # to the radius multiplied by the formula for determinig the point on a unit circle that a
    # angle corresponds to.  3.6 * percent gives us that angle, but it's in degrees, so we need to
    # convert, hence the muliplication by Pi over 180
    arc_end_x = r + 2 + (r * Math.cos((3.6 * percent)*(Math::PI/180)))

    # The same goes for here, except it's the vertical point instead of the horizontal one
    arc_end_y = r + 2 + (r * Math.sin((3.6 * percent)*(Math::PI/180)))

    # Because the SVG path format is seriously screwy, we need to set the large-arc-flag to 1
    # if the angle of an arc is greater than 180 degrees.  I have no idea why this is, but it is.
    percent > 50? large_arc_flag = 1: large_arc_flag = 0

    # This is also confusing
    # M tells us to move to an absolute point on the image.  We're moving to the center of the pie
    # h tells us to move to a relative point.  We're moving to the right edge of the circle.
    # A tells us to start an absolute elliptical arc.  The first two values are the radii of the ellipse
    # the third value is the x-axis-rotation (how to rotate the ellipse if we wanted to [could have some fun
    # with randomizing that maybe), the fourth value is our large-arc-flag, the fifth is the sweep-flag,
    # (again, confusing), the sixth and seventh values are the end point of the arc which we calculated previously
    # More info on the SVG path string format at: http://www.w3.org/TR/SVG/paths.html
    path = "M#{r + 2},#{r + 2} h#{r} A#{r},#{r} 0 #{large_arc_flag},1 #{arc_end_x},#{arc_end_y} z"
    @draw.path(path)

    @draw.draw(@canvas)
    @canvas
  end

  ##
  # Creates a smooth line graph sparkline.
  #
  #   :step - An integer that determines the distance between each point on the sparkline.  Defaults to 2.
  #
  #   :height - An integer that determines what the height of the sparkline will be.  Defaults to 14
  #
  #   :has_min - Determines whether a dot will be drawn at the lowest value or not.  Defaults to false.
  #
  #   :has_max - Determines whether a dot will be drawn at the highest value or not.  Defaults to false.
  #
  #   :has_last - Determines whether a dot will be drawn at the last value or not.  Defaults to false.
  #
  #   :has_std_dev - Determines whether there will be a standard deviation bar behind the smooth graph or not. Defaults to false.
  #
  #   :min_color - A string or color code representing the color that the dot drawn at the smallest value will be displayed as.  Defaults to blue.
  #
  #   :max_color - A string or color code representing the color that the dot drawn at the largest value will be displayed as.  Defaults to green.
  #
  #   :last_color - A string or color code representing the color that the dot drawn at the last value will be displayed as.  Defaults to red.
  #
  #   :std_dev_color - A string or color code representing the color that the standard deviation bar behind the smooth graph will be displayed as. Defaults to #efefef
  #
  #   :underneath_color - A string or color code representing the color that will be used to fill in the area underneath the line. Optional.
  #
  #   :target - A 1px horizontal line will be drawn at this value. Useful for showing an average.
  #
  #   :target_color - Color of the target line. Defaults to white.
  
  def smooth

    step = @options[:step].to_f
    height = @options[:height].to_f
    width = ((@norm_data.size - 1) * step).to_f

    background_color = @options[:background_color]
    create_canvas(width, height, background_color)

    min_color = @options[:min_color]
    max_color = @options[:max_color]
    last_color = @options[:last_color]
    has_min = @options[:has_min]
    has_max = @options[:has_max]
    has_last = @options[:has_last]
    line_color = @options[:line_color]
    has_std_dev = @options[:has_std_dev]
    std_dev_color = @options[:std_dev_color]

    target = @options.has_key?(:target) ? @options[:target].to_f : nil
    target_color = @options[:target_color] || 'white'

    drawstddevbox(width,height,std_dev_color) if has_std_dev == true

    @draw.stroke(line_color)
    coords = []
    i=0
    @norm_data.each do |r|
      coords.push [ i, (height - 3 - r/(101.0/(height-4))) ]
      i += step
    end

    if @options[:underneath_color]
      closed_polygon(height, width, coords)
    else
      open_ended_polyline(coords)
    end

    unless target.nil?
      normalized_target_value = ((target.to_f - @minimum_value)/(@maximum_value - @minimum_value)) * 100.0
      adjusted_target_value = (height - 3 - normalized_target_value/(101.0/(height-4))).to_i
      @draw.stroke(target_color)
      open_ended_polyline([[-5, adjusted_target_value], [width + 5, adjusted_target_value]])
    end

    drawbox(coords[@norm_data.index(@norm_data.min)], 2, min_color) if has_min == true
    drawbox(coords[@norm_data.index(@norm_data.max)], 2, max_color) if has_max == true
    drawbox(coords[-1], 2, last_color) if has_last == true

    @draw.draw(@canvas)
    @canvas
  end

  ##
  # Creates a whisker sparkline to track on/off type data. There are five states:
  # on, off, no value, exceptional on, exceptional off. On values create an up
  # whisker and off values create a down whisker. Exceptional values may be
  # colored differently than regular values to indicate, for example, a shut out.
  # No value produces an empty row to indicate a tie.
  #
  # * results - an array of integer values between -2 and 2. -2 is exceptional
  #   down, -1 is regular down, 0 is no value, 1 is up, and 2 is exceptional up.
  # * options - a hash that takes parameters
  #
  #   :height - height of the sparkline
  #
  #   :whisker_color - the color of regular whiskers; defaults to black
  #
  #   :exception_color - the color of exceptional whiskers; defaults to red
  #
  #   :step - Spacing for whiskers. Includes the whisker itself. Default 2.

  def whisker

    step = @options[:step].to_i
    height = @options[:height].to_f
    background_color = @options[:background_color]

    create_canvas(@data.size * step - 1, height, background_color)

    whisker_color = @options[:whisker_color] || 'black'
    exception_color = @options[:exception_color] || 'red'

    on_row = (@canvas.rows/2.0 - 1).ceil
    off_row = (@canvas.rows/2.0).floor
    i = 0
    @data.each do |r|
      color = whisker_color

      if ( (r == 2 || r == -2) && exception_color )
        color = exception_color
      end

      y_mid_point = (r >= 1) ? on_row : off_row

      y_end_point = y_mid_point
      if ( r > 0)
        y_end_point = 0
      end

      if ( r < 0 )
        y_end_point = @canvas.rows
      end

      @draw.stroke( color )
      @draw.line( i, y_mid_point, i, y_end_point )
      i += step
    end

    @draw.draw(@canvas)
    @canvas
  end

  ##
  # A bullet graph, a la Stephen Few in "Information Dashboard Design."
  #
  # * data - A single value for the thermometer part of the bullet.
  #   Represents the current value.
  # * options - a hash
  #
  #   :good - Numeric. Maximum value that will be shown on the graph. Required.
  #
  #   :height - Numeric. Defaults to 15. Should be a multiple of three.
  #
  #   :width - This graph expands to any specified width. Defaults to 100.
  #   
  #   :bad - Numeric. A darker shade background will be drawn up to this point.
  #
  #   :satisfactory - Numeric. A medium background will be drawn up to this point.
  #
  #   :target - Numeric value. A thin vertical bar will be drawn.
  #
  #   :good_color - Color for the rightmost section of the bullet.
  #
  #   :satisfactory_color - Color for the middle background of the bullet.
  #
  #   :bad_color - Color for the lowest, leftmost section.

  def bullet
    height = @options[:height].to_f
    @graph_width       = @options.has_key?(:width) ? @options[:width].to_f : 100.0
    good_color         = @options.has_key?(:good_color) ? @options[:good_color] : '#eeeeee'
    satisfactory_color = @options.has_key?(:satisfactory_color) ? @options[:satisfactory_color] : '#bbbbbb'
    bad_color          = @options.has_key?(:bad_color) ? @options[:bad_color] : '#999999'
    bullet_color       = @options.has_key?(:bullet_color) ? @options[:bullet_color] : 'black'
    @thickness = height/3.0

    create_canvas(@graph_width, height, good_color)

    @value = @norm_data
    @good_value = @options[:good].to_f

    @graph_height = @options[:height]

    qualitative_range_colors = [satisfactory_color, bad_color]
    [:satisfactory, :bad].each_with_index do |indicator, index|
      next unless @options.has_key?(indicator)
      @draw = @draw.fill(qualitative_range_colors[index])
      indicator_width_x  = @graph_width * (@options[indicator].to_f / @good_value)
      @draw = @draw.rectangle(0, 0, indicator_width_x.to_i, @graph_height)
    end

    if @options.has_key?(:target)
      @draw = @draw.fill(bullet_color)
      target_x = @graph_width * (@options[:target].to_f / @good_value)
      half_thickness = (@thickness / 2.0).to_i
      bar_width = 1.0
      @draw = @draw.rectangle(target_x.to_i, half_thickness, (target_x + bar_width).to_i, @thickness * 2 + half_thickness)
    end

    # Value
    @draw = @draw.fill(bullet_color)
    @draw = @draw.rectangle(0, @thickness.to_i, @graph_width * (@data.first.to_f / @good_value), (@thickness * 2.0).to_i)

    @draw.draw(@canvas)
    @canvas
  end

  ##
  # Draw the error Sparkline.

  def plot_error(options={})
    create_canvas(40, 15, 'white')

    @draw.fill('red')
    @draw.line(0,0,40,15)
    @draw.line(0,15,40,0)

    @draw.draw(@canvas)
    @canvas
  end

  private

  def normalize_data
    @minimum_value = @data.min
    @maximum_value = @data.max
    case @options[:type].to_s
    when 'pie'
      @norm_data = @data
    when 'bullet'
      @norm_data = @data
    else
      @norm_data = @data.map do |value|
        value = ((value.to_f - @minimum_value)/(@maximum_value - @minimum_value)) * 100.0
      end
    end
  end

  ##
  #   :arr - an array of points (represented as two element arrays)

  def open_ended_polyline(arr)
    0.upto(arr.length - 2) { |i|
      @draw.line(arr[i][0], arr[i][1], arr[i+1][0], arr[i+1][1])
    }
  end

  # Fills in the area under the line (used for a smooth graph)
  def closed_polygon(height, width, coords)
    return if @options[:underneath_color].nil?
    list = []
    # Start off screen so completed polygon doesn't show
    list << [-1, height + 1]
    list << [coords.first.first - 1, coords.first.last]
    # Now the normal coords
    list << coords
    # Close offscreen
    list << [coords.last.first + 1, coords.last.last]
    list << [width + 1, height + 1]
    @draw.fill( @options[:underneath_color] )
    @draw.polygon( *list.flatten )
  end

  ##
  # Create an image to draw on and a drawable to do the drawing with.
  #
  # TODO Refactor into smaller methods

  def create_canvas(w, h, bkg_col)
    @draw = Magick::Draw.new
    @draw.pointsize = @@pointsize # TODO Use height
    @draw.pointsize = @options[:font_size] if @options.has_key?(:font_size)
    @canvas = Magick::Image.new(w , h) { self.background_color = bkg_col }

    # Make room for label and last value
    unless @options[:label].nil?
      @options[:has_last] = true
      @label_width = calculate_width(@options[:label])
      @data_last_width = calculate_width(@data.last)
      # HACK The 7.0 is a severe hack. Must figure out correct spacing
      @label_and_data_last_width = @label_width + @data_last_width + @@label_margin * 7.0
      w += @label_and_data_last_width
    end

    @canvas = Magick::Image.new(w , h) { self.background_color = bkg_col }
    @canvas.format = "PNG"

    # Draw label and last value
    unless @options[:label].nil?
      if ENV.has_key?('MAGICK_FONT_PATH')
        vera_font_path = File.expand_path('Vera.ttf', ENV['MAGICK_FONT_PATH'])
        @font = File.exists?(vera_font_path) ? vera_font_path : nil
      else
        @font = nil
      end
      @font = @options[:font] if @options.has_key?(:font)

      @draw.fill = 'black'
      @draw.font = @font if @font
      @draw.gravity = Magick::WestGravity
      @draw.annotate( @canvas,
      @label_width, 1.0,
      w - @label_and_data_last_width + @@label_margin, h - calculate_caps_height/2.0,
      @options[:label])

      @draw.fill = 'red'
      @draw.annotate( @canvas,
      @data_last_width, 1.0,
      w - @data_last_width - @@label_margin * 2.0, h - calculate_caps_height/2.0,
      @data.last.to_s)
    end
  end

  ##
  # Utility to draw a coloured box
  # Centred on pt, offset off in each direction, fill color is col

  def drawbox(pt, offset, color)
    @draw.stroke 'transparent'
    @draw.fill(color)
    @draw.rectangle(pt[0]-offset, pt[1]-offset, pt[0]+offset, pt[1]+offset)
  end

  ##
  # Utility to draw the standard deviation box
  #
  def drawstddevbox(width,height,color)
    mid=@norm_data.inject(0) {|sum,v| sum+=v}/@norm_data.size
    std_dev = standard_deviation(@norm_data)
    lower = (height - 3 - (mid-std_dev)/(101.0/(height-4)))
    upper = (height - 3 - (mid+std_dev)/(101.0/(height-4)))
    @draw.stroke 'transparent'
    @draw.fill(color)
    @draw.rectangle(0, lower, width, upper)
  end

  def calculate_width(text)
    @draw.get_type_metrics(@canvas, text.to_s).width
  end

  def calculate_caps_height
    @draw.get_type_metrics(@canvas, 'X').height
  end

  ##
  # Calculation helper for standard deviation.
  #
  # Thanks to Warren Seen
  # http://warrenseen.com/blog/2006/03/13/how-to-calculate-standard-deviation/
  def variance(population)
    n = 0
    mean = 0.0
    s = 0.0
    population.each { |x|
      n = n + 1
      delta = x - mean
      mean = mean + (delta / n)
      s = s + delta * (x - mean)
    }
    # if you want to calculate std deviation
    # of a sample change this to "s / (n-1)"
    return s / n
  end

  ##
  # Calculate the standard deviation of a population
  #
  #   accepts: an array, the population
  #   returns: the standard deviation
  def standard_deviation(population)
    Math.sqrt(variance(population))
  end

end
