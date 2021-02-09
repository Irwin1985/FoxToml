* main
set step on 
set default to f:\desarrollo\github\foxtoml\src\
set procedure to 'toml_lexer' additive
set procedure to 'toml_parser' additive

local source
text to source noshow
# This is a TOML document

title = "TOML Example"

[owner]
name = "Tom Preston-Werner"
dob = 1979-05-27

[database]
enabled = true
ports = [ 8001, 8001, 8002 ]
data = ["delta", "phi", 3.14]

[servers]

[servers.alpha]
ip = "10.0.0.1"
role = "frontend"

[servers.beta]
ip = "10.0.0.2"
role = "backend"
endtext
lexer = createobject('TomlLexer', source)
parser = createobject('TomlParser', lexer)
public obj
obj = parser.parse()
