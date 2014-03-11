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

class Builder 
	def initialize
		@keys = {} 
		tag = Rboxy::Core.new('tag', {
			'Array': array_handle()
		})
	end

	def tag_def
		arr = Proc.new{|c| }
	end 
end

