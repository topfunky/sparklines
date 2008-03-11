#!/usr/bin/ruby

require 'test/unit'
require 'lib/sparklines'
require 'fileutils'
require 'tidy_table'
require 'dust'

class SparklinesTest < Test::Unit::TestCase

  def setup
    @output_dir = "test/actual"
    FileUtils.mkdir_p(@output_dir)

    @data = %w( 1 5 15 20 30 50 57 58 55 48
    44 43 42 42 46 48 49 53 55 59
    60 65 75 90 105 106 107 110 115 120
    115 120 130 140 150 160 170 100 100 10).map {|i| i.to_f}
  end

  test "basic bullet" do
    Sparklines.plot_to_file("#{@output_dir}/bullet_basic.png", 85, {
      :type => "bullet",
      :target => 80,
      :good => 100,
      :height => 15
    })
  end

  test "full-featured bullet" do
    Sparklines.plot_to_file("#{@output_dir}/bullet_full_featured.png", 85, {
      :type => "bullet",
      :target => 90,
      :bad => 60,
      :satisfactory => 80,
      :good => 100,
      :height => 15
    })
  end

  test "colorful bullet" do
    Sparklines.plot_to_file("#{@output_dir}/bullet_colorful.png", 85, {
      :type => "bullet",
      :target => 90,
      :bad => 60,
      :satisfactory => 80,
      :good => 100,
      :height => 15,
      :bad_color => '#c3e3bf',
      :satisfactory_color => '#96cf90',
      :good_color => "#6ab162"
    })
  end

  test "tall bullet" do
    Sparklines.plot_to_file("#{@output_dir}/bullet_tall.png", 85, {
      :type => "bullet",
      :target => 90,
      :bad => 60,
      :satisfactory => 80,
      :good => 100,
      :height => 30
    })
  end

  test "wide bullet" do
    Sparklines.plot_to_file("#{@output_dir}/bullet_wide.png", 85, {
      :type => "bullet",
      :target => 90,
      :bad => 60,
      :satisfactory => 80,
      :good => 100,
      :height => 15,
      :width => 200
    })
  end

  test "smooth with target" do
    quick_graph("smooth_with_target", {
      :type => "smooth",
      :target => 50,
      :target_color => '#999999',
      :line_color => "#6699cc",
      :underneath_color => "#ebf3f6"
    })
  end

  test "whisker with step" do
    quick_graph("whisker_with_step", {
      :type => "whisker",
      :step => 5
    })
  end

  def test_each_graph
    %w{pie area discrete smooth bar}.each do |type|
      quick_graph("#{type}", :type => type)
    end
  end

  def test_each_graph_with_label
    %w{pie area discrete smooth bar}.each do |type|
      quick_graph("labeled_#{type}", :type => type, :label => 'Glucose')
    end
  end

  def test_whisker_decimals
    @data = (1..200).map {|n| n.to_f/100 }
    quick_graph("labeled_whisker_decimals", {
      :height => 30,
      :type => 'smooth',
      :label => 'png'
    })
  end

  def test_whisker_random
    # Need data ranging from -2 to +2
    @data = (1..40).map { |i| rand(3) * (rand(2) == 1 ? -1 : 1) }
    quick_graph("whisker", :type => 'whisker')
  end

  def test_whisker_non_exceptional
    @data = [1,1,1,1,1,1,1,1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
    quick_graph("whisker_non_exceptional", :type => 'whisker')
  end

  ##
  # Send random values in the range (-9..9)

  def test_whisker_junk
    @data = (1..40).map { |i| rand(10) * (rand(2) == 1 ? -1 : 1) }
    quick_graph("whisker_junk", :type => 'whisker')
  end

  def test_pie
    # Test extremes which previously did not work right
    [0, 1, 45, 95, 99, 100].each do |value|
      Sparklines.plot_to_file("#{@output_dir}/pie#{value}.png",
      value, {
        :type => 'pie',
        :diameter => 128
      })
    end
    Sparklines.plot_to_file("#{@output_dir}/pie_flat.png",
    [60],
    {
      :type => 'pie'
    })
  end

  def test_special_conditions
    tests = {	'smooth_colored' =>
      {
        :type => 'smooth',
        :line_color => 'purple'
      },
      'pie_large'	 => {
        :type => 'pie',
        :diameter => 200
      },
      'area_high'	 => {
        :type => 'area',
        :upper => 80,
        :step => 4,
        :height => 20
      },
      'discrete_wide' => {
        :type => 'discrete',
        :step => 8
      },
      'bar_wide' => {
        :type => 'bar',
        :step => 8
      },
      'bar_tall' => {
        :type => 'bar',
        :below_color => 'blue',
        :above_color => 'red',
        :upper => 90,
        :height => 50,
        :step => 8
      }
    }
    tests.each do |name, options|
      quick_graph(name, options)
    end
  end

  def test_bar_extreme_values
    Sparklines.plot_to_file("#{@output_dir}/bar_extreme_values.png",
    [0,1,100,2,99,3,98,4,97,5,96,6,95,7,94,8,93,9,92,10,91], {
      :type => 'bar',
      :below_color => 'blue',
      :above_color => 'red',
      :upper => 90,
      :step => 4
    })
  end

  def test_string_args
    quick_graph("bar_string.png", {
      'type' => 'bar',
      'below_color' => 'blue',
      'above_color' => 'red',
      'upper' => 50,
      'height' => 50,
      'step' => 8
    })
  end

  def test_area_min_max
    quick_graph("area_min_max", {
      :has_min => true,
      :has_max => true,
      :has_first => true,
      :has_last => true
    })
  end

  def test_smooth_underneath_color
    quick_graph("smooth_underneath_color", {
      :type => 'smooth',
      :line_color => "#6699cc",
      :underneath_color => "#ebf3f6"
    })
  end

  def test_close_values
    Sparklines.plot_to_file("#{@output_dir}/smooth_similar_nonzero_values.png", [100, 90, 95, 99, 80, 90], {
      :type => 'smooth',
      :line_color => "#6699cc",
      :underneath_color => "#ebf3f6"
    })
  end

  def test_no_type
    Sparklines.plot_to_file("#{@output_dir}/error.png", 0, :type => 'nonexistent')
  end

  def test_standard_deviation
    quick_graph('standard_deviation', {
      :type => 'smooth',
      :height => 100,
      :line_color => '#666',
      :has_std_dev => true,
      :std_dev_color => '#cccccc'
    })
  end

  def test_standard_deviation_tall
    quick_graph('standard_deviation_tall', {
      :type => 'smooth',
      :height => 300,
      :line_color => '#666',
      :has_std_dev => true,
      :std_dev_color => '#cccccc'
    })
  end

  def test_standard_deviation_short
    quick_graph('standard_deviation_short', {
      :type => 'smooth',
      :height => 20,
      :line_color => '#666',
      :has_std_dev => true,
      :std_dev_color => '#cccccc'
    })
  end

  private

  def quick_graph(name, options)
    Sparklines.plot_to_file("#{@output_dir}/#{name}.png", @data, options)
  end

end

# HACK Make reference HTML file for viewing output
END {
  def image_tag(image_path)
    %(<img src="#{image_path}" />)
  end

  reference_files = Dir['test/expected/*']
  output = TidyTable.new(reference_files).to_html(%w(Expected Actual)) do |record|
    [image_tag("../../" + record), image_tag("../../" + record.gsub('expected', 'actual'))]
  end
  FileUtils.mkdir_p("test/actual")
  File.open("test/actual/result.html", "w") do |f|
    f.write <<-EOL
    <style>
    .first_column {
      text-align: right;
    }
    .last_column {
      text-align: left;
    }
    </style>
    EOL
    f.write output
  end
}
