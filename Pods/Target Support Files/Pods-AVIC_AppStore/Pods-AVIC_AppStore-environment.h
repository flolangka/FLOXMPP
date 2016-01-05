
// To check if a library is compiled with CocoaPods you
// can use the `COCOAPODS` macro definition which is
// defined in the xcconfigs so it is available in
// headers also when they are imported in the client
// project.


// Debug build configuration
#ifdef DEBUG

  // FLEX
  #define COCOAPODS_POD_AVAILABLE_FLEX
  #define COCOAPODS_VERSION_MAJOR_FLEX 2
  #define COCOAPODS_VERSION_MINOR_FLEX 2
  #define COCOAPODS_VERSION_PATCH_FLEX 0

#endif
