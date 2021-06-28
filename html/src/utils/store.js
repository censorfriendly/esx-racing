// store.js
 
import Vue from "vue";
import Vuex from "vuex";
 
Vue.use(Vuex);
 
export default new Vuex.Store({
 state: {
    trackList: {},
    pendingList: {},
    leaderboard: {},
    raceApp: {
        joinedRace: false,
        race_id: 0,
        loading : false,
        isOwner : false,
        error: ''
    },
    global: {
        identifier : null
    },
    home: {
        finishedRaces: {},
        finishedRacesRacers: {} 
    },
    crypto: 0
 },
 getters: {},
 mutations: {},
 actions: {}
});