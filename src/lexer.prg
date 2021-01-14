clear
#include toml.h

&&>Test
cd f:\desarrollo\github\foxtoml\src
*set step on
lexer = createobject("lexer", filetostr("sample.toml"))
tok = lexer.get_next_token()
do while tok.type != T_EOF
	?"Type:", "'" + transform(tok.type) + "'", "Value:", tok.value
	tok = lexer.get_next_token()
enddo
&&<Test

define class lexer as Custom
	text = ''
	pos = 0
	line = 0
	col = 0
	current_char = ''
	dimension keywords(2)
	
	function init(text)
		this.text = text
		this.pos = 1
		this.current_char = substr(this.text, this.pos, 1)
		this.line = 1
		this.col = 1
		this.build_keywords()
	endfunc
	function build_keywords
		dimension this.keywords(1)
		this.keywords(1) = 'true'
		dimension this.keywords(2)
		this.keywords(2) = 'false'		
	endfunc
	function is_keyword(ident)
		if ascan(this.keywords, ident) > 0
			return T_KEYWORD
		else
			return T_IDENT
		endif
	endfunc
	function lexer_error
		error "Unknown character '" + transform(this.current_char) + "'"
	endfunc
	function advance
		this.pos = this.pos + 1
		if this.pos > len(this.text)
			this.current_char = T_NONE
		else
			this.current_char = substr(this.text, this.pos, 1)
			this.col = this.col + 1
		endif
		if this.current_char == LF
			this.line = this.line + 1
			this.col = 1
		endif
	endfunc
	function peek
		peek_pos = this.pos + 1
		if peek_pos > len(this.text)
			return T_NONE
		else
			return substr(this.text, peek_pos, 1)
		endif
	endfunc
	function is_letter(ch)
		return isalpha(ch) or ch == '_'
	endfunc
	function skip_whitespace
		do while this.current_char != T_NONE and this.current_char == T_SPACE
			this.advance()
		enddo
	endfunc
	function skip_comments
		do while this.current_char != T_NONE and this.current_char != LF
			this.advance()
		enddo
		if this.current_char == T_NONE
			error "Unexpected End Of File"
		endif
		this.advance() && eat LF
	endfunc
	function string
		result = ''
		this.advance() && eat begining "
		do while this.current_char != T_NONE
			&& "hola\r\nmundo"
			if this.current_char == '\'
				peek_char = this.advance()
				do case
				case peek_char == 'r'
					result = result + chr(13)
				case peek_char == 'n'
					result = result + chr(10)
				case peek_char == 't'
					result = result + chr(9)
				case peek_char == '"'
					result = result + '"'
				otherwise
					result = result + '\' + peek_char
				endcase
				this.advance()
				loop
			endif
			if this.current_char == '"'
				exit
			endif
			result = result + this.current_char
			this.advance()
		enddo
		if this.current_char == T_NONE
			error "Unterminated string"
		endif
		this.advance() && eat closing "
		return this.new_token(T_STRING, result)
	endfunc
	function number
		result = ''
		do while this.current_char != T_NONE and isdigit(this.current_char)
			result = result + this.current_char
			this.advance()
		enddo
		if this.current_char == '.' and isdigit(this.peek())
			do while this.current_char != T_NONE and isdigit(this.current_char)
				result = result + this.current_char
				this.advance()
			enddo
		endif
		return this.new_token(T_NUMBER, val(result))
	endfunc
	function identifier
		result = ''
		do while this.current_char != T_NONE and this.is_letter(this.current_char)
			result = result + this.current_char
			this.advance()
		enddo
		return this.new_token(this.is_keyword(result), result) 
	endfunc
	function new_token(type, value)
		token = createobject("empty")
		addproperty(token, "type", type)
		addproperty(token, "value", value)
		return token
	endfunc
	function get_next_token
		do while this.current_char != T_NONE
			if this.current_char == T_SPACE
				this.skip_whitespace()
				loop
			endif
			if this.current_char == T_HASH
				this.skip_comments()
				loop
			endif
			if this.current_char == T_DBQUOTE
				return this.string()
			endif
			if isdigit(this.current_char)
				return this.number()
			endif
			if this.is_letter(this.current_char)
				return this.identifier()
			endif
			if this.current_char == '['
				this.advance()
				return this.new_token(T_LBRACKET, '[')
			endif
			if this.current_char == ']'
				this.advance()
				return this.new_token(T_RBRACKET, ']')
			endif
			if this.current_char == '{'
				this.advance()
				return this.new_token(T_LBRACE, '{')
			endif
			if this.current_char == '}'
				this.advance()
				return this.new_token(T_RBRACE, '}')
			endif
			if this.current_char == '='
				this.advance()
				return this.new_token(T_ASSIGN, '=')
			endif
			if this.current_char == '.'
				this.advance()
				return this.new_token(T_DOT, '.')
			endif
			if this.current_char == ':'
				this.advance()
				return this.new_token(T_COLON, ':')
			endif
			if this.current_char == '-'
				this.advance()
				return this.new_token(T_DASH, '-')
			endif
			if this.current_char == ','
				this.advance()
				return this.new_token(T_COMMA, ',')
			endif
			if this.current_char == chr(13)
				this.advance() && eat CR
				this.advance() && eat LF
				return this.new_token(T_NEW_LINE, T_NEW_LINE)
			endif			
			this.lexer_error()
		enddo
		return this.new_token(T_EOF, T_NONE)
	endfunc
enddefine