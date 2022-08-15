import { createMachine } from 'xstate';

const statusMachine = 
/** @xstate-layout N4IgpgJg5mDOIC5SwC4EMUFdYDoVxQEsA7KAYkVAAcB7WQom4ykAD0QCYA2AVhw4CMABgCcAFjFCAHNwDsUqQBoQAT0QCOHHDyG7pHAMxiBXA1w4BfC8tQZsOCGCoAbGipJQACpgBGzwrAAFgCyaADGgSRgFEggtPSMzLHsCFxcQjgi6eI8PGJS0qLKaggaWjp6MkYmZpZWysQ0jvCxtli4+KgeLPEMhEwsKWIcxYgiAjh6QgJSIgUSYiIG9SBt9o4ubh7efgEh4ZHEYD10fQPJiGZS2gYaPFIGHLIcQouyowjjk3ozc68SSxWa1wECYx1ivUSg0Qsi4Yn4UjuIlkIm4QneqnUJm0PxEIh4sgMKK4QPQ7ROCX6SVAKRmHxm310HBE6LyZjEhKsViAA */
createMachine(
  {
  id: "status",
  initial: "testing",
  states: {
    testing: {
      entry: "runTestScript",
      always: {
        target: "suspendingReplica",
      },
    },
    suspendingReplica: {
      entry: "suspendReplica",
      always: {
        target: "done",
      },
    },
    done: {
      type: "final",
    },
  },
},
  {
    actions: {
      // test.sh
      runTestScript: () => {},
      suspendReplica: () => {},
    },
  },
);
