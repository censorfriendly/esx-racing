// store.js
 
import Vue from "vue";
import Vuex from "vuex";
 
Vue.use(Vuex);
 
export default new Vuex.Store({
 state: {
    trackList: {},
    pendingList: {},
    raceApp: {
        joinedRace: false,
        race_id: 0,
        loading : false,
        isOwner : false
    },
    global: {
        identifier : null
    },
    home: {
        lastRace: [
            {
                "total_time": "139448",
                "race_id": 4,
                "player_name": "Test Racer",
                "lap": 2,
                "id": 2,
                "checkpoint": 1,
                "best_lap": "69889",
                "race_key": "37438431",
                "position": 1,
                "finished": 1,
                "identifier": "Char1:fbe32bb51c7d686f36d903c66de8531e8d1db82c"
            },
            {
                "total_time": "139448",
                "race_id": 4,
                "player_name": "Test Racer",
                "lap": 2,
                "id": 3,
                "checkpoint": 1,
                "best_lap": "69889",
                "race_key": "37653501",
                "position": 1,
                "finished": 1,
                "identifier": "Char1:fbe32bb51c7d686f36d903c66de8531e8d1db82c"
            }
        ]
    }
 },
 getters: {},
 mutations: {},
 actions: {}
});