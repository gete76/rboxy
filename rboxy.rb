
require 'pry'
require "#{File.dirname(__FILE__)}/binders/js/knockout.rb"
require "#{File.dirname(__FILE__)}/binders/css/css.rb"
module Rboxy
  #Builder class will be the core HTML generator
  #implements the bare rules for generating an HTML element
  #or required pieces to form a basic element without any attributes
  #other then id
  class Builder

    attr_writer :input
    attr_reader :css_output, :js_output, :html_output

    def initialize obj
      @output = {
        html: '',
        js: '',
        css: ''
      }
      
      @css_output = ''
      @js_output = ''
      @html_output = ''

      @object_nest = []
      @object_index = nil
      @object_counter = 0
      @object_index_topology = []

      @input = obj
      @page_fragments = []
      @current = {}

      if(@input.instance_of?(String) && File.exist?(@input))
        file = File.open(@input, 'rb')
        contents = file.read
        @input = eval(contents) #should be a jsonish type object
      end
    end
     
    def build 
      reset
      method_command @input
    end
    
    protected

    def reset
      @css_output = ''
      @js_output = ''
      @html_output = ''
      @current = {}
      @object_nest = []
      @object_index = nil
      @object_counter = 0
      @object_index_topology = []
      @page_fragments = []
    end

    def box_tags
      %w{ li ul a span div table thead tbody tr td th p }
    end

    def inline_tags
      %w{ input img audio }
    end

    def default_object
      {tag: 'div', id: generate_id }#id can be overwritten
    end
    #essential keys that non empty objects need for processing
    #and should be part of the core object language
    def object_keys
      [:tag, :has]
    end

    def generate_id
      @object_counter += 1
      "objectid_"+ @object_counter.to_s
    end
    #core command behind the :has tag
    def method_command val
      t = ''
      case val
        when String #string can be whatever you want but be careful
          t = val#Rboxy::StringInput.handle(val)
        when Hash #hash is an html object 
          @current = default_object.merge(val)
          t = make_object
        when Array #array just means you have another collection of objects or strings
          val.each{|v| t << method_command(v)}
        when Boolean
        when Integer 
      end
      return t
    end

    #the object{} to HTML generator that will produce css and js 
    #and return html to be appended to the html accumulator 
    def make_object
      if !@current.empty?
        html_acc = start_object
        keys = @current.keys
        (keys - object_keys).each do |key|
          handler = Rboxy::MethodHandler.new
          t = handler.run(key.to_s, @current[key], @current)
          if (t.instance_of?(String) && !t.empty?)#if val is string
            html_acc << " #{t}" 
          else
            if t.instance_variable_defined?('@js')
              @js_output<< t.js   
            end
            if t.instance_variable_defined?('@html')
              html_acc << " #{t.html}"
            end
            if t.instance_variable_defined?('@css')
              @css_output<< t.css
            end
          end
        end
        html_acc << close_object
        #if nest is empty then string can be returned to final HTML output
        if @object_index == nil
          @html_output << html_acc
          html_acc = ''
        end
      end
      return html_acc
    end
    #starts the generation of a new HTML object/DOM Element etc.
    def start_object
      @object_nest << @current
      @object_index = (@object_index == nil ? 0 : @object_index + 1)
      @object_index_topology << @object_index
      start = '<' + @current[:tag]
      @page_fragments << start
      return start
    end
    #this is where the magic starts to generate the next nested object
    def close_object
      #check out the objects collection or HTML children if you will
      has = (@current.has_key?(:has) ? method_command(@current[:has]) : '')
      output = (!inline_tags.index(@current[:tag]) ? ">#{has}</#{@current[:tag]}>" : " />")
      #@object_nest.pop#done with the object so get rid of it
      @object_index = (@object_index == 0 ? nil : @object_index - 1)
      @current = (@object_index == nil ? {} : @object_nest[@object_index])
      @page_fragments << output
      return output
    end
    
  end

  #core class for running non core tags
  #can always add new binders to this at runtime
  class MethodHandler
    attr_accessor :method_list   
    def initialize
      @method_list = {
        bind: Rboxy::Binders::Knockout.new,
        css: Rboxy::Binders::Css.new
      }
    end 

    def method_missing(val, *args)
      if(@method_list.key? val)
        return @method_list[val.to_sym].run(args[0],args[1])
      else
        #default match
        return "#{val.to_s}=\"#{args[0]}\""
      end
    end

    #or just define a handler here ending with '_method'
    #so {id: 'blah'}  becomes MethodHandler.id_method('blah')
    def run(key,arg,obj)
      self.send(key,arg,obj)
    end 
  end
  
  class ParseError; end

end

if(!ARGV.empty? && ($0 == __FILE__))
  ARGV.each do |arg|
    file = File.open(arg, 'rb')
    contents = file.read
    v = eval(contents)
    t = Rboxy::Builder.new(v)
    t.build
    puts t.html_output + '<script type="text/javascript">'+t.js_output+'</script>'
  end 
end

