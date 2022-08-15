import { createMachine } from 'xstate';

const cronMachine = 
/** @xstate-layout N4IgpgJg5mDOIC5QGMBOB7AdgOlQV00wEtMoBiRUAB3ViIBcitKQAPRARg+wGYBOAAwA2DoL4cAHAHYOPADQgAnogAs47KIkrtAJik8VsqQF9jCtFmwQwVADbpFJKAAUMEPMkZYKSEDTpemCzsCHwSPLxCOioSIpI6OjzySog6UdhqfHwqPAIArLFCeTqm5hg4AO4AhgxOZKyw9FX0YNhVAGYtqAAUAPIAcgCiAPoAIgCCAJoAlGQWlTWMpCz+tcy+IXk8Urw5PHoq+XxSQgrKoRLY4UkcQlICWdsCEqZmIJjo1vC+87gExMtfKtAsFVDozog+DpeEl9lobltnqUQL9rHYHE5XJ8PCCgbQ1kENoh+NCdLIHnoOA9ZEJTikEGToZlxHkOCoouyOCY3r9qrVAdR8bjQCE+EIIjwJHkwkU2ToBCcIaFobDcqypDoJAJJXxkfMVkKmISRYgALQcaFCB6Sh7PC3SJWiGFwkRQngFPh5PKvYxAA */
createMachine(
  {
  id: "cron",
  initial: "running",
  states: {
    running: {
      always: [
        {
          cond: "isProduction",
          target: "deployingProduction",
        },
        {
          target: "waiting",
        },
      ],
    },
    deployingProduction: {
      entry: ["deployProductionWordpress"],
      always: {
        target: "waiting",
      },
    },
    waiting: {
      after: {
        ONE_DAY: {
          target: "running",
        },
      },
    },
  },
},
  {
    actions: {
      deployProductionWordpress: () => {},
    },
    guards: {
      isProduction: (context, event) => {
        return false;
      },
    },
    delays: {
      ONE_DAY: (context, event) => {
        return 24 * 1000;
      },
    },
  },
);
