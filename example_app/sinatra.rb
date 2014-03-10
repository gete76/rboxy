require '~/projects/rboxy/rboxy.rb'
require 'sinatra'
require 'haml'
require 'json'
require 'pry'

set :public_folder, File.dirname(__FILE__) + '/public'
get '/' do 
	file = "#{File.dirname(__FILE__)}/../example.rb"
	output = Rboxy::Builder.new(file)
	#binding.pry
	@html = output.html_output
	@js = output.js_output
    #'<html>'+output.html_output+'<script type="text/javascript">'+output.js_output+'</script></html>'
    haml 'views/layout'
end

get '/user' do
	content_type :json
	[{first_name: 'rboxy', last_name: 'test'},{first_name: 'gerg', last_name: 'terg'}].to_json
end
