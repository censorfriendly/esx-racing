<template>
  <div class="racing-app">
        <h1 @click="closeApp">Race App Screen</h1>
        <p class="error" v-html="errmessage">
        <hr/>
        <div class="grid third center">
            <div class="tab" :class="{active:index==1}" @click="triggerTab(1)">Pending Races</div>
            <div class="tab" :class="{active:index==2}" @click="triggerTab(2)">Tracks</div>
            <div class="tab" :class="{active:index==3}" @click="triggerTab(3)">Leaderboards</div>
        </div>
        <div class="interior-page">
            <div v-if="index==1">
                <pendingScreen v-bind:pendingList="pendingList" />
            </div>
            <div v-else-if="index==2">
                <trackScreen/>
            </div>
            <div v-else-if="index==3">
                <leaderboardScreen />
            </div>
        </div>
  </div>
</template>

<script>
import pendingScreen from './pendingScreen';
import leaderboardScreen from './leaderboardScreen';
import trackScreen from './trackScreen';
import Nui from '../utils/Nui';
export default {
  name: 'race-app',
  components: {
      pendingScreen,
      leaderboardScreen,
      trackScreen,
  },
  props: {
  },
  data() {
    return {
      index : 0,
      pendingList: {},
      errmessage: ''
    };
  },
  methods: {
      closeApp: function() {
        Nui.send('closeApp',{})
      },
      triggerTab: function(i) {
          if(i == 1){
            Nui.send('getPendingRaces',{})
          }
          this.index = i;
      }
  },
  mounted() {
    Nui.send('getTracks',{})
    Nui.send('getPendingRaces',{})
    this.listener = window.addEventListener(
      'message',
      event => {
        const item = event.data || event.detail;
        if (item.trackListEvent) {
            this.$store.state.trackList = item.tracks;
        }
        if (item.racingListEvent) {
            this.pendingList = item.list;
        }
        if (item.error) {
            this.errmessage = item.message;
        }
      },
      false,
    );
    console.log(this.$store);
  },

};
</script>

<style lang="scss">
.racing-app {
    display: none;
    background-color: green;
    position: absolute;
    bottom:0px;
    right:0px;
    padding:15px;
    min-height: 25%;
    min-width: 400px;
    .interior-page {
        height: 500px;
        overflow-y:auto;
    }
}
.tab {
    cursor: pointer;
    &.active {
        background-color: black;
        color: white;
    }
}
.error {
    color:red;
}
</style>
