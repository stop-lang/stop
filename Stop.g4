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
    : 'include' STRING
    ;

model_annotation:
   '@' model_type;

model
   : annotation* START? MODEL_TYPE (throw_type)? block
   | annotation* STOP? MODEL_TYPE (throw_type)? block
   | annotation* QUEUE? MODEL_TYPE (throw_type)? block
   | annotation* MODEL_TYPE RETURN_OP return_type (throw_type)? return_block
   ;

block
   : '{' ( statement ';'? )* '}'
   ;

statement
   : enumeration | field | transition | enqueue
   ;

return_block
   : '{' ( return_block_statement ';'? )* '}'
   ;

return_block_statement
   : enumeration | field
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
	: OPTIONAL? type ID (dynamic_source)? validation_block?
	| OPTIONAL? collection ID (dynamic_source)? validation_block?
	;

dynamic_source
    : RETURN_OP model_type (dynamic_source_mapping)?
    ;

dynamic_source_mapping
    : '(' dynamic_source_mapping_parameter (',' dynamic_source_mapping_parameter)* ')'
    ;

dynamic_source_mapping_parameter
    : ID ':' dynamic_source_mapping_parameter_rename
    ;

reference
    : ID
    | reference DOT ID
    ;

dynamic_source_mapping_parameter_rename
    : reference
    ;

validation_block
   : '{' ( validation_statement ';'? )* '}'
   ;

validation_statement
   : state_validation
   | validation
   ;

state_validation
   : '!state' (model_type | model_annotation)
   ;

validation
   : '!' ID validation_parameters?
   ;

validation_parameters:
   '(' (validation_parameter (',' validation_parameter)*)* ')'
   ;

validation_parameter
    : ID ':' validation_parameter_value
    ;

validation_parameter_value 
    : STRING
    | NUMBER
    ;

type
    : scalar_type | model_type | model_annotation
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
    : model_type | model_annotation
    ;

transition: TRANSITION_OP model_type
    | TRANSITION_OP model_annotation
    ;

enqueue: ENQUEUE_OP model_type
    | ENQUEUE_OP model_annotation
    ;

annotation:
   '@' annotation_type annotation_parameters?
   ;

annotation_type:
   model_type
   | reference
   ;

annotation_parameters:
   '(' (annotation_parameter (',' annotation_parameter)*)* ')'
   ;

annotation_parameter
    : ID ':' annotation_parameter_value
    ;

annotation_parameter_value 
    : STRING
    ;

// Tokens
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

fragment ESCAPED_QUOTE : '\\"';
STRING :   '"' ( ESCAPED_QUOTE | ~('\n'|'\r') )*? '"';

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
