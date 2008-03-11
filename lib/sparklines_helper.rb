require 'base64'
# Provides a tag for embedding sparklines graphs into your Rails app.
#
module SparklinesHelper

	# Call with an array of data and a hash of params for the Sparklines module.
  #
  #  sparkline_tag [42, 37, 43, 182], :type => 'bar', :line_color => 'black'
  #
	# You can also pass :class => 'some_css_class' ('sparkline' by default).
	def sparkline_tag(results=[], options={})		
    url = { :controller => 'sparklines' }
    url[:results] = results.join(',') unless results.nil?
		options = url.merge(options)
    attributes = %(class="#{options[:class] || 'sparkline'}" alt="Sparkline Graph" )
    attributes << %(title="#{options[:title]}" ) if options[:title]

    # prefer to use a "data" URL scheme as described in {RFC 2397}[http://www.ietf.org/rfc/rfc2397.txt]
#     data_url = "data:image/png;base64,#{Base64.encode64(Sparklines.plot(results,options))}"
#     tag = %(<img src="#{data_url}" #{attributes}/>)

#     # respect some limits noted in RFC 2397 since the data: url is supposed to be 'short'
#     data_url.length <= 1024 && tag.length <= 2100 ? tag :
      %(<img src="#{ url_for options }" #{attributes}/>)
		
	end

end
