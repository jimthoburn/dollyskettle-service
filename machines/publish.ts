import { createMachine } from 'xstate';

const publishMachine = 
/** @xstate-layout N4IgpgJg5mDOIC5QAcCuAjANgS1gCwDo0tc9sA7KAYkRQHtZsAXbO82kAD0QCYBOACwE+AVgDMARgAMfMXx5ipIgOwAaEAE9EEgVIIiphw2OU8JANhEqAvtfXEc+ArFSxkYchApQAChkd4ALIAhgDGZORgNEggyAzMrOwx3AjmfAAcBOkSPALpPGkCilIS6loIOnoGRlImZpY2turkdBBwHA6kRP6k3h3xLGwcKQI8ZYh8EgQ1EukZUgKLsk2xPU4ubh5elH4k+CHhFGD9jINJoClymTzKYqNi5g-pkunjFTLTRhLfs4tpK50nBA2McYnFTolhoh0lIeAQJGIbnw0mJ0vlzGNNNo7vovjwZOJsiJ0gC1ngTgkhsltK8sRVMjV+FJlCIiuY8spbLYgA */
createMachine(
  {
  id: "publish",
  initial: "publishing",
  states: {
    publishing: {
      entry: ["deleteGitLockFile", "runPublishScript"],
      always: {
        target: "suspendingPublishMachine",
      },
    },
    suspendingPublishMachine: {
      entry: "suspendPublishMachine",
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

      // update-content.sh
      runPublishScript: () => {},

      // docker-entrypoint-environment.sh
      suspendPublishMachine: () => {},
    },
  },
);
