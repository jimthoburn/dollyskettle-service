import { createMachine } from 'xstate';

const backupMachine = 
/** @xstate-layout N4IgpgJg5mDOIC5QCMCGBjA1gVwA4Do0sBLAOygFVcBiCAe1LH1gBdUWmicCuzLdEoXHVjEWxBoJAAPRACYAnABZ8CgKwBmAIxaAHDqUKNANgDsAGhABPRFqUAGfGvsuXG03K3G1a0wF8-Sy48fAgwXAAbOis+ACVwiOJ0VGopYVFxSSQZRFMtRzz7ZU81OXtjBV1LGwQ7R2dXe3dPb18AwJBSOjD4bOCeDEw+KjSRMQlSKVkEJTlqxAUtfEb7Uw1nOVMmuQCgwZCwyOi4hKTUUYyJqcQHXXxtOWddIy0FUyUteYQFRwU-v98ZSKviUuxA-VCDDAF3GWVA030KiaWkeRnsHw0by+Wg0KkMf10hPW2w0ujB-RhmUm2WmemxplU-yZzN0xnafiAA */
createMachine(
  {
  id: "backup",
  initial: "backingUp",
  states: {
    backingUp: {
      entry: ["deleteGitLockFile", "runBackupScript"],
      onDone: {
        target: "deployingReplica",
      },
    },
    deployingReplica: {
      entry: ["deployReplicaMySQL", "deployReplicaWordpress"],
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

      // wordpress-backup.sh
      runBackupScript: () => {},

      // docker-entrypoint-environment.sh
      deployReplicaMySQL: () => {},
      deployReplicaWordpress: () => {},
    },
  },
);
