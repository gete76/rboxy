module Rboxy
	module Binders
		
		class Css
			attr_reader :css
			def initialize
				@css = ''
			end 

			def run command, obj
        @css = ''
        @command = command
        @obj = obj
        interpret_string
        return self
      end

      def interpret_string 
        #matching strings starting with a ko binder
        case @command 
        when 'redbox'
        	@css = "
        		##{@obj[:id]}{
        		padding:10px;
        		border:2px solid red;
        	}
        		##{@obj[:id]}:hover{
        			background-color:#fdfdfd;
        	}

        	"
        end
      end
		end

	end
end