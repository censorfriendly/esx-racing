// store.js
 
import Vue from "vue";
import Vuex from "vuex";
 
Vue.use(Vuex);
 
export default new Vuex.Store({
 state: {
    trackList: {},
    raceApp: {
        joinedRace: false,
        race_id: 0
    }
 },
 getters: {},
 mutations: {},
 actions: {}
});