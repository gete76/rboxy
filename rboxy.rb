module Rboxy
  #Language class will be the core HTML generator
  #implements the bare rules for generating an HTML element
  #or required pieces to form a basic element without any attributes
  #other then id
  class Builder

    attr_writer :input
    attr_reader :css_output, :js_output, :html_output

    def initialize obj
      @output = ''
      @css_output = ''
      @js_output = ''
      @html_output = ''
      @html_acc = ''
      @html_objects = []
      @css_objects = []
      @js_objects = []

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
      method_command @input

    end
     
    def bind enum
      reset
      
      
      return @html_output
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
      {tag: 'div', id: generate_id }
    end
    #essential keys that non empty objects need for processing
    #and should be part of the core object language
    def object_keys
      [:tag, :has, :bind]
    end

    def generate_id
      @object_counter += 1
      "objectid_"+ @object_counter.to_s
    end

    def method_command val
      t = ''
      case val
        when String #string can be whatever you want but be careful
          t = Rboxy::StringInput.handle(val)
        when Hash #hash is an html object 
          @current = default_object.merge(val)
          
          t = make_object
        when Array #array just means you have another collection of objects or strings
          val.each{|v| t << method_command(v)}
      end
      return t
    end

    #the object to HTML generator that will bind css and js observers
    #to the object by building the js on the server side....here comes the fun part
    def make_object
      if !@current.empty?
        #all objects get incremented ID - ones that have :bind defined get the val appended also.
        @current[:id] = @current[:id] + '_' + @current[:bind] if @current.has_key?(:bind)
        html_acc = start_object
        #this is where we bind css or js to the object/element
        #or interpret non core key => val commands to be defined
        #by the user, a module, or caught by method_missing
        keys = @current.keys
        (keys - object_keys).each do |key|
           t = Rboxy::MethodHandler.send((key.to_s+'_method').to_sym, @current[key], @current)
           if (t.instance_of?(String) && !t.empty?)
             html_acc << " #{t}"
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

  class StringInput
    
    def lang_support
      %w{ javascript ruby css }
    end

    def self.handle input
      #matching strings starting with ex ruby: commands
      t = input.match(/(\A[a-zA-Z]{2,12}):\s/)
      if t == nil
        return input
        #just give back string
      elsif lang_support.include?(t[1].to_s)
        
        #here we can intercept with another language if its in our language list
        #perhaps insert a language interpreter here
      end
    end

  end

  class MethodHandler   
    def self.method_missing(val, *args)
      parts = val.to_s.match(/([a-zA-Z]+)_method\z/)
      #default match
      if(parts.length == 2)

        return "#{parts[1]}=\"#{args[0]}\""
      else
        #do nothing without raising error
        #this is useful for where MethodHandler is used other then make_object 
        return ::StringInput.handle(arg)
      end
    end
    #knockout handler
    def self.bind_method(arg, obj)
      binder = Rboxy::Binders::Knockout.new(arg, obj)
      binder.bind
      binder.html_attr
    end
    #or just define a handler here ending with '_method'
    #so {id: 'blah'}  becomes MethodHandler.id_method('blah')
  end
  
  class ParseError; end

end

if(!ARGV.empty? && ($0 == __FILE__))
  ARGV.each do |arg|
    file = File.open(arg, 'rb')
    contents = file.read
    v = eval(contents)
    t = Rboxy::Builder.new(v)
    puts t.html_output
  end 
end

