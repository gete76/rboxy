module Rboxy
	class Core
		attr_accessor :key , :classes
		def initialize(key='', method_objects={}) 
			@key = key
			@classes = []
			@method_objects = method_objects
			@method_objects.each{|key,val| @classes << key}
		end

		def self.method_missing opts
			val = @method_objects[opts]
			return Proc.new{|c| }
		end

		def call object_class
			if @method_objects[object_class]
				#return lambda / proc
			end
		end
	end
end

module Rboxy
	module Binders
		class Tag
			def string_method val

			end

			def array_method val

			end

			def hash_method val

			end
		end
	end
end


module Rboxy
	module Binders
		class Base
			attr_accessor :output, :js, :html, :css
			def initialize 
				@output=''
				@html = ''
				@js = ''
				@css = ''
			end
			private
			def run input
				self.send(input.class.to_s.downcase+'_method', input)
			end
		end
	end
end

module Rboxy
	module Binders
		#has class is a core interpreter
		#its job is to actually read the next object
		class Has<::Base

			def string_method input
	      #matching strings starting with ex ruby: commands
	      #t = input.match(/(\A[a-zA-Z]{2,12}):\s/)
	      #if t == nil
	        @output<<input
	        #just give back string
	      #elsif lang_support.include?(t[1].to_s)
	        
	        #here we can intercept with another language if its in our language list
	        #perhaps insert a language interpreter here
	      #end
			end

			def array_method input
				input.each{|v| @output << self.send('run',v)}
			end

			def hash_method val
        #@current = default_object.merge(val)
        t = make_object
			end
		end
	end
end

module Rboxy
	class Builder 
		attr_accessor :output
		def initialize 
			@input = nil
			@output = nil
			@binders = {
				tag: Rboxy::Binders::Tag.new,
				has: Rboxy::Binders::Has.new
			} 
		end
	  
	  def build input
	  	@input = input
	  	run_method @input
	  end

	  private 
	  def run_method key, val
	  	#cls = val.class 
	  	@binders[key].run(val)
	  end
	end
end