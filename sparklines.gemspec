Gem::Specification.new do |s|
  s.name = %q{sparklines}
  s.version = "0.5.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Geoffrey Grosenbach"]
  s.date = %q{2008-08-20}
  s.description = %q{Tiny graphs.}
  s.email = %q{boss@topfunky.com}
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "MIT-LICENSE", "Manifest.txt", "README.txt", "Rakefile", "lib/sparklines.rb", "lib/sparklines_helper.rb", "samples/area-high.png", "samples/area.png", "samples/discrete.png", "samples/pie-large.png", "samples/pie.png", "samples/pie0.png", "samples/pie1.png", "samples/pie100.png", "samples/pie45.png", "samples/pie95.png", "samples/pie99.png", "samples/smooth-colored.png", "samples/smooth.png", "test/expected/area.png", "test/expected/area_high.png", "test/expected/area_min_max.png", "test/expected/bar.png", "test/expected/bar_extreme_values.png", "test/expected/bar_string.png.png", "test/expected/bar_tall.png", "test/expected/bar_wide.png", "test/expected/bullet_basic.png", "test/expected/bullet_colorful.png", "test/expected/bullet_full_featured.png", "test/expected/bullet_tall.png", "test/expected/bullet_wide.png", "test/expected/discrete.png", "test/expected/discrete_wide.png", "test/expected/error.png", "test/expected/labeled_area.png", "test/expected/labeled_bar.png", "test/expected/labeled_discrete.png", "test/expected/labeled_pie.png", "test/expected/labeled_smooth.png", "test/expected/labeled_whisker_decimals.png", "test/expected/pie.png", "test/expected/pie0.png", "test/expected/pie1.png", "test/expected/pie100.png", "test/expected/pie45.png", "test/expected/pie95.png", "test/expected/pie99.png", "test/expected/pie_flat.png", "test/expected/pie_large.png", "test/expected/smooth.png", "test/expected/smooth_colored.png", "test/expected/smooth_similar_nonzero_values.png", "test/expected/smooth_underneath_color.png", "test/expected/smooth_with_target.png", "test/expected/standard_deviation.png", "test/expected/standard_deviation_short.png", "test/expected/standard_deviation_tall.png", "test/expected/whisker.png", "test/expected/whisker_junk.png", "test/expected/whisker_non_exceptional.png", "test/expected/whisker_with_step.png", "test/expected/zeros.png", "test/test_all.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://nubyonrails.com/pages/sparklines}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{sparklines}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Tiny graphs.}
  s.test_files = ["test/test_all.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_development_dependency(%q<hoe>, [">= 1.7.0"])
    else
      s.add_dependency(%q<hoe>, [">= 1.7.0"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.7.0"])
  end
end
