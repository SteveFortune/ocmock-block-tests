# OCMock - Block Testing

### Features

- `[OCMArg invokeBlock]`

  - A constraint specific to block arguments.
  - It auto-invokes the block with default values for each of its arguments.
  - E.g. `OCMStub([uiView animateWithDuration:0.4 animations:[OCMArg invokeBlock] completion:[OCMArg invokeBlock]])`.

- `[OCMArg invokeBlockWithArgs:...]`

  - A constraint specific to block arguments.
  - It auto-invokes the block with the given values for each of its arguments.
  - The number of arguments passed in the vargs _must_ match the number of arguments that the block takes.
  - The type of the arguments passed in the vargs _must_ be compatible with the types of the arguments that the block takes.
  - Argument values which are not Objective-C objects (e.g. primitives, structs, pointers) must be boxed in `NSValue`.
  - Use `OCMOCK_VALUE` to do this conveniently.
  - Pass `OCMDefault` in the vargs to invoke the block with a default argument.
  - List of arguments must be nil-terminated.
  - Note that it requires additional parentheses when used in an `OCMStub` macro to avoid the vargs being parsed as separate macro arguments.
  - E.g. `OCMStub([obj doSomethingComplexCompletionBlock:([OCMArg invokeBlockWithArgs:"A first param", @123, OCMOCK_VALUE(somePtr), OCMDefault, nil])])`

### Test Cases

-
