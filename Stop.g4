grammar Stop;

// Rules

file: packageDeclaration? ( include | model | enumeration )+;

packageName
	:	ID
	|	packageName DOT ID
	;

packageDeclaration
    : 'package' packageName
    ;

include
    : 'include' FILENAME
    ;

model
   : START? MODEL_TYPE (throw_type)? block
   | STOP? MODEL_TYPE (throw_type)? block
   | QUEUE? MODEL_TYPE (throw_type)? block
   | ASYNC MODEL_TYPE (throw_type)? block_with_timeout
   | ASYNC MODEL_TYPE RETURN_OP return_type (throw_type)? return_block_with_timeout
   | MODEL_TYPE RETURN_OP return_type (throw_type)? return_block
   ;

block
   : '{' ( statement ';'? )* '}'
   ;

statement
   : enumeration | field | transition | enqueue
   ;

block_with_timeout
   : '{' ( block_with_timeout_statement ';'? )* '}'
   ;

block_with_timeout_statement
   : enumeration | field | transition | timeout | enqueue
   ;

return_block
   : '{' ( return_block_statement ';'? )* '}'
   ;

return_block_statement
   : enumeration | field
   ;

return_block_with_timeout
   : '{' ( return_block_with_timeout_statement ';'? )* '}'
   ;

return_block_with_timeout_statement
   : enumeration | field | timeout
   ;

scalar_type: 'double' | 'float' | 'int32' | 'int64' | 'uint32' | 'uint64' | 'sint32' | 'sint64'
	| 'fixed32' | 'fixed64' | 'sfixed32' | 'sfixed64' | 'bool' | 'string' | 'bytes' | 'timestamp'
	;

model_type
    : MODEL_TYPE
    | reference DOT MODEL_TYPE
    ;

enum_type
    : MODEL_TYPE
    ;

enum_value
    : MODEL_TYPE
    ;

enumeration
    : 'enum' enum_type '{' ( enum_value )+ '}'
    ;

field
	: OPTIONAL? type ID (async_source)?
	| OPTIONAL? collection ID (async_source)?
	;

async_source
    : RETURN_OP model_type (async_source_mapping)?
    ;

async_source_mapping
    : '(' async_source_mapping_parameter (',' async_source_mapping_parameter)* ')'
    ;

async_source_mapping_parameter
    : ID ':' async_source_mapping_parameter_rename
    ;

reference
    : ID
    | reference DOT ID
    ;

async_source_mapping_parameter_rename
    : reference
    ;

type
    : scalar_type | model_type
    ;

collection
    : '[' type ']'
    ;

return_type
    : collection | type;

throw_type
    : 'throws' throw_parameter (',' throw_parameter)*
    ;

throw_parameter
    : model_type
    ;

timeout: 'timeout' NUMBER transition;

transition: TRANSITION_OP model_type;

enqueue: ENQUEUE_OP model_type;


// Tokens
ASYNC : 'async';

START : 'start';

STOP : 'stop';

QUEUE : 'queue';

TRANSITION_OP : '->';

RETURN_OP : '<-';

ENQUEUE_OP : '>>';

OPTIONAL : 'optional';

DOT: '.';

NUMBER
   : '-'? ( DOT DIGIT+ | DIGIT+ ( DOT DIGIT* )? )
   ;

MODEL_TYPE
   : UPPERCASE_LETTER  ( LETTER | DIGIT )*
   ;

ID
   : LOWERCASE_LETTER ( LETTER | DIGIT )*
   ;

FILENAME
    : '"' (LETTER | DIGIT | DOT | '\\' | '/' | '-' | '_')+ '"'
    ;

fragment UPPERCASE_LETTER
   : [A-Z]
   ;

fragment LOWERCASE_LETTER
   : [a-z]
   ;

fragment LETTER
   : [a-zA-Z_]
   ;

fragment DIGIT
   : [0-9]
   ;

COMMENT
   : '/*' .*? '*/' -> skip
   ;

LINE_COMMENT
   : '//' .*? '\r'? '\n' -> skip
   ;

WS
   : [ \t\n\r]+ -> skip
   ;
