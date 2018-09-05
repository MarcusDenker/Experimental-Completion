Class {
	#name : #CompletionContext,
	#superclass : #Object,
	#instVars : [
		'source',
		'position',
		'theClass',
		'completionToken',
		'model',
		'receiverClass',
		'controller',
		'ast',
		'node',
		'variables',
		'selectors',
		'context'
	],
	#category : #'NewCompletion-Model'
}

{ #category : #'as yet unclassified' }
CompletionContext class >> controller: aNECController class: aClass source: aString position: anInteger [ 
	^ self new
		setController: aNECController
		class: aClass
		source: aString
		position: anInteger
]

{ #category : #accessing }
CompletionContext >> completionToken [
	"here we need to return the name of the var or selector"
	node isLiteralNode ifTrue: [ ^ node value asString ].
	node isMethod ifTrue: [ ^ node selector asString ].
	^completionToken
		ifNil: [ node isMessage
			ifTrue: [ node selector ]
			ifFalse: [ node name ] ]
]

{ #category : #action }
CompletionContext >> configureSelectorsAndVariables [
	variables := true.
	selectors := true.
	^true
]

{ #category : #accessing }
CompletionContext >> context: aCompletionContext [
	context := aCompletionContext.
]

{ #category : #accessing }
CompletionContext >> createModel [
	"to be implemented"
	node isLiteralNode ifTrue: [ ^NECEmptyModel new ].
	node isMethod ifTrue: [ ^NECEmptyModel new ].
	self receiverClass
		ifNotNil: [^ NECTypedModel class: receiverClass].
	variables := false. selectors  := true.
	node isMessage ifFalse: [  variables := true. selectors  := true ].
	"self context: model."
	^ NECUntypedModel
		class: theClass
		temporaries: (ast isMethod ifTrue: [ ast temporaryNames ] ifFalse: [ #() ])
		additionals: #()
		variables: variables
		selectors: selectors
]

{ #category : #accessing }
CompletionContext >> model [
	model isNil ifTrue: [ model := self createModel ].
	^ model
]

{ #category : #action }
CompletionContext >> narrowWith: aString [ 
	completionToken := aString.
	model ifNotNil: [ model narrowWith: aString].
]

{ #category : #parsing }
CompletionContext >> parseSource [
	(theClass = UndefinedObject) 
		ifTrue: [ ast :=  RBParser parseFaultyExpression: source ]
		ifFalse: [ ast := RBParser parseFaultyMethod: source ]. 
	ast doSemanticAnalysis.
	TypingVisitor new visitNode: ast.
]

{ #category : #accessing }
CompletionContext >> receiverClass [
	node isMessage ifFalse: [ ^nil ].
	receiverClass := node receiver propertyAt: #type ifAbsent: [ nil ] .
	^ receiverClass
]

{ #category : #'as yet unclassified' }
CompletionContext >> setController: aECController class: aClass source: aString position: anInteger [ 
	controller := aECController.
	theClass := aClass ifNil: [ UndefinedObject ].
	source := aString.
	position := anInteger. 
	self parseSource.
	node := ast bestNodeFor: (position to: position).
	
]