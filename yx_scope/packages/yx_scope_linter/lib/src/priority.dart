enum FixPriority {
  useAsyncDepForAsyncLifecycle,
  finalDep,
  considerDepSuffix;

  int get value => 100 - index;
}
