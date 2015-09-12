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
  - E.g. `OCMStub([obj doSomethingComplexCompletionBlock:([OCMArg invokeBlockWithArgs:@"A first param", @123, OCMOCK_VALUE(somePtr), OCMDefault, nil])])`

### Use Cases

- [`UIViewController` transition methods](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIViewController_Class/#//apple_ref/occ/instm/UIViewController/transitionFromViewController:toViewController:duration:options:animations:completion:)
- [`UIView` animation methods](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/)
- [Third party dependencies, e.g. `RestKit`](https://github.com/RestKit/RestKit/blob/c567522fc6a8cb70770228fa35410e138a75f7e1/Code/Network/RKObjectManager.h#L690-L694)
- [`NSArray` enumeration methods](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSArray_Class/#//apple_ref/occ/instm/NSArray/enumerateObjectsUsingBlock:)


### Tests

- This repo contains 2 test harnesses:

    - `Strange Types`, which tests these features out with all sorts of strange block signatures,
    - A sample application taken from [BetweenKit](https://github.com/ice3-software/between-kit), which aims to demonstrate how this feature might be used in the real world.

- All tests have passed on the following:

    - iPhone 6, iOS 8.3
    - iPad Mini, iOS 8.1
    - __TODO__

### Limitations

- This relies on `NSInvocation` to invoke the blocks and as a result, does not support `va_list`s or `unions` as arguments.
- This has not been tested with function pointers as block arguments.
- `OCMBlockArgCaller` is quite strict: it will throw if the type signature of a given argument doesn't match the type signature of the block (to offer as much protection as possible against weird bugs).

### References

- [This article](https://mikeash.com/pyblog/friday-qa-2011-05-06-a-tour-of-mablockclosure.html)
- [CTObjectiveCRuntimeAdditions](https://github.com/ebf/CTObjectiveCRuntimeAdditions#getting-runtime-information-about-blocks)
- [BlocksKit/DynamicDelegate](https://github.com/zwaldowski/BlocksKit/tree/master/BlocksKit/DynamicDelegate)
