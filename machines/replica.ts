import { createMachine } from 'xstate';

const replicaMachine = 
/** @xstate-layout N4IgpgJg5mDOIC5QCcwAcA2BLAxgQwDpVYwAXLAOygGJFQ0B7WLchiukAD0QCYBOACwE+AVgDMARjEAOAQDYA7AoE8eAGhABPRBIEAGAiL3HjYhTwlyRIhQF9bG1JlyEI6DA02UoAZVJ5SAFdYAFk8HAALSjBaJBBGZlZ2OO4EOWkxAgkJBUtROTkeBT1pDW0EXQMjEz0zCysbewcQCgY3eDinbHwiODJvDgSWLDYOVJUyxD4JAhqJaT5pPQEVvjF7R3cXAjdMT28-AOCwyOjBpmHRlMQxRYIisQEZHIFrPRzJir0+WZNs7Nk8j4GxAXW2EDYYHOiRGyVAqQU0jkBCeygy0gkegUfAUnykQmq7x433EGJE0hBYPw0MucK4OlKWgZv2M-CxIiecgECnWTSAA */
createMachine(
  {
  id: "replica",
  initial: "reseting",
  states: {
    reseting: {
      entry: ["deleteGitLockFile", "runResetScript"],
      always: {
        target: "deployingStatusMachine",
      },
    },
    deployingStatusMachine: {
      entry: "resumeStatusMachine",
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
      deleteGitLockFile: () => {},

      // reset.sh
      runResetScript: () => {},

      // docker-entrypoint-environment.sh
      resumeStatusMachine: () => {},
    },
  },
);
